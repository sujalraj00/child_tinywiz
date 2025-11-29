import 'package:flutter/material.dart';
import '../../viewmodels/story_time_viewmodel.dart';
import '../../../core/constants/app_constants.dart';
import '../widgets/story_audio_item.dart';

class StoryTimeScreen extends StatelessWidget {
  final StoryTimeViewModel viewModel;
  final VoidCallback onBack;

  const StoryTimeScreen({
    Key? key,
    required this.viewModel,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4CAF50),
        title: Text('Story Time', style: TextStyle(fontFamily: AppConstants.fontFamily)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
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
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            if (viewModel.showWelcome) {
              return _buildWelcomeScreen();
            } else {
              return _buildStoryLibraryScreen();
            }
          },
        ),
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
              'Welcome ${AppConstants.defaultChildName}!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'So, today we will learn a lesson',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF4CAF50),
                fontFamily: AppConstants.fontFamily,
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
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.stories.length,
              itemBuilder: (context, index) {
                final story = viewModel.stories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: StoryAudioItem(
                    story: story,
                    viewModel: viewModel,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

