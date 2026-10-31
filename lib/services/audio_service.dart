abstract class AudioService {
  Future<void> configure() async {}
  Future<void> setVolume(double volume) async {}
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();

  Future<void> disposeWhenDone() => dispose();
}
