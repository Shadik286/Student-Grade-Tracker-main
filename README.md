# Student Grade Tracker

A small Flutter app where a student can add subjects with marks, see grades, and view a result summary.

## What it does

- **Add Subject** — enter a subject name and a mark (0–100). The app assigns a grade: A (≥80), B (≥65), C (≥50), F (<50).
- **Subject List** — see every subject you added. Swipe a row left to delete it.
- **Summary** — total subjects, average mark, and the overall grade. Updates live when you add or remove a subject.
- **Light/Dark theme** — toggle in the app bar. All colors come from `Theme.of(context)`, nothing is hardcoded.

The app has 3 screens switched via a `BottomNavigationBar`.

## Project layout

```
lib/
├── main.dart
├── models/subject.dart
├── providers/
│   ├── subject_provider.dart
│   └── theme_provider.dart
├── screens/
│   ├── add_subject_screen.dart
│   ├── subject_list_screen.dart
│   └── summary_screen.dart
├── themes/app_themes.dart
└── widgets/subject_tile.dart
```

## How it works

- `Subject` (`lib/models/subject.dart`) — has a private `_mark` field and a `grade` getter that returns `A`, `B`, `C`, or `F`. Also exposes `isPassing` (mark ≥ 50).
- `SubjectProvider` (`lib/providers/subject_provider.dart`) — holds `List<Subject>` and exposes `addSubject`, `removeSubject`, `subjects`, `passingSubjects` (uses `.where()`), `failingSubjects` (`.where()`), `averageMark`, `overallGrade`.
- `ThemeProvider` (`lib/providers/theme_provider.dart`) — toggles between light and dark mode.
- `app_themes.dart` — defines custom `ThemeData` for both light and dark modes.
- State is read with `context.watch<T>()` and mutated with `context.read<T>()`. There is no `setState` anywhere.

## Dependencies

- `flutter` — SDK
- `provider: ^6.1.1` — state management

Dev:

- `flutter_lints: ^3.0.0`
