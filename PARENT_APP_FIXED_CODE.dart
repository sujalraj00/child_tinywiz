// ============================================
// FIXED PARENT APP CODE
// ============================================

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// ============================================
// Socket Service Base (Keep as is)
// ============================================
class SocketServiceBase {
  IO.Socket? _socket;
  bool _isConnected = false;

  Function()? onConnected;
  Function(String)? onError;
  Function(String)? onDisconnected;

  Future<bool> connect(String deviceId, {String? serverUrl}) async {
    try {
      final String url = serverUrl ?? 'http://192.168.1.13:3200';

      print('🔄 Connecting to: $url');

      _socket = IO.io(
        url,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setTimeout(5000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('✅ Connected to server');
        _isConnected = true;
        onConnected?.call();
      });

      _socket!.onDisconnect((_) {
        print('❌ Disconnected from server');
        _isConnected = false;
        onDisconnected?.call('Disconnected');
      });

      _socket!.onError((error) {
        print('🚨 Socket error: $error');
        _isConnected = false;
        onError?.call(error.toString());
      });

      _socket!.on('connected', (data) {
        print('🔗 Server connection confirmed: $data');
      });

      _socket!.connect();
      await Future.delayed(Duration(seconds: 2));
      return _isConnected;
    } catch (e) {
      print('💥 Connection failed: $e');
      onError?.call(e.toString());
      return false;
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
  }

  bool get isConnected => _isConnected;

  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket!.emit(event, data);
    } else {
      print('⚠️ Cannot emit $event - not connected');
    }
  }

  // Add method to listen to events
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }
}

// ============================================
// ENHANCED Parent Socket Service
// ============================================
class ParentSocketService extends SocketServiceBase {
  String? _parentId;
  String? _childId;

  // Callbacks for parent app
  Function(bool)? onLockStatusChanged;
  Function(Map<String, dynamic>)? onChildStatusUpdate;
  Function(Map<String, dynamic>)? onLockAcknowledged;
  Function(String)? onLockError;

  static final ParentSocketService _instance = ParentSocketService._internal();
  factory ParentSocketService() => _instance;
  ParentSocketService._internal();

  Future<bool> connectAsParent(
    String parentId,
    String childId, {
    String? serverUrl,
  }) async {
    _parentId = parentId;
    _childId = childId;

    final connected = await connect(parentId, serverUrl: serverUrl);

    if (connected) {
      // Register as parent after connection
      emit('register_parent', {'parentId': parentId, 'childId': childId});

      // Set up event listeners
      _setupEventListeners();
    }

    return connected;
  }

  void _setupEventListeners() {
    // Listen for registration confirmation
    on('parent_registered', (data) {
      print('✅ Parent registration confirmed: $data');
    });

    // Listen for lock command confirmation from server
    on('lock_command_sent', (data) {
      print('📤 Lock command response: $data');

      if (data['success'] == true) {
        // Server successfully sent command to child
        print('✅ Lock command sent to child');
      } else {
        // Failed to send (child not connected, etc.)
        print('❌ Failed to send lock command: ${data['error']}');
        onLockError?.call(data['error'] ?? 'Unknown error');
      }
    });

    // Listen for child's acknowledgment
    on('lock_acknowledged', (data) {
      print('✅ Child acknowledged lock: $data');
      final bool locked = data['locked'] ?? false;
      onLockAcknowledged?.call(data);
      onLockStatusChanged?.call(locked);
    });

    // Listen for child status updates
    on('child_status', (data) {
      print('📊 Child status update: $data');
      onChildStatusUpdate?.call(data);
    });

    // Listen for emergency alerts
    on('child_emergency', (data) {
      print('🚨 Emergency alert from child: $data');
      // Handle emergency - show alert, notification, etc.
    });

    // Listen for unlock requests
    on('unlock_request_received', (data) {
      print('🔓 Child requesting unlock: $data');
      // Show dialog to parent asking if they want to unlock
    });
  }

  void lockChildPhone(bool lock) {
    if (isConnected) {
      print('🔒 Sending lock command: $lock');
      emit('lock_child_phone', {
        'parentId': _parentId,
        'childId': _childId,
        'lock': lock,
      });
    } else {
      print('⚠️ Not connected - cannot send lock command');
      onLockError?.call('Not connected to server');
    }
  }
}

// ============================================
// ENHANCED Parent Dashboard
// ============================================
class ParentDashboard extends StatefulWidget {
  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;
  final ParentSocketService _socketService = ParentSocketService();
  bool _isChildLocked = false;
  bool _isConnected = false;
  Map<String, dynamic>? _childStatus;

  @override
  void initState() {
    super.initState();
    _setupSocketCallbacks();
    _socketService.connectAsParent(
      'parent123',
      'child456',
      serverUrl: 'http://192.168.1.13:3200',
    );
  }

  void _setupSocketCallbacks() {
    // Update lock status when child acknowledges
    _socketService.onLockStatusChanged = (bool locked) {
      setState(() {
        _isChildLocked = locked;
      });
    };

    // Handle child status updates
    _socketService.onChildStatusUpdate = (Map<String, dynamic> status) {
      setState(() {
        _childStatus = status;
      });
    };

    // Handle lock acknowledgment
    _socketService.onLockAcknowledged = (Map<String, dynamic> data) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Child ${data['locked'] ? 'locked' : 'unlocked'} successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    };

    // Handle lock errors
    _socketService.onLockError = (String error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lock command failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
      // Revert state if command failed
      setState(() {
        _isChildLocked = !_isChildLocked;
      });
    };

    // Connection status callbacks
    _socketService.onConnected = () {
      setState(() {
        _isConnected = true;
      });
    };

    _socketService.onDisconnected = (String reason) {
      setState(() {
        _isConnected = false;
      });
    };
  }

  void _toggleChildPhoneLock() {
    // Optimistically update UI
    setState(() {
      _isChildLocked = !_isChildLocked;
    });

    // Send command to server
    _socketService.lockChildPhone(_isChildLocked);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, Aastha!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[800],
            ),
          ),
          Row(
            children: [
              // Connection status indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
              SizedBox(width: 8),
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepPurple[200],
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.deepPurple[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.deepPurple[700],
      unselectedItemColor: Colors.deepPurple[300],
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Setup',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.bar_chart_outlined),
              label: Text('View Full Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[50],
                foregroundColor: Colors.deepPurple[800],
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isConnected ? _toggleChildPhoneLock : null,
              icon: Icon(_isChildLocked ? Icons.lock_open : Icons.lock_outline),
              label: Text(
                _isChildLocked ? 'Unlock Child Phone' : 'Lock Child Phone',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[700],
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add child status card widget
  Widget buildChildStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Child Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isChildLocked ? Icons.lock : Icons.lock_open,
                  color: _isChildLocked ? Colors.red : Colors.green,
                ),
                SizedBox(width: 8),
                Text(
                  _isChildLocked ? 'Phone Locked' : 'Phone Unlocked',
                  style: TextStyle(
                    fontSize: 16,
                    color: _isChildLocked ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            if (_childStatus != null) ...[
              SizedBox(height: 8),
              Text('Status: ${_childStatus!['status']}'),
              Text('Battery: ${_childStatus!['battery']}%'),
            ],
          ],
        ),
      ),
    );
  }

  // Placeholder widgets (implement these based on your needs)
  Widget buildKeyMetrics() {
    return Container(); // Your implementation
  }

  Widget buildDailySchedule() {
    return Container(); // Your implementation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              buildChildStatusCard(),
              buildKeyMetrics(),
              _buildQuickActions(),
              buildDailySchedule(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}

// Extension method to darken a color
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
