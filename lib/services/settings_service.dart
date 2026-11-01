abstract class SettingsService {
  static const int defaultPreWorkoutCountdownSeconds = 5;
  static const int minPreWorkoutCountdownSeconds = 0;
  static const int maxPreWorkoutCountdownSeconds = 10;

  static const int defaultBreakDurationSeconds = 0;
  static const int minBreakDurationSeconds = 0;
  static const int maxBreakDurationSeconds = 120;
  static const int breakDurationStepSeconds = 5;

  bool get isPersistenceAvailable;
  double get soundVolume;
  int get preWorkoutCountdownSeconds;
  int get breakDurationSeconds;

  Future<void> setSoundVolume(double value);
  Future<void> setPreWorkoutCountdownSeconds(int value);
  Future<void> setBreakDurationSeconds(int value);
}
