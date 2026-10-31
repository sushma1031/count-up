abstract class SettingsService {
  static const int defaultPreWorkoutCountdownSeconds = 5;
  static const int minPreWorkoutCountdownSeconds = 0;
  static const int maxPreWorkoutCountdownSeconds = 10;

  bool get isPersistenceAvailable;
  double get soundVolume;
  int get preWorkoutCountdownSeconds;

  Future<void> setSoundVolume(double value);
  Future<void> setPreWorkoutCountdownSeconds(int value);
}
