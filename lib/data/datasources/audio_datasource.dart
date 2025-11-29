import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../../domain/entities/audio_state.dart';

class AudioDataSource {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _stateController = StreamController<AudioState>.broadcast();
  AudioState _currentState = AudioState();

  AudioDataSource() {
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _currentState = _currentState.copyWith(
        isPlaying: state == PlayerState.playing,
      );
      _stateController.add(_currentState);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _currentState = _currentState.copyWith(duration: duration);
      _stateController.add(_currentState);
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentState = _currentState.copyWith(position: position);
      _stateController.add(_currentState);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _currentState = _currentState.copyWith(
        isPlaying: false,
        position: Duration.zero,
      );
      _stateController.add(_currentState);
    });
  }

  Future<void> loadAudio(String audioFile) async {
    _currentState = _currentState.copyWith(isLoading: true);
    _stateController.add(_currentState);

    try {
      await _audioPlayer.setSource(AssetSource(audioFile));
      _currentState = _currentState.copyWith(isLoading: false, isLoaded: true);
      _stateController.add(_currentState);
    } catch (e) {
      _currentState = _currentState.copyWith(isLoading: false);
      _stateController.add(_currentState);
      rethrow;
    }
  }

  Future<void> play() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentState = _currentState.copyWith(
      isPlaying: false,
      position: Duration.zero,
    );
    _stateController.add(_currentState);
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Stream<AudioState> get stateStream => _stateController.stream;

  void dispose() {
    _audioPlayer.dispose();
    _stateController.close();
  }
}
