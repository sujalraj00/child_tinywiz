import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Color(0xFFF0F8FF),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildExitButton(context),
                _buildConnectionStatus(),
                SizedBox(height: 20),
                _buildAvatar(),
                SizedBox(height: 20),
                _buildGreeting(),
                SizedBox(height: 40),
                _buildActivityMenu(),
                SizedBox(height: 40),
                _buildProgressBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: viewModel.isConnected ? Colors.green[100] : Colors.red[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: viewModel.isConnected ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: viewModel.isConnected ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(width: 8),
            Text(
              viewModel.isConnected ? 'Connected to Parent' : 'Disconnected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: viewModel.isConnected ? Colors.green[900] : Colors.red[900],
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => viewModel.openParentGatekeeper(),
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
          child: Icon(Icons.lock_outline, color: Colors.deepPurple, size: 20),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
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
          Center(child: Icon(Icons.face, size: 60, color: Colors.white)),
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
    );
  }

  Widget _buildGreeting() {
    return Column(
      children: [
        Text(
          'Hello, ${AppConstants.defaultChildName}!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A148C),
            fontFamily: AppConstants.fontFamily,
            shadows: [
              Shadow(color: Colors.white, blurRadius: 2, offset: Offset(1, 1)),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Ready to play?',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF6A1B9A),
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActivityButton(
          icon: Icons.menu_book_rounded,
          label: 'Story Time',
          color: Color(0xFF4CAF50),
          size: 80,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(1);
          },
        ),
        _buildActivityButton(
          icon: Icons.star_rounded,
          label: 'Fun Quiz',
          color: Color(0xFFFF9800),
          size: 80,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(2);
          },
        ),
        _buildActivityButton(
          icon: Icons.music_note_rounded,
          label: 'Sing Along',
          color: Color(0xFFE91E63),
          size: 80,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(3);
          },
        ),
      ],
    );
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
          onTap: onTap,
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
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = viewModel.progress;
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
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(width: 10),
          Row(
            children: List.generate(progress.totalStars, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Icon(
                  index < progress.collectedStars
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: index < progress.collectedStars
                      ? Colors.amber
                      : Colors.grey[400],
                  size: 28,
                ),
              );
            }),
          ),
          SizedBox(width: 8),
          if (progress.collectedStars < progress.totalStars)
            GestureDetector(
              onTap: () => viewModel.collectStar(),
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
}
