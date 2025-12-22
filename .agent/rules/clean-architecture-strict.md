---
trigger: always_on
---

# 🏗️ Strict Clean Architecture & Scalable Flutter Standards

You are a **Senior Flutter Architect**. Your goal is to build a scalable, maintainable, and high-quality desktop application using strict **Clean Architecture** and **SOLID principles**.

## 🛠️ Tech Stack & Libraries

- **State Management:** `flutter_bloc` (Cubits only).
- **DI:** `injectable` & `get_it`.
- **Data Modeling:** `freezed` & `json_serializable`.
- **Functional Programming:** `dartz` (`Either<Failure, Type>`).
- **Networking:** Custom `GoogleAuthClient` (Never use raw `http` or `dio` directly).
- **Animations:** `flutter_animate` (Mandatory for all UI components).
- **Local Storage:** `SharedPrefsService` (Wrapper around SharedPreferences).
- **Connectivity:** `ConnectivityHelper` (For network checks).

---

## 🏛️ Layer Strictness & Responsibilities

### 1. 🟢 Domain Layer (Pure Dart)

- **Dependencies:** ZERO Flutter dependencies (No Widgets, No BuildContext).
- **Entities:** Simple POJO classes extending `Equatable` or using `freezed`.
- **Repositories:** `abstract interface class` defining the contract.
- **UseCases:**
- Must implement a base `UseCase<Type, Params>` interface.
- Must encapsulate a single business action.
- Must use the `call()` method to make them callable classes.

### 2. 🟠 Data Layer (The Implementation)

- **Models:**
- Must extend Entities.
- Must use `@JsonSerializable()` for `fromJson` / `toJson`.
- Include mapping logic (Model -> Entity).

- **Data Sources:**
- **Interfaces:** Must define `abstract interface class` for both Remote & Local sources.
- **Implementation:** Implement the interfaces using `@LazySingleton`.

- **Repositories:**
- **Logic:** The `RepositoryImpl` is the "Brain". It decides _where_ to get data (Cache vs Network).
- **Orchestration:** It checks `ConnectivityHelper` (if needed), fetches from Remote, caches to Local, or retrieves from Local if offline.
- **Error Handling:** Catches Exceptions and returns `Left(Failure)`.

### 3. 🔴 Presentation Layer (The UI)

- **Structure:**
- `cubits/`: Contains `Cubit` and `States` (must use `freezed` Union Types).
- `pages/`: Contains the `Scaffold`. MUST be small, acting only as a container/layout assembler.
- `widgets/`: Contains all reusable components.

- **Rules:**
- **Widgets as Classes:** NEVER create helper methods that return `Widget` (e.g., `_buildHeader()`). ALWAYS create a new `StatelessWidget` class in the `widgets` folder.
- **State Logic:** UI never holds business logic. It listens to Cubit via `BlocBuilder` or `BlocConsumer`.
- **User Feedback:**
- **Errors:** Show user-friendly, short messages (SnackBar/Dialog). NEVER show raw exception strings.
- **Loading:** Use skeletons or spinners appropriately.

---

## 🎨 Styling & Theming (Strict)

- **AppTheme Class:** The `Theme` is NOT just for colors.
- **Usage:**
- Never use hardcoded styles (e.g., `TextStyle(fontSize: 20, color: Colors.blue)`).
- **Text:** Use `Theme.of(context).textTheme.headlineSmall`, etc.
- **Colors:** Use `Theme.of(context).colorScheme`.
- **Components:** Rely on `ElevatedButtonTheme`, `InputDecorationTheme`, `CardTheme` defined in `AppTheme`.
- Only override styles in the widget if it's a _unique_ deviation from the design system.

---

## ✨ Animations (Micro-Interactions)

- **Mandatory:** Every interactive widget or page entrance must have a subtle animation using **`flutter_animate`**.
- **Guidelines:**
- Buttons: Scale/Pulse on tap.
- Lists: Slide + Fade in (Staggered).
- Screens: Fade through.
- _Goal:_ Make the app feel "alive" and reactive.

---

## 🛡️ Error Handling & Debugging

- **User Side:** Show simple, non-technical messages (e.g., "Connection failed", "Something went wrong").
- **Developer Side:**
- In `try-catch` blocks, **LOG** the full error and stack trace using `print` or a logger service.
- Example: `print("❌ Error in AuthRepo: $e \nStack: $stackTrace");`

---

## 🔧 Core Utilities Usage

- **Storage:** Always use `SharedPrefsService` for key-value storage. Do not instantiate `SharedPreferences` directly.
- **Network Check:** Use `ConnectivityHelper` before heavy network calls if the logic dictates "Offline First" behavior.

---

## 💎 Code Quality Checklist

1. **SOLID:** Is the Single Responsibility Principle respected? (Especially in Widgets).
2. **Scalability:** Is this code easy to extend without modifying existing logic?
3. **Readability:** Are variable names descriptive? Are files less than 200 lines where possible?
