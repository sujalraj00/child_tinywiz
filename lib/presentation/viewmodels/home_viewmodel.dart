import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/progress_repository_interface.dart';
import '../../domain/repositories/socket_repository_interface.dart';
import '../../domain/usecases/collect_star_usecase.dart';

class HomeViewModel extends ChangeNotifier {
  final ProgressRepositoryInterface _progressRepository;
  final SocketRepositoryInterface _socketRepository;
  final CollectStarUseCase _collectStarUseCase;

  UserProgress _progress = UserProgress(
    collectedStars: 3,
    totalStars: 5,
    lastUpdated: DateTime.now(),
  );
  bool _isLocked = false;
  bool _isConnected = false;
  int _currentIndex = 0;
  Timer? _statusUpdateTimer;
  StreamSubscription<bool>? _lockStatusSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;

  HomeViewModel(
    this._progressRepository,
    this._socketRepository,
    this._collectStarUseCase,
  ) {
    _initialize();
  }

  void _initialize() {
    _loadProgress();
    // Don't set up socket listeners here - wait until socket is connected
  }

  Future<void> initializeSocket(String childId, {String? serverUrl}) async {
    // Connect first
    final connected = await _socketRepository.connect(
      childId,
      serverUrl: serverUrl,
    );

    if (connected) {
      // Then set up listeners after connection is established
      _setupSocketListeners();
      _startPeriodicStatusUpdates();
    } else {
      print('❌ Failed to connect socket, cannot set up listeners');
    }
  }

  Future<void> _loadProgress() async {
    _progress = await _progressRepository.getProgress();
    _progressRepository.progressStream.listen((progress) {
      _progress = progress;
      notifyListeners();
    });
    notifyListeners();
  }

  void _setupSocketListeners() {
    print('🔧 Setting up socket listeners...');

    // Cancel existing subscriptions if any
    _lockStatusSubscription?.cancel();
    _connectionStatusSubscription?.cancel();

    // Set up lock status listener
    _lockStatusSubscription = _socketRepository.lockStatusStream.listen((
      locked,
    ) {
      print('🔒🔒🔒 LOCK STATUS CHANGED IN VIEWMODEL: $locked');
      print('   Previous lock status: $_isLocked');
      _isLocked = locked;
      print('   New lock status: $_isLocked');
      if (locked) {
        // Reset to home screen when locked
        _currentIndex = 0;
        print('   📱 Reset to home screen (index 0)');
        // Notify Android native code about lock status
        _notifyAndroidLockStatus(locked);
        print('   📲 Notified Android: locked=true');
      } else {
        // Notify Android when unlocked
        _notifyAndroidLockStatus(locked);
        print('   📲 Notified Android: locked=false');
      }
      print('   🔔 Calling notifyListeners()...');
      notifyListeners();
      print(
        '   ✅ notifyListeners() called. isLocked getter will return: $_isLocked',
      );
    });
    print('   ✅ Lock status subscription created');

    // Set up connection status listener
    _connectionStatusSubscription = _socketRepository.connectionStatusStream
        .listen((connected) {
          _isConnected = connected;
          if (connected) {
            _startPeriodicStatusUpdates();
          } else {
            _stopPeriodicStatusUpdates();
          }
          notifyListeners();
        });
    print('   ✅ Connection status subscription created');
  }

  void _startPeriodicStatusUpdates() {
    _stopPeriodicStatusUpdates(); // Stop any existing timer

    // Send initial status
    _sendStatusUpdate();

    // Send status updates every 30 seconds
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_isConnected && !_isLocked) {
        _sendStatusUpdate();
      }
    });
  }

  void _stopPeriodicStatusUpdates() {
    _statusUpdateTimer?.cancel();
    _statusUpdateTimer = null;
  }

  void _sendStatusUpdate() {
    if (_isConnected) {
      _socketRepository.sendStatusUpdate({
        'status': _isLocked ? 'locked' : 'active',
        'battery': 100, // You can add battery level detection here
        'lastActive': DateTime.now().toIso8601String(),
        'appState': 'foreground',
      });
    }
  }

  UserProgress get progress => _progress;
  bool get isLocked => _isLocked;
  bool get isConnected => _isConnected;
  int get currentIndex => _currentIndex;

  Future<void> collectStar() async {
    if (!_isLocked) {
      await _collectStarUseCase.execute();
    }
  }

  void navigateTo(int index) {
    if (!_isLocked) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void openParentGatekeeper() {
    if (!_isLocked) {
      _currentIndex = 4;
      notifyListeners();
    }
  }

  void requestUnlock({String? reason}) {
    _socketRepository.requestUnlock(reason: reason);
  }

  /// Unlocks the device if the correct PIN is provided
  /// Returns true if unlock was successful, false otherwise
  bool unlock(String pin) {
    if (pin == '1234') {
      _isLocked = false;
      // Notify Android when unlocked
      _notifyAndroidLockStatus(false);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Notify Android native code about lock status
  void _notifyAndroidLockStatus(bool locked) {
    const platform = MethodChannel('com.example.child_tinywiz/lock');
    try {
      platform.invokeMethod('setLocked', locked);
    } catch (e) {
      // Ignore errors if method channel is not available (e.g., on iOS)
      if (kDebugMode) {
        print('Failed to notify Android lock status: $e');
      }
    }
  }

  @override
  void dispose() {
    _stopPeriodicStatusUpdates();
    _lockStatusSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    super.dispose();
  }
}
