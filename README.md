# Nutrition Roulette

Let fate decide what you eat. Add your favorite foods and spin for a random pick when you cannot choose.

## Features

- **Pick a food** - Tap the button on the Home tab and get a random food from your list.
- **Manage foods** - Add and remove foods in the Manage tab, stored locally on the device.
- **Settings** - Switch between light, dark, and system theme, and choose from several color themes.
- **Swipe navigation** - Switch between tabs from the bottom bar or by swiping left/right.
- **Material 3 design** - Poppins font and a subtle gradient background in your chosen theme.

## Tech stack

- Flutter / Dart
- [sqflite](https://pub.dev/packages/sqflite) for local persistence
- Material 3 theming

## Getting started

### Prerequisites

- Flutter SDK (stable)
- Android SDK / emulator (or any other supported Flutter target)

### Run

```sh
flutter pub get
flutter run
```

### Test

```sh
flutter test
```

### Build an APK

```sh
flutter build apk --debug
```

The signed APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

## Project structure

```
lib/
  main.dart                         App entry point, theme and settings root
  settings/settings_controller.dart Theme mode + color theme state
  data/database.dart                SQLite persistence layer
  models/food.dart                  Food model
  screens/
    main_shell.dart                 Bottom navigation shell + swipeable tabs
    home_screen.dart                Random pick screen
    manage_foods_screen.dart        Add / remove foods
    settings_screen.dart            Theme and appearance settings
  widgets/
    gradient_background.dart        App background
```