// // import 'package:socket_io_client/socket_io_client.dart' as IO;

// // class ChildSocketService {
// //   IO.Socket? _socket;
// //   String? _childId;

// //   // Callback for lock status changes
// //   Function(bool)? onLockStatusChanged;

// //   static final ChildSocketService _instance = ChildSocketService._internal();
// //   factory ChildSocketService() => _instance;
// //   ChildSocketService._internal();

// //   void connect(String serverUrl, String childId) {
// //     _childId = childId;

// //     // _socket = IO.io(serverUrl, <String, dynamic>{
// //     //   'transports': ['websocket'],
// //     //   'autoConnect': true,
// //     // });
// //     final String url = serverUrl ?? 'http://192.168.1.13:3200'; // ← UPDATE THIS

// //     print('🔄 Connecting to: $url');

// //     _socket = IO.io(
// //       url,
// //       IO.OptionBuilder()
// //           .setTransports(['websocket', 'polling']) // Fallback transport
// //           .enableAutoConnect()
// //           .setTimeout(5000)
// //           .build(),
// //     );

// //     _socket!.onConnect((_) {
// //       print('Child connected to server');
// //       // Register as child
// //       _socket!.emit('register_child', {'childId': childId});
// //     });

// //     _socket!.onDisconnect((_) => print('Child disconnected'));
// //     _socket!.onError((error) => print('Socket error: $error'));

// //     // Listen for lock commands from parent
// //     _socket!.on('phone_lock_status', (data) {
// //       print('Received lock command: $data');
// //       final bool locked = data['locked'] ?? false;
// //       onLockStatusChanged?.call(locked);
// //     });
// //   }

// //   void sendStatusUpdate(Map<String, dynamic> status) {
// //     if (_socket != null && _socket!.connected) {
// //       _socket!.emit('child_status_update', {'childId': _childId, ...status});
// //     }
// //   }

// //   void disconnect() {
// //     _socket?.disconnect();
// //     _socket = null;
// //   }

// //   bool get isConnected => _socket?.connected ?? false;
// // }

// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class ChildSocketService {
//   IO.Socket? _socket;
//   String? _childId;
//   bool _isConnected = false;

//   // Connection callbacks
//   Function()? onConnected;
//   Function(String)? onError;
//   Function(String)? onDisconnected;

//   // App-specific callbacks
//   Function(bool)? onLockStatusChanged;
//   Function(Map<String, dynamic>)? onParentCommand;

//   static final ChildSocketService _instance = ChildSocketService._internal();
//   factory ChildSocketService() => _instance;
//   ChildSocketService._internal();

//   Future<bool> connect(String childId, {String? serverUrl}) async {
//     try {
//       _childId = childId;

//       // Use provided URL or default to your local network IP
//       final String url =
//           serverUrl ?? 'http://192.168.1.13:3200'; // ← UPDATE THIS IP

//       print('🔄 Child connecting to: $url');

//       _socket = IO.io(
//         url,
//         IO.OptionBuilder()
//             .setTransports(['websocket', 'polling'])
//             .enableAutoConnect()
//             .setTimeout(5000)
//             //.disableAutoReconnect() // We'll handle reconnection manually
//             .build(),
//       );

//       _setupEventListeners();
//       _socket!.connect();

//       // Wait for connection with timeout
//       await Future.delayed(Duration(seconds: 2));
//       return _isConnected;
//     } catch (e) {
//       print('💥 Child connection failed: $e');
//       onError?.call(e.toString());
//       return false;
//     }
//   }

//   void _setupEventListeners() {
//     // Connection events
//     _socket!.onConnect((_) {
//       print('✅ Child connected to server');
//       _isConnected = true;
//       _registerChild();
//       onConnected?.call();
//     });

//     _socket!.onDisconnect((_) {
//       print('❌ Child disconnected from server');
//       _isConnected = false;
//       onDisconnected?.call('Disconnected');
//     });

//     _socket!.onError((error) {
//       print('🚨 Child socket error: $error');
//       _isConnected = false;
//       onError?.call(error.toString());
//     });

//     _socket!.on('connected', (data) {
//       print('🔗 Child server connection confirmed: $data');
//     });

//     // App-specific events
//     _socket!.on('phone_lock_status', (data) {
//       print('📱 Received lock command: $data');
//       final bool locked = data['locked'] ?? false;
//       final String timestamp = data['timestamp'] ?? '';

//       onLockStatusChanged?.call(locked);

//       // Send acknowledgment back to parent
//       sendLockAcknowledgment(locked, timestamp);
//     });

//     _socket!.on('parent_command', (data) {
//       print('📨 Received parent command: $data');
//       onParentCommand?.call(Map<String, dynamic>.from(data));
//     });

//     _socket!.on('lock_acknowledged', (data) {
//       print('✅ Lock acknowledgment received by parent: $data');
//     });
//   }

//   void _registerChild() {
//     if (_childId != null && _isConnected) {
//       _socket!.emit('register_child', {
//         'childId': _childId,
//         'deviceInfo': {
//           'platform': 'flutter',
//           'timestamp': DateTime.now().toIso8601String(),
//         },
//       });
//       print('👶 Child registered: $_childId');
//     }
//   }

//   void sendLockAcknowledgment(bool locked, String timestamp) {
//     if (_isConnected) {
//       _socket!.emit('lock_acknowledgment', {
//         'childId': _childId,
//         'locked': locked,
//         'commandTimestamp': timestamp,
//         'acknowledgedAt': DateTime.now().toIso8601String(),
//       });
//       print('✅ Lock acknowledgment sent: $locked');
//     }
//   }

//   void sendStatusUpdate(Map<String, dynamic> status) {
//     if (_isConnected) {
//       _socket!.emit('child_status_update', {
//         'childId': _childId,
//         'status': status['status'] ?? 'active',
//         'battery': status['battery'] ?? 100,
//         'lastActive': status['lastActive'] ?? DateTime.now().toIso8601String(),
//         'appState': status['appState'] ?? 'foreground',
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//     }
//   }

//   void sendEmergencyAlert({String? reason}) {
//     if (_isConnected) {
//       _socket!.emit('child_emergency_alert', {
//         'childId': _childId,
//         'reason': reason ?? 'Emergency help needed',
//         'location': 'Unknown', // You can add location services here
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//       print('🚨 Emergency alert sent');
//     }
//   }

//   void requestUnlock({String? reason}) {
//     if (_isConnected) {
//       _socket!.emit('unlock_request', {
//         'childId': _childId,
//         'reason': reason ?? 'Requesting unlock',
//         'requestedAt': DateTime.now().toIso8601String(),
//       });
//       print('🔓 Unlock request sent');
//     }
//   }

//   void disconnect() {
//     print('👋 Child disconnecting...');
//     _socket?.disconnect();
//     _socket?.destroy();
//     _socket = null;
//     _isConnected = false;
//   }

//   // Manual reconnection
//   Future<bool> reconnect() async {
//     if (_childId != null) {
//       disconnect();
//       await Future.delayed(Duration(seconds: 2));
//       return connect(_childId!);
//     }
//     return false;
//   }

//   bool get isConnected => _isConnected;
//   String? get childId => _childId;
// }
