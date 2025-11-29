import 'dart:async';
import '../../domain/entities/user_progress.dart';
import '../../core/constants/app_constants.dart';

class ProgressDataSource {
  final _progressController = StreamController<UserProgress>.broadcast();
  UserProgress _currentProgress = UserProgress(
    collectedStars: 3,
    totalStars: AppConstants.totalStars,
    lastUpdated: DateTime.now(),
  );

  ProgressDataSource() {
    _progressController.add(_currentProgress);
  }

  Future<UserProgress> getProgress() async {
    return _currentProgress;
  }

  Future<void> updateProgress(UserProgress progress) async {
    _currentProgress = progress;
    _progressController.add(_currentProgress);
  }

  Future<void> collectStar() async {
    if (_currentProgress.collectedStars < _currentProgress.totalStars) {
      _currentProgress = _currentProgress.copyWith(
        collectedStars: _currentProgress.collectedStars + 1,
        lastUpdated: DateTime.now(),
      );
      _progressController.add(_currentProgress);
    }
  }

  Stream<UserProgress> get progressStream => _progressController.stream;

  void dispose() {
    _progressController.close();
  }
}

