import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(TinyWizApp());
}

class TinyWizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyWiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'ComicNeue',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _collectedStars = 3;
  final int _totalStars = 5;
  int _currentIndex = 0;

  void _collectStar() {
    if (_collectedStars < _totalStars) {
      setState(() {
        _collectedStars++;
      });
    }
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openParentGatekeeper() {
    setState(() {
      _currentIndex = 4;
    });
  }

  Widget _buildActivityButton({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            onTap();
            _collectStar();
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(icon, size: size * 0.5, color: Colors.white),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
            fontFamily: 'ComicNeue',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Today\'s stars: ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A148C),
              fontFamily: 'ComicNeue',
            ),
          ),
          SizedBox(width: 10),
          Row(
            children: List.generate(_totalStars, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  index < _collectedStars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: index < _collectedStars
                      ? Colors.amber
                      : Colors.grey[400],
                  size: 28,
                ),
              );
            }),
          ),
          SizedBox(width: 8),
          if (_collectedStars < _totalStars)
            GestureDetector(
              onTap: _collectStar,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exit button for parents (top right)
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _openParentGatekeeper,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Large Central Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF9575CD), Color(0xFF673AB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.face, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Greeting Message
            Text(
              'Hello, Nitin!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A148C),
                fontFamily: 'ComicNeue',
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Ready to play?',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF6A1B9A),
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),

            // Main Activity Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActivityButton(
                  icon: Icons.menu_book_rounded,
                  label: 'Story Time',
                  color: Color(0xFF4CAF50),
                  size: 80,
                  onTap: () => _navigateTo(1),
                ),
                _buildActivityButton(
                  icon: Icons.star_rounded,
                  label: 'Fun Quiz',
                  color: Color(0xFFFF9800),
                  size: 80,
                  onTap: () => _navigateTo(2),
                ),
                _buildActivityButton(
                  icon: Icons.music_note_rounded,
                  label: 'Sing Along',
                  color: Color(0xFFE91E63),
                  size: 80,
                  onTap: () => _navigateTo(3),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Progress & Positive Reinforcement
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryTimeScreen() {
    return StoryTimeScreen(onBack: () => _navigateTo(0));
  }

  Widget _buildActivityScreen({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(title, style: TextStyle(fontFamily: 'ComicNeue')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _navigateTo(0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: color),
            SizedBox(height: 20),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'ComicNeue',
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This is a placeholder for the $title activity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentGatekeeperScreen() {
    final TextEditingController _pinController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String _correctPin = '1234';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Gatekeeper',
          style: TextStyle(fontFamily: 'ComicNeue'),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _navigateTo(0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter PIN to exit the app',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[700],
                  fontFamily: 'ComicNeue',
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'PIN',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PIN';
                  }
                  if (value != _correctPin) {
                    return 'Incorrect PIN';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _navigateTo(0);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Exit allowed')));
                  }
                },
                child: Text(
                  'Unlock',
                  style: TextStyle(fontSize: 18, fontFamily: 'ComicNeue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget screen;
    switch (_currentIndex) {
      case 0:
        screen = _buildHomeScreen();
        break;
      case 1:
        screen = _buildStoryTimeScreen();
        break;
      case 2:
        screen = _buildActivityScreen(
          title: 'Fun Quiz',
          icon: Icons.star_rounded,
          color: Color(0xFFFF9800),
        );
        break;
      case 3:
        screen = _buildActivityScreen(
          title: 'Sing Along',
          icon: Icons.music_note_rounded,
          color: Color(0xFFE91E63),
        );
        break;
      case 4:
        screen = _buildParentGatekeeperScreen();
        break;
      default:
        screen = _buildHomeScreen();
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      child: screen,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class StoryTimeScreen extends StatefulWidget {
  final VoidCallback onBack;

  const StoryTimeScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  _StoryTimeScreenState createState() => _StoryTimeScreenState();
}

class _StoryTimeScreenState extends State<StoryTimeScreen> {
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    // Show welcome message for 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        title: Text('Story Time', style: TextStyle(fontFamily: 'ComicNeue')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFC8E6C9)],
          ),
        ),
        child: _showWelcome
            ? _buildWelcomeScreen()
            : _buildStoryLibraryScreen(),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 100, color: Color(0xFF4CAF50)),
            SizedBox(height: 30),
            Text(
              'Welcome Nitin!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontFamily: 'ComicNeue',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'So, today we will learn a lesson',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF4CAF50),
                fontFamily: 'ComicNeue',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryLibraryScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Text(
              'Choose a Story to Listen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontFamily: 'ComicNeue',
              ),
            ),
          ),
          SizedBox(height: 16),

          // Stories List
          Expanded(
            child: ListView(
              children: [
                StoryAudioItem(
                  title: 'Motivational Speech by Amitabh Bachchan',
                  description: 'A story about courage and friendship',
                  duration: '5:30',
                  audioFile: 'audio/story1.mp3',
                  color: Color(0xFF4CAF50),
                ),
                SizedBox(height: 16),
                StoryAudioItem(
                  title: 'The Magic Forest',
                  description: 'Discover the secrets of the enchanted woods',
                  duration: '7:15',
                  audioFile: 'audio/story2.mp3',
                  color: Color(0xFF2196F3),
                ),
                SizedBox(height: 16),
                StoryAudioItem(
                  title: 'The Lost Star',
                  description: 'A journey to help a star find its way home',
                  duration: '6:45',
                  audioFile: 'audio/story3.mp3',
                  color: Color(0xFFFF9800),
                ),
                SizedBox(height: 16),
                StoryAudioItem(
                  title: 'The Kind Giant',
                  description: 'Learn about kindness and sharing',
                  duration: '8:20',
                  audioFile: 'audio/story4.mp3',
                  color: Color(0xFFE91E63),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryAudioItem extends StatefulWidget {
  final String title;
  final String description;
  final String duration;
  final String audioFile;
  final Color color;

  const StoryAudioItem({
    Key? key,
    required this.title,
    required this.description,
    required this.duration,
    required this.audioFile,
    required this.color,
  }) : super(key: key);

  @override
  _StoryAudioItemState createState() => _StoryAudioItemState();
}

class _StoryAudioItemState extends State<StoryAudioItem> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _loadAudio() async {
    if (_isLoaded) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _audioPlayer.setSource(AssetSource(widget.audioFile));
      if (mounted) {
        setState(() {
          _isLoaded = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading audio: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load audio: ${widget.title}')),
      );
    }
  }

  Future<void> _playAudio() async {
    if (!_isLoaded) {
      await _loadAudio();
    }
    await _audioPlayer.resume();
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _position = Duration.zero;
    });
  }

  Future<void> _seekAudio(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
        border: Border.all(color: widget.color.withOpacity(0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Info
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'ComicNeue',
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontFamily: 'ComicNeue',
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Progress Bar
            Column(
              children: [
                Slider(
                  value: _position.inSeconds.toDouble(),
                  min: 0,
                  max: _duration.inSeconds.toDouble(),
                  onChanged: _seekAudio,
                  activeColor: widget.color,
                  inactiveColor: Colors.grey[300],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stop Button
                IconButton(
                  onPressed: _stopAudio,
                  icon: Icon(Icons.stop, color: Colors.red),
                  iconSize: 30,
                ),
                SizedBox(width: 16),

                // Play/Pause Button
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isPlaying ? _pauseAudio : _playAudio,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(width: 16),

                // Loading Indicator or Placeholder
                if (_isLoading)
                  Container(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: widget.color,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Container(width: 30, height: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
