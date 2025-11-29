import 'package:flutter/material.dart';
import '../../viewmodels/story_time_viewmodel.dart';
import '../../../domain/entities/story.dart';

class StoryAudioItem extends StatelessWidget {
  final Story story;
  final StoryTimeViewModel viewModel;

  const StoryAudioItem({
    Key? key,
    required this.story,
    required this.viewModel,
  }) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final audioState = viewModel.audioState;
        final isCurrentStory = viewModel.currentStory?.id == story.id;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
            ],
            border: Border.all(color: story.color.withOpacity(0.2), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: story.color,
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
                            story.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'ComicNeue',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            story.description,
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
                      story.duration,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isCurrentStory) ...[
                  SizedBox(height: 16),
                  Column(
                    children: [
                      Slider(
                        value: audioState.position.inSeconds.toDouble(),
                        min: 0,
                        max: audioState.duration.inSeconds > 0
                            ? audioState.duration.inSeconds.toDouble()
                            : 1.0,
                        onChanged: (value) {
                          viewModel.seek(Duration(seconds: value.toInt()));
                        },
                        activeColor: story.color,
                        inactiveColor: Colors.grey[300],
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(audioState.position),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              _formatDuration(audioState.duration),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => viewModel.stop(),
                        icon: Icon(Icons.stop, color: Colors.red),
                        iconSize: 30,
                      ),
                      SizedBox(width: 16),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: story.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: story.color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: audioState.isPlaying
                              ? () => viewModel.pause()
                              : () {
                                  if (!isCurrentStory) {
                                    viewModel.loadStory(story);
                                  }
                                  viewModel.play();
                                },
                          icon: Icon(
                            audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      if (audioState.isLoading)
                        Container(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            color: story.color,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        Container(width: 30, height: 30),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: 12),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => viewModel.loadStory(story),
                      icon: Icon(Icons.play_arrow),
                      label: Text('Play Story'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: story.color,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

