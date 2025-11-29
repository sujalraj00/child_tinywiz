import '../../data/datasources/audio_datasource.dart';
import '../../data/datasources/socket_datasource.dart';
import '../../data/datasources/progress_datasource.dart';
import '../../data/repositories/audio_repository.dart';
import '../../data/repositories/socket_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../domain/repositories/audio_repository_interface.dart';
import '../../domain/repositories/socket_repository_interface.dart';
import '../../domain/repositories/progress_repository_interface.dart';
import '../../domain/usecases/collect_star_usecase.dart';
import '../../domain/usecases/play_audio_usecase.dart';
import '../../domain/usecases/validate_pin_usecase.dart';
import '../../presentation/viewmodels/home_viewmodel.dart';
import '../../presentation/viewmodels/story_time_viewmodel.dart';
import '../../presentation/viewmodels/parent_gatekeeper_viewmodel.dart';

class ServiceLocator {
  // Data Sources
  static final AudioDataSource _audioDataSource = AudioDataSource();
  static final SocketDataSource _socketDataSource = SocketDataSource();
  static final ProgressDataSource _progressDataSource = ProgressDataSource();

  // Repositories
  static AudioRepositoryInterface get audioRepository =>
      AudioRepository(_audioDataSource);
  
  static SocketRepositoryInterface get socketRepository =>
      SocketRepository(_socketDataSource);
  
  static ProgressRepositoryInterface get progressRepository =>
      ProgressRepository(_progressDataSource);

  // Use Cases
  static CollectStarUseCase get collectStarUseCase =>
      CollectStarUseCase(progressRepository);
  
  static PlayAudioUseCase get playAudioUseCase =>
      PlayAudioUseCase(audioRepository);
  
  static ValidatePinUseCase get validatePinUseCase => ValidatePinUseCase();

  // ViewModels
  static HomeViewModel get homeViewModel => HomeViewModel(
        progressRepository,
        socketRepository,
        collectStarUseCase,
      );

  static StoryTimeViewModel get storyTimeViewModel =>
      StoryTimeViewModel(audioRepository);

  static ParentGatekeeperViewModel get parentGatekeeperViewModel =>
      ParentGatekeeperViewModel(validatePinUseCase);

  static void dispose() {
    _audioDataSource.dispose();
    _socketDataSource.dispose();
    _progressDataSource.dispose();
  }
}

