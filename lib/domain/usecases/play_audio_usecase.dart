import '../repositories/audio_repository_interface.dart';

class PlayAudioUseCase {
  final AudioRepositoryInterface repository;

  PlayAudioUseCase(this.repository);

  Future<void> execute(String audioFile) async {
    await repository.loadAudio(audioFile);
    await repository.play();
  }
}

