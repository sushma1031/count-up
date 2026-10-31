import 'package:count_up/services/audio_service.dart';

enum AudioStatus { playing, paused, stopped }

class MockAudioService extends AudioService {
  bool configured = false;
  bool disposed = false;

  /// Last value passed to [setVolume], or null if it was never called.
  double? volume;

  AudioStatus _status = AudioStatus.stopped;

  @override
  Future<void> configure() async {
    configured = true;
  }

  @override
  Future<void> setVolume(double value) async {
    volume = value;
  }

  @override
  Future<void> play() async {
    _status = AudioStatus.playing;
  }

  @override
  Future<void> pause() async {
    _status = AudioStatus.paused;
  }

  @override
  Future<void> resume() async {
    _status = AudioStatus.playing;
  }

  @override
  Future<void> stop() async {
    _status = AudioStatus.stopped;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }

  AudioStatus get status => _status;
}
