import '../repositories/progress_repository_interface.dart';

class CollectStarUseCase {
  final ProgressRepositoryInterface repository;

  CollectStarUseCase(this.repository);

  Future<void> execute() async {
    await repository.collectStar();
  }
}

