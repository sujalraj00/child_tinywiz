import 'package:flutter/foundation.dart';
import '../../domain/entities/audio_state.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/audio_repository_interface.dart';

class StoryTimeViewModel extends ChangeNotifier {
  final AudioRepositoryInterface _audioRepository;

  bool _showWelcome = true;
  AudioState _audioState = AudioState();
  Story? _currentStory;
  List<Story> _stories = [];
  bool _showQuiz = false;

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
        title: 'स्मार्ट गिलहरी',
        description: 'An exciting adventure awaits!',
        duration: '5:30',
        audioFile: 'stories/story 1.mp3',
        colorValue: 0xFF4CAF50,
        quiz: Quiz(
          storyId: '1',
          questions: [
            QuizQuestion(
              question: 'गिलहरी का नाम क्या था?',
              options: ['झिलमिल', 'फुर्ती', 'चुलबुली', 'मिनी'],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'फुर्ती अखरोट को क्यों नहीं खोल पा रही थी?',
              options: [
                'क्योंकि उसे भूख नहीं थी',
                'क्योंकि अखरोट बहुत सख़्त था',
                'क्योंकि उसे पेड़ों से डर लगता था',
                'क्योंकि चिड़िया ने मना किया था',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'फुर्ती ने चिड़िया से क्या सीखा?',
              options: [
                'घोंसला कैसे बनाते हैं',
                'पेड़ पर नाचना',
                'चीज़ों को ऊपर से गिराने पर वे टूट सकती हैं',
                'उड़ना',
              ],
              correctAnswerIndex: 2,
            ),
            QuizQuestion(
              question: 'कहानी की मुख्य सीख क्या है?',
              options: [
                'ताकत सबसे ज़रूरी है',
                'हमेशा सोते रहना चाहिए',
                'दिमाग का इस्तेमाल करने से मुश्किल काम भी आसान हो जाते हैं',
                'अखरोट खाना गलत है',
              ],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ),
      Story(
        id: '2',
        title: 'चतुर मोर',
        description: 'A magical journey begins!',
        duration: '7:15',
        audioFile: 'stories/story 2.mp3',
        colorValue: 0xFF2196F3,
        quiz: Quiz(
          storyId: '2',
          questions: [
            QuizQuestion(
              question: 'मोर रोज़ कहाँ जाता था?',
              options: [
                'पहाड़ पर',
                'तालाब के पास',
                'खेतों में',
                'नदी के किनारे',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'मोर को कौन-सी चीज़ चमकती दिखी?',
              options: ['पत्थर', 'मोती', 'फूल', 'पत्ता'],
              correctAnswerIndex: 0,
            ),
            QuizQuestion(
              question: 'असल में "पत्थर" क्या था?',
              options: ['मेंढक', 'कछुआ', 'घोंघा', 'चूहा'],
              correctAnswerIndex: 2,
            ),
            QuizQuestion(
              question: 'कहानी की सीख क्या है?',
              options: [
                'रंग सबसे ज़रूरी हैं',
                'सिर्फ खुद को देखना चाहिए',
                'दूसरों की सुंदरता भी देखनी चाहिए',
                'घोंघे तेज़ होते हैं',
              ],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ),
      Story(
        id: '3',
        title: 'तेज़ हवा',
        description: 'Discover amazing secrets!',
        duration: '6:45',
        audioFile: 'stories/story 3.mp3',
        colorValue: 0xFFFF9800,
        quiz: Quiz(
          storyId: '3',
          questions: [
            QuizQuestion(
              question: 'लीला कौन थी?',
              options: ['चिड़िया', 'खरगोश', 'गिलहरी', 'कुत्ता'],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'हिरण किस बात के लिए जाना गया?',
              options: [
                'तेज दौड़ने के लिए',
                'शांत रहने के लिए',
                'जोर से बोलने के लिए',
                'खाना छिपाने के लिए',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'तेज आवाज किसकी थी?',
              options: [
                'शेर की दहाड़',
                'हवा की सीटी',
                'एक गिरी हुई डाल',
                'नदी का बहाव',
              ],
              correctAnswerIndex: 2,
            ),
            QuizQuestion(
              question: 'कहानी की मुख्य सीख क्या है?',
              options: [
                'सिर्फ तेज होना सबसे अच्छा है',
                'डर को दबाना चाहिए',
                'शांत दिमाग से हल मिल जाता है',
                'जंगल हमेशा खतरनाक होता है',
              ],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ),
      Story(
        id: '4',
        title: 'मदद',
        description: 'A tale of friendship and fun!',
        duration: '8:20',
        audioFile: 'stories/story 4.mp3',
        colorValue: 0xFFE91E63,
        quiz: Quiz(
          storyId: '4',
          questions: [
            QuizQuestion(
              question: 'लीला कौन थी?',
              options: ['चिड़िया', 'खरगोश', 'गिलहरी', 'कुत्ता'],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'हिरण किस बात के लिए जाना गया?',
              options: [
                'तेज दौड़ने के लिए',
                'शांत रहने के लिए',
                'जोर से बोलने के लिए',
                'खाना छिपाने के लिए',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'तेज आवाज किसकी थी?',
              options: [
                'शेर की दहाड़',
                'हवा की सीटी',
                'एक गिरी हुई डाल',
                'नदी का बहाव',
              ],
              correctAnswerIndex: 2,
            ),
            QuizQuestion(
              question: 'कहानी की मुख्य सीख क्या है?',
              options: [
                'सिर्फ तेज होना सबसे अच्छा है',
                'डर को दबाना चाहिए',
                'शांत दिमाग से हल मिल जाता है',
                'जंगल हमेशा खतरनाक होता है',
              ],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ),
      Story(
        id: '5',
        title: 'शेर और चूहा',
        description: 'An inspiring tale of courage!',
        duration: '7:00',
        audioFile: 'stories/story 5.mp3',
        colorValue: 0xFF9C27B0,
        quiz: Quiz(
          storyId: '5',
          questions: [
            QuizQuestion(
              question: 'सिंह ने चूहे को क्यों छोड़ा?',
              options: [
                'वह भूखा नहीं था',
                'चूहे ने वादा किया',
                'उसे नींद आ रही थी',
                'उसे डर लगा',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'सिंह किस में फँसा था?',
              options: ['गड्ढे में', 'जाल में', 'नदी में', 'पेड़ पर'],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'चूहे ने सिंह की कैसे मदद की?',
              options: [
                'जाल उठाया',
                'जाल काटा',
                'शिकारी को भगाया',
                'पानी लाया',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'कहानी की सीख क्या है?',
              options: [
                'छोटे जानवर तेज होते हैं',
                'मदद सिर्फ बड़े करते हैं',
                'किसी को छोटा मत समझो',
                'जाल खतरनाक होते हैं',
              ],
              correctAnswerIndex: 2,
            ),
          ],
        ),
      ),
      Story(
        id: '6',
        title: 'चींटी और टिड्डा',
        description: 'A wonderful learning experience!',
        duration: '6:30',
        audioFile: 'stories/story 6.mp3',
        colorValue: 0xFF00BCD4,
        quiz: Quiz(
          storyId: '6',
          questions: [
            QuizQuestion(
              question: 'चींटी क्या कर रही थी?',
              options: [
                'सो रही थी',
                'दाने जमा कर रही थी',
                'पेड़ काट रही थी',
                'खेल रही थी',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'टिड्डा क्या करता था?',
              options: [
                'खाना ढूँढता',
                'गाता और मज़े करता',
                'घर बनाता',
                'चींटी की मदद करता',
              ],
              correctAnswerIndex: 1,
            ),
            QuizQuestion(
              question: 'बारिश के समय टिड्डे की क्या हालत हुई?',
              options: [
                'उसके पास बहुत दाने थे',
                'वह जंगल छोड़ गया',
                'वह भूखा रह गया',
                'वह खुश था',
              ],
              correctAnswerIndex: 2,
            ),
            QuizQuestion(
              question: 'कहानी की सीख क्या है?',
              options: [
                'आराम ही सबसे अच्छा',
                'भविष्य की तैयारी जरूरी है',
                'बारिश हमेशा मजेदार है',
                'चींटी गाने नहीं देती',
              ],
              correctAnswerIndex: 1,
            ),
          ],
        ),
      ),
    ];
    notifyListeners();
  }

  void _setupAudioListeners() {
    _audioRepository.audioStateStream.listen((state) {
      final wasPlaying = _audioState.isPlaying;
      _audioState = state;

      // Show quiz when story finishes playing (detect when playback stops after reaching end)
      if (wasPlaying &&
          !state.isPlaying &&
          state.position.inSeconds > 0 &&
          state.duration.inSeconds > 0 &&
          (state.position.inSeconds >= state.duration.inSeconds - 1) &&
          _currentStory != null &&
          _currentStory!.quiz != null &&
          !_showQuiz) {
        // Small delay to ensure audio has fully stopped
        Future.delayed(Duration(milliseconds: 500), () {
          if (!_showQuiz &&
              _currentStory != null &&
              _currentStory!.quiz != null) {
            _showQuiz = true;
            notifyListeners();
          }
        });
      }
      notifyListeners();
    });
  }

  void closeQuiz() {
    _showQuiz = false;
    notifyListeners();
  }

  void startQuiz() {
    if (_currentStory != null && _currentStory!.quiz != null) {
      _showQuiz = true;
      notifyListeners();
    }
  }

  bool get showWelcome => _showWelcome;
  AudioState get audioState => _audioState;
  List<Story> get stories => _stories;
  Story? get currentStory => _currentStory;
  bool get showQuiz => _showQuiz;

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
