import '../../domain/repositories/audio_repository_interface.dart';
import '../../domain/entities/audio_state.dart';
import '../datasources/audio_datasource.dart';

class AudioRepository implements AudioRepositoryInterface {
  final AudioDataSource _dataSource;

  AudioRepository(this._dataSource);

  @override
  Future<void> loadAudio(String audioFile) async {
    await _dataSource.loadAudio(audioFile);
  }

  @override
  Future<void> play() async {
    await _dataSource.play();
  }

  @override
  Future<void> pause() async {
    await _dataSource.pause();
  }

  @override
  Future<void> stop() async {
    await _dataSource.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _dataSource.seek(position);
  }

  @override
  Stream<AudioState> get audioStateStream => _dataSource.stateStream;

  @override
  void dispose() {
    _dataSource.dispose();
  }
}

