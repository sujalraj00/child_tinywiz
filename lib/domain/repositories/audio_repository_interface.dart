import '../entities/audio_state.dart';

abstract class AudioRepositoryInterface {
  Future<void> loadAudio(String audioFile);
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Stream<AudioState> get audioStateStream;
  void dispose();
}

