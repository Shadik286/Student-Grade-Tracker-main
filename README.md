# 📘 StudyDesk — Student Grade Tracker

A clean, fast Flutter app for keeping your academic life in one place. Add subjects, drop in your scores, and let the app crunch the numbers — overall average, per-subject breakdowns, and a quick glance at where you stand before exam week hits.

Built with Flutter + Provider, themed for both light and dark modes, and wrapped in a custom pill-style bottom nav that feels nicer than the stock `BottomNavigationBar`.

---

## ✨ What it does

- **Add subjects on the fly** — name, credit hours, score, max marks, and a quick note.
- **Subject list at a glance** — color-coded tiles show weighted contribution to your total average.
- **Smart summary screen** — overall GPA-style aggregate, sorted breakdown of best-to-worst performing subjects, and quick stats (highest, lowest, total credits).
- **Dark + Light themes** — toggle from the app bar, preference lives in memory for the session.
- **Custom animated bottom nav** — pill-shaped, gradient-active, with a smooth expand-on-select animation.

---

## 🧱 Project layout

```
lib/
├── main.dart                  # Entry point + MultiProvider + custom nav
├── models/
│   └── subject.dart           # Subject data model
├── providers/
│   ├── subject_provider.dart  # Add/remove/list subjects (ChangeNotifier)
│   └── theme_provider.dart    # Light/dark toggle
├── screens/
│   ├── add_subject_screen.dart
│   ├── subject_list_screen.dart
│   └── summary_screen.dart
├── themes/
│   └── app_themes.dart        # Material 3 light & dark themes
└── widgets/
    └── subject_tile.dart      # Reusable subject card
```

---

## 🚀 Running it locally

You'll need the [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+) installed.

```bash
# 1. Grab dependencies
flutter pub get

# 2. Pick a device (or launch an emulator/simulator first)
flutter devices

# 3. Run it
flutter run

# 4. (optional) Build a release bundle
flutter build apk        # Android
flutter build ios        # iOS
```

That's it — no API keys, no env files, no backend. Pure client-side.

---

## 🧠 How the state flows

State lives in three `ChangeNotifier`s, all wired up via `MultiProvider` in `main.dart`:

| Provider | Responsibility |
|---|---|
| `SubjectProvider` | Holds the `List<Subject>`, exposes add/remove operations |
| `ThemeProvider` | `bool isDarkMode`, flips on tap |
| `NavProvider` | Tracks the selected bottom-nav tab index |

Screens read state through `context.watch<T>()` and dispatch mutations through `context.read<T>()`. No `setState`, no boilerplate.

---

## 🎨 Theming

All colors, shapes, and component styles live in `lib/themes/app_themes.dart`. Both themes are Material 3, generated from a shared seed color so light and dark feel like the same app — not two strangers. If you want to rebrand:

1. Open `app_themes.dart`
2. Swap the `seedColor` value in `lightTheme` and `darkTheme`
3. Hot reload — Flutter regenerates the color scheme automatically.

---


---

## 📦 Dependencies

From `pubspec.yaml`:

- `flutter` — SDK
- `provider: ^6.1.1` — state management

Dev:

- `flutter_lints: ^3.0.0` — lint rules

That's the whole list. Keeping it minimal on purpose.

---

## 🛣️ Ideas for next iterations

- Persistent storage with `shared_preferences` or `hive` so subjects survive a restart.
- Per-subject grade history (multiple assessments per course).
- Export summary as PDF or CSV.
- Target grade calculator — "what do I need on the final to land an A?"
- Localization (currently English-only).

---

## 📄 License

Released under the MIT License. Use it, fork it, ship it in your portfolio.