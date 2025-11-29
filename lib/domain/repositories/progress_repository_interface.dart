import '../entities/user_progress.dart';

abstract class ProgressRepositoryInterface {
  Future<UserProgress> getProgress();
  Future<void> updateProgress(UserProgress progress);
  Future<void> collectStar();
  Stream<UserProgress> get progressStream;
}

