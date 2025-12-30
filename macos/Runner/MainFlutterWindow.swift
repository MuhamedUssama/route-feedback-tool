import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // 1. Initial Native Style (Melted Sidebar Look) & Boot Color
    self.titlebarAppearsTransparent = true
    self.styleMask.insert(.fullSizeContentView)
    self.titlebarSeparatorStyle = .none
    self.titleVisibility = .hidden 
    self.isMovableByWindowBackground = true
    
    // Boot Color: RGB(27, 29, 30) -> Dark Slate
    self.backgroundColor = NSColor(srgbRed: 27/255.0, green: 29/255.0, blue: 30/255.0, alpha: 1.0)
    self.appearance = NSAppearance(named: .darkAqua) // Start in Dark Mode
    
    // 2. Method Channel for Dynamic Theming
    let channel = FlutterMethodChannel(
        name: "com.mentor_assistant/native_theme",
        binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else { return }
        
        if call.method == "updateTitleBarColor" {
            if let args = call.arguments as? [String: Any] {
                 if let colorVal = args["backgroundColor"] as? Int {
                    // Extract RGB from ARGB int (Flutter Color.value)
                    let red = CGFloat((colorVal >> 16) & 0xFF) / 255.0
                    let green = CGFloat((colorVal >> 8) & 0xFF) / 255.0
                    let blue = CGFloat(colorVal & 0xFF) / 255.0
                    self.backgroundColor = NSColor(srgbRed: red, green: green, blue: blue, alpha: 1.0)
                 }
                 
                 if let textColorVal = args["textColor"] as? Int {
                    // Heuristic: If text is White (0xFFFFFFFF) -> Dark Mode (.darkAqua). Otherwise Light Mode (.aqua).
                    // We check if the lower 24 bits are effectively white (0xFFFFFF)
                    let isWhiteText = (textColorVal & 0xFFFFFF) == 0xFFFFFF
                    self.appearance = NSAppearance(named: isWhiteText ? .darkAqua : .aqua)
                 }
            }
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    super.awakeFromNib()
    self.orderOut(nil)
  }
}
