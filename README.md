# Count Up

A minimalist workout routine tracker app that supports timed and rep exercises. Currently built and tested only for Android.

## Snapshots
![screenshots of the home screen, a workout, and a timer in progress](public/screenshots.png)

## Features

**Workout Management**
- Create custom workouts. Add, edit, and organize exercises within workouts.
- Workouts are saved to local storage using Hive.
- Export/import workouts as JSON files

**Workout Player**
- Timed exercises show a circular progress indicator with the remaining time and play a sound alert at 3 seconds remaining
- Rep exercises show the rep count and complete when you tap Done icon
- Pause, resume, skip forward/backward through exercises

## Getting Started
### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/sushma1031/count-up.git
   cd count-up
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Testing

Run the test suite:
```bash
flutter test
```

## Building for Release

### Android APK
```bash
flutter build apk --split-per-abi
```
