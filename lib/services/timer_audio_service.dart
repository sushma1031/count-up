import 'package:audioplayers/audioplayers.dart';
import 'package:count_up/services/audio_service.dart';

class TimerAudioService extends AudioService {
  AudioPlayer _player = AudioPlayer();
  AudioStatus _status = AudioStatus.stopped;
  final AssetSource _asset;
  double _volume;

  TimerAudioService(String assetPath, {double volume = 1.0})
      : _asset = AssetSource(assetPath),
        _volume = volume;

  // Configures player to duck other audio during playback
  @override
  Future<void> configure() async {
    await _player.setAudioContext(AudioContext(
      android: AudioContextAndroid(
        usageType: AndroidUsageType.notification,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
    ));
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume;
  }

  @override
  Future<void> play() async {
    if (_volume <= 0) return;
    await _player.play(_asset, volume: _volume);
    _status = AudioStatus.playing;
  }

  @override
  Future<void> pause() async {
    if (_status == AudioStatus.playing) {
      await _player.pause();
      _status = AudioStatus.paused;
    }
  }

  @override
  Future<void> resume() async {
    if (_status == AudioStatus.paused) {
      await _player.resume();
      _status = AudioStatus.playing;
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _status = AudioStatus.stopped;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  AudioStatus get status => _status;

  @override
  set status(AudioStatus value) {
    _status = value;
  }
}
