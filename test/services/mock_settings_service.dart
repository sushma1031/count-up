import 'package:count_up/services/settings_service.dart';

class MockSettingsService implements SettingsService {
  double _soundVolume;
  int _preWorkoutCountdownSeconds;

  @override
  final bool isPersistenceAvailable;

  MockSettingsService({
    double soundVolume = 0.5,
    this.isPersistenceAvailable = true,
    int preWorkoutCountdownSeconds = SettingsService.defaultPreWorkoutCountdownSeconds,
  })  : _soundVolume = soundVolume,
        _preWorkoutCountdownSeconds = preWorkoutCountdownSeconds;

  @override
  double get soundVolume => _soundVolume;

  @override
  int get preWorkoutCountdownSeconds => _preWorkoutCountdownSeconds;

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
}
