import '../../domain/repositories/progress_repository_interface.dart';
import '../../domain/entities/user_progress.dart';
import '../datasources/progress_datasource.dart';

class ProgressRepository implements ProgressRepositoryInterface {
  final ProgressDataSource _dataSource;

  ProgressRepository(this._dataSource);

  @override
  Future<UserProgress> getProgress() async {
    return await _dataSource.getProgress();
  }

  @override
  Future<void> updateProgress(UserProgress progress) async {
    await _dataSource.updateProgress(progress);
  }

  @override
  Future<void> collectStar() async {
    await _dataSource.collectStar();
  }

  @override
  Stream<UserProgress> get progressStream => _dataSource.progressStream;
}

