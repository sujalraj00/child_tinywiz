import 'package:animate_do/animate_do.dart';
import 'package:child_tinywiz/feature_box.dart';
import 'package:child_tinywiz/gemini_service.dart';
import 'package:child_tinywiz/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onBack;
  const HomePage({super.key, required this.onBack});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final GeminiService geminiService = GeminiService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isInitialized = false;
  bool hasError = false;
  String? errorMessage;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    try {
      await flutterTts.setSharedInstance(true);
      // Set language to English
      await flutterTts.setLanguage('en-US');
      // Set speech rate (0.0 to 1.0) - slightly slower for children
      await flutterTts.setSpeechRate(0.5);
      // Set pitch (0.5 to 2.0) - slightly higher for friendlier voice
      await flutterTts.setPitch(1.1);
      // Set volume (0.0 to 1.0)
      await flutterTts.setVolume(1.0);

      print('✅ [TTS] Text-to-speech initialized successfully');
      setState(() {});
    } catch (e) {
      print('❌ [TTS] Error initializing text-to-speech: $e');
    }
  }

  Future<void> initSpeechToText() async {
    try {
      bool available = await speechToText.initialize(
        onError: (error) {
          print('Speech recognition error: $error');
          setState(() {
            hasError = true;
            errorMessage = error.errorMsg;
          });
        },
        onStatus: (status) {
          print('Speech recognition status: $status');
        },
      );

      setState(() {
        isInitialized = available;
        hasError = !available;
        if (!available) {
          errorMessage = 'Speech recognition not available';
        }
      });

      print('Speech recognition initialized: $available');
    } catch (e) {
      print('Error initializing speech recognition: $e');
      setState(() {
        isInitialized = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> startListening() async {
    if (!isInitialized) {
      await initSpeechToText();
      if (!isInitialized) {
        _showErrorDialog(
          'Speech recognition is not available. Please check your permissions and try again.',
        );
        return;
      }
    }

    // Check if already listening
    if (speechToText.isListening) {
      return;
    }

    try {
      await speechToText.listen(
        onResult: onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: false,
        partialResults: true,
      );
      setState(() {});
      print('Started listening...');
    } catch (e) {
      print('Error starting listening: $e');
      _showErrorDialog(
        'Error starting speech recognition: $e\n\nPlease ensure microphone permission is granted.',
      );
    }
  }

  Future<void> stopListening() async {
    try {
      await speechToText.stop();
      setState(() {});
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
    print('Recognized words: $lastWords');

    // If final result, automatically process it
    if (result.finalResult) {
      print('Final result: $lastWords');
      // Automatically process the final result (fire and forget, but with guard)
      if (!isProcessing) {
        _processSpeechResult();
      }
    }
  }

  Future<void> _processSpeechResult() async {
    // Prevent duplicate processing
    if (isProcessing) {
      print('⚠️ [HomePage] Already processing, skipping...');
      return;
    }

    if (lastWords.isEmpty) {
      print('⚠️ [HomePage] No words to process');
      return;
    }

    isProcessing = true;
    print('🎤 [HomePage] User said: "$lastWords"');
    print('🚀 [HomePage] Making API call with recognized text...');

    setState(() {
      generatedContent = 'Processing...';
    });

    try {
      print('📞 [HomePage] Calling geminiService.isArtPromptAPI()...');
      final speech = await geminiService.isArtPromptAPI(lastWords);
      print('✅ [HomePage] API call completed. Response: "$speech"');

      if (speech.contains('https')) {
        print('🖼️ [HomePage] Response is an image URL');
        setState(() {
          generatedImageUrl = speech;
          generatedContent = null;
        });
        // Even for images, speak a message
        await systemSpeak('I found an image for you!');
      } else {
        print('💬 [HomePage] Response is text content');
        setState(() {
          generatedImageUrl = null;
          generatedContent = speech;
        });
        print('🔊 [HomePage] Speaking response...');
        // Always speak the response
        await systemSpeak(speech);
      }
    } catch (e, stackTrace) {
      print('❌ [HomePage] Error in API call: $e');
      print('❌ [HomePage] Stack trace: $stackTrace');
      final errorMessage =
          'Sorry, I had trouble understanding that. Could you try asking again?';
      setState(() {
        generatedContent = errorMessage;
      });
      // Speak the error message too
      await systemSpeak(errorMessage);
    } finally {
      isProcessing = false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Recognition Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> systemSpeak(String content) async {
    try {
      print('🔊 [TTS] Starting to speak: "$content"');

      // Clean the content - remove markdown, URLs, and special characters that might break TTS
      String cleanContent = content
          .replaceAll(RegExp(r'https?://\S+'), '') // Remove URLs
          .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1') // Remove bold markdown
          .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1') // Remove italic markdown
          .replaceAll(RegExp(r'#+\s*'), '') // Remove markdown headers
          .replaceAll(RegExp(r'`([^`]+)`'), r'$1') // Remove code blocks
          .replaceAll(RegExp(r'\n+'), '. ') // Replace newlines with periods
          .trim();

      // If content is empty after cleaning, use original
      if (cleanContent.isEmpty) {
        cleanContent = content;
      }

      print('🔊 [TTS] Speaking cleaned content: "$cleanContent"');

      // Stop any ongoing speech first
      await flutterTts.stop();

      // Wait a bit before starting new speech
      await Future.delayed(const Duration(milliseconds: 100));

      // Speak the content
      final result = await flutterTts.speak(cleanContent);

      if (result == 1) {
        print('✅ [TTS] Speech started successfully');
      } else {
        print('⚠️ [TTS] Speech returned result: $result');
      }
    } catch (e) {
      print('❌ [TTS] Error speaking: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Allen')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ).copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.borderColor),
                    borderRadius: BorderRadius.circular(
                      20,
                    ).copyWith(topLeft: Radius.zero),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning Nitin, what task can I do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'GPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  // SlideInLeft(
                  //   delay: Duration(milliseconds: start + delay),
                  //   child: const FeatureBox(
                  //     color: Pallete.secondSuggestionBoxColor,
                  //     headerText: 'Dall-E',
                  //     descriptionText:
                  //         'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  //   ),
                  // ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by TinyWiz',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            print(
              '🔘 [HomePage] Button pressed. isListening: ${speechToText.isListening}, lastWords: "$lastWords"',
            );

            if (speechToText.isListening) {
              // Stop listening manually
              print('🛑 [HomePage] Stopping listening...');
              await stopListening();

              // Wait a bit for final result to come through
              await Future.delayed(const Duration(milliseconds: 500));

              // Process the speech result
              await _processSpeechResult();
            } else {
              // Start listening
              print('🎤 [HomePage] Starting to listen...');

              // Clear previous results
              setState(() {
                lastWords = '';
                generatedContent = null;
                generatedImageUrl = null;
              });

              if (!isInitialized) {
                await initSpeechToText();
              }

              if (isInitialized) {
                await startListening();
              } else {
                _showErrorDialog(
                  'Please grant microphone permission to use speech recognition.',
                );
              }
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
