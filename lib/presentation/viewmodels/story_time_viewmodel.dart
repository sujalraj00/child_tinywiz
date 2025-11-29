import 'package:flutter/foundation.dart';
import '../../domain/entities/audio_state.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/audio_repository_interface.dart';

class StoryTimeViewModel extends ChangeNotifier {
  final AudioRepositoryInterface _audioRepository;
  
  bool _showWelcome = true;
  AudioState _audioState = AudioState();
  Story? _currentStory;
  List<Story> _stories = [];

  StoryTimeViewModel(this._audioRepository) {
    _initialize();
    _setupAudioListeners();
  }

  void _initialize() {
    _loadStories();
    Future.delayed(Duration(seconds: 3), () {
      if (!_showWelcome) return;
      _showWelcome = false;
      notifyListeners();
    });
  }

  void _loadStories() {
    _stories = [
      Story(
        id: '1',
        title: 'Motivational Speech by Amitabh Bachchan',
        description: 'A story about courage and friendship',
        duration: '5:30',
        audioFile: 'audio/story.mp3',
        colorValue: 0xFF4CAF50,
      ),
      Story(
        id: '2',
        title: 'The Magic Forest',
        description: 'Discover the secrets of the enchanted woods',
        duration: '7:15',
        audioFile: 'audio/story2.mp3',
        colorValue: 0xFF2196F3,
      ),
      Story(
        id: '3',
        title: 'The Lost Star',
        description: 'A journey to help a star find its way home',
        duration: '6:45',
        audioFile: 'audio/story3.mp3',
        colorValue: 0xFFFF9800,
      ),
      Story(
        id: '4',
        title: 'The Kind Giant',
        description: 'Learn about kindness and sharing',
        duration: '8:20',
        audioFile: 'audio/story4.mp3',
        colorValue: 0xFFE91E63,
      ),
    ];
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioRepository.audioStateStream.listen((state) {
      _audioState = state;
      notifyListeners();
    });
  }

  bool get showWelcome => _showWelcome;
  AudioState get audioState => _audioState;
  List<Story> get stories => _stories;
  Story? get currentStory => _currentStory;

  Future<void> loadStory(Story story) async {
    _currentStory = story;
    await _audioRepository.loadAudio(story.audioFile);
    notifyListeners();
  }

  Future<void> play() async {
    await _audioRepository.play();
  }

  Future<void> pause() async {
    await _audioRepository.pause();
  }

  Future<void> stop() async {
    await _audioRepository.stop();
  }

  Future<void> seek(Duration position) async {
    await _audioRepository.seek(position);
  }

  @override
  void dispose() {
    _audioRepository.dispose();
    super.dispose();
  }
}

