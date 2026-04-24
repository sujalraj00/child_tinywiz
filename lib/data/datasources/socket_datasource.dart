import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../../core/constants/app_constants.dart';

class SocketDataSource {
  IO.Socket? _socket;
  String? _childId;
  bool _isConnected = false;
  String? _currentServerUrl;

  final _lockStatusController = StreamController<bool>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  Future<bool> connect(String childId, {String? serverUrl}) async {
    try {
      _childId = childId;
      final String url = serverUrl ?? AppConstants.defaultServerUrl;
      _currentServerUrl = url;

      print('🔄 Child connecting to: $url');
      print('🆔 Child ID: $childId');

      // SIMPLE APPROACH - Match parent app EXACTLY
      print('🔧 Creating socket...');
      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // EXACTLY like parent
            .enableAutoConnect() // EXACTLY like parent
            .setTimeout(5000) // EXACTLY like parent
            .build(),
      );

      // Setup event handlers (like parent app)
      _setupEventListeners();

      // Connect (parent app does this even with autoConnect)
      _socket!.connect();

      // Wait exactly like parent app (2 seconds)
      await Future.delayed(Duration(seconds: 2));

      return _isConnected;
    } catch (e) {
      print('💥 Connection failed: $e');
      return false;
    }
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      final socketId = _socket?.id ?? 'unknown';
      print('✅✅✅ CONNECTION ESTABLISHED ✅✅✅');
      print('🔗 Socket ID: $socketId');
      print('🌐 Server: $_currentServerUrl');
      print('📱 Child ID: $_childId');
      print('⏰ Connected at: ${DateTime.now().toIso8601String()}');
      print('───────────────────────────────────────────────────────');
      _isConnected = true;
      _connectionStatusController.add(true);
      // Register immediately after connection
      Future.delayed(Duration(milliseconds: 100), () {
        _registerChild();
      });
    });

    _socket!.onDisconnect((reason) {
      print('❌ DISCONNECTED FROM SERVER');
      print('📝 Reason: $reason');
      print('⏰ Disconnected at: ${DateTime.now().toIso8601String()}');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    _socket!.onError((error) {
      print('🚨🚨🚨 SOCKET ERROR 🚨🚨🚨');
      print('❌ Error Type: ${error.runtimeType}');
      print('❌ Error Details: $error');
      print('📋 Error String: ${error.toString()}');
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // CRITICAL: Listen for connect_error event (this is what fires on timeout)
    _socket!.on('connect_error', (error) {
      print('🚨🚨🚨 CONNECT_ERROR EVENT 🚨🚨🚨');
      print('❌ Error: $error');
      print('❌ Error Type: ${error.runtimeType}');
      if (error is Map) {
        print('❌ Error Map: $error');
      }
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    _socket!.on('connected', (data) {
      print('🔗 Server connection confirmed event received');
      print('   Data: $data');
      print('   Type: ${data.runtimeType}');
    });

    _socket!.on('child_registered', (data) {
      print('✅ Child registration confirmed: $data');
    });

    _socket!.on('phone_lock_status', (data) {
      final bool locked = data['locked'] ?? false;
      final String timestamp = data['timestamp'] ?? '';
      print('🔒🔒🔒 SOCKET: Received lock status event');
      print('   Data: $data');
      print('   Locked: $locked');
      print('   Timestamp: $timestamp');
      print('   Adding to stream controller...');
      _lockStatusController.add(locked);
      print('   ✅ Added to stream. Stream should notify listeners now.');
      sendLockAcknowledgment(locked, timestamp);
    });
  }

  void _registerChild() {
    if (_childId != null && _isConnected) {
      print('📝 Registering child: $_childId');
      final registrationData = {
        'childId': _childId,
        'deviceInfo': {
          'platform': 'flutter',
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
      print('📤 EMITTING EVENT');
      print('   Event: register_child');
      print('   Data: $registrationData');
      print('   Server: $_currentServerUrl');
      print('   Socket ID: ${_socket?.id ?? 'unknown'}');
      print('   Timestamp: ${DateTime.now().toIso8601String()}');
      _socket!.emit('register_child', registrationData);
      print('✅ Registration event emitted');
    } else {
      print('⚠️ Cannot register: childId=$_childId, connected=$_isConnected');
    }
  }

  void sendLockAcknowledgment(bool locked, String timestamp) {
    if (_isConnected) {
      _socket!.emit('lock_acknowledgment', {
        'childId': _childId,
        'locked': locked,
        'commandTimestamp': timestamp,
        'acknowledgedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  void sendStatusUpdate(Map<String, dynamic> status) {
    if (_isConnected) {
      _socket!.emit('child_status_update', {
        'childId': _childId,
        'status': status['status'] ?? 'active',
        'battery': status['battery'] ?? 100,
        'lastActive': status['lastActive'] ?? DateTime.now().toIso8601String(),
        'appState': status['appState'] ?? 'foreground',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void sendEmergencyAlert({String? reason}) {
    if (_isConnected) {
      _socket!.emit('child_emergency_alert', {
        'childId': _childId,
        'reason': reason ?? 'Emergency help needed',
        'location': 'Unknown',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void requestUnlock({String? reason}) {
    if (_isConnected) {
      _socket!.emit('unlock_request', {
        'childId': _childId,
        'reason': reason ?? 'Requesting unlock',
        'requestedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  void sendUsageStats(List<Map<String, dynamic>> usageStats) {
    if (_isConnected) {
      _socket!.emit('child_usage_stats', {
        'childId': _childId,
        'usageStats': usageStats,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('📊 Usage stats sent to server: ${usageStats.length} apps');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    _connectionStatusController.add(false);
  }

  Stream<bool> get lockStatusStream => _lockStatusController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  bool get isConnected => _isConnected;
  String? get childId => _childId;

  void dispose() {
    disconnect();
    _lockStatusController.close();
    _connectionStatusController.close();
  }
}
