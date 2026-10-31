import 'package:audioplayers/audioplayers.dart';
import 'package:count_up/services/audio_service.dart';

class TimerAudioService extends AudioService {
  AudioPlayer _player = AudioPlayer();
  final AssetSource _asset;
  double _volume;
  bool _isStarting = false;

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
    _isStarting = true;
    try {
      await _player.play(_asset, volume: _volume);
    } finally {
      _isStarting = false;
    }
  }

  @override
  Future<void> pause() async {
    // While play() is still starting, the player isn't [PlayerState.playing] yet, but pausing here
    // makes audioplayers cancel the pending start instead of playing through the pause.
    if (_player.state == PlayerState.playing || _isStarting) {
      await _player.pause();
    }
  }

  @override
  Future<void> resume() async {
    if (_player.state == PlayerState.paused) {
      await _player.resume();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }

  @override
  Future<void> disposeWhenDone() async {
    if (_player.state == PlayerState.playing || _isStarting) {
      await _player.onPlayerComplete.first;
    }
    await _player.dispose();
  }
}
