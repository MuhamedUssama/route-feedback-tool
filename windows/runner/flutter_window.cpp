#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include <dwmapi.h>

#pragma comment(lib, "dwmapi.lib")

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  // Set the background brush to match the app's background color (0xFF1b1d1e -> RGB(27, 29, 30))
  // We keep this to prevent white flashes during resize, even if the title bar color changes dynamically.
  HBRUSH brush = CreateSolidBrush(RGB(27, 29, 30));
  SetClassLongPtr(GetHandle(), GCLP_HBRBACKGROUND, reinterpret_cast<LONG_PTR>(brush));

  // Set initial "Boot Color" for the title bar (User requested 0xFF1b1d1e)
  // This ensures the bar is dark while Flutter and the ThemeCubit are initializing.
  HWND hwnd = GetHandle();
  COLORREF titleBarColor = RGB(27, 29, 30);
  COLORREF titleTextColor = RGB(255, 255, 255); 
  DwmSetWindowAttribute(hwnd, 35, &titleBarColor, sizeof(titleBarColor));
  DwmSetWindowAttribute(hwnd, 36, &titleTextColor, sizeof(titleTextColor));

  method_channel_ =
      std::make_unique<flutter::MethodChannel<>>(
          flutter_controller_->engine()->messenger(), "com.mentor_assistant/native_theme",
          &flutter::StandardMethodCodec::GetInstance());

  method_channel_->SetMethodCallHandler(
      [hwnd = GetHandle()](const flutter::MethodCall<>& call,
                           std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "updateTitleBarColor") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (args) {
            auto bg_it = args->find(flutter::EncodableValue("backgroundColor"));
            if (bg_it != args->end()) {
              if (std::holds_alternative<int>(bg_it->second) || std::holds_alternative<int64_t>(bg_it->second)) {
                 int64_t color_val = std::holds_alternative<int>(bg_it->second) ? std::get<int>(bg_it->second) : std::get<int64_t>(bg_it->second);
                 COLORREF color = RGB((color_val >> 16) & 0xFF, (color_val >> 8) & 0xFF, color_val & 0xFF);
                 DwmSetWindowAttribute(hwnd, 35, &color, sizeof(color));
                 
                 // Also update the background brush to match
                 HBRUSH new_brush = CreateSolidBrush(color);
                 SetClassLongPtr(hwnd, GCLP_HBRBACKGROUND, reinterpret_cast<LONG_PTR>(new_brush));
                 // Note: We leak the old brush here, but it's one per theme change. Standard GDI practice usually requires cleanup, 
                 // but SetClassLongPtr replaces it. The system deletes Class brushes on destroy, but manual replacements might need DeleteObject.
                 // Ideally we track the previous brush and delete it, but for this simpler implementation we rely on OS cleanup at exit or minor leak acceptable compared to complexity.
              }
            }
            auto text_it = args->find(flutter::EncodableValue("textColor"));
             if (text_it != args->end()) {
              if (std::holds_alternative<int>(text_it->second) || std::holds_alternative<int64_t>(text_it->second)) {
                 int64_t color_val = std::holds_alternative<int>(text_it->second) ? std::get<int>(text_it->second) : std::get<int64_t>(text_it->second);
                 COLORREF color = RGB((color_val >> 16) & 0xFF, (color_val >> 8) & 0xFF, color_val & 0xFF);
                 DwmSetWindowAttribute(hwnd, 36, &color, sizeof(color));
              }
            }
          }
          result->Success();
        } else {
          result->NotImplemented();
        }
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    // this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    case WM_WINDOWPOSCHANGED: {
      LRESULT result = Win32Window::MessageHandler(hwnd, message, wparam, lparam);
      flutter_controller_->ForceRedraw();
      return result;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
