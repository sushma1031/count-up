import 'package:count_up/services/settings_service.dart';

class MockSettingsService implements SettingsService {
  double _soundVolume;
  int _preWorkoutCountdownSeconds;
  int _breakDurationSeconds;

  @override
  final bool isPersistenceAvailable;

  MockSettingsService({
    double soundVolume = 0.5,
    this.isPersistenceAvailable = true,
    int preWorkoutCountdownSeconds = SettingsService.defaultPreWorkoutCountdownSeconds,
    int breakDurationSeconds = SettingsService.defaultBreakDurationSeconds,
  })  : _soundVolume = soundVolume,
        _preWorkoutCountdownSeconds = preWorkoutCountdownSeconds,
        _breakDurationSeconds = breakDurationSeconds;

  @override
  double get soundVolume => _soundVolume;

  @override
  int get preWorkoutCountdownSeconds => _preWorkoutCountdownSeconds;

  @override
  int get breakDurationSeconds => _breakDurationSeconds;

  @override
  Future<void> setSoundVolume(double value) async {
    _soundVolume = value.clamp(0.0, 1.0);
  }

  @override
  Future<void> setPreWorkoutCountdownSeconds(int value) async {
    _preWorkoutCountdownSeconds = value.clamp(
      SettingsService.minPreWorkoutCountdownSeconds,
      SettingsService.maxPreWorkoutCountdownSeconds,
    );
  }

  @override
  Future<void> setBreakDurationSeconds(int value) async {
    _breakDurationSeconds = value.clamp(
      SettingsService.minBreakDurationSeconds,
      SettingsService.maxBreakDurationSeconds,
    );
  }
}
