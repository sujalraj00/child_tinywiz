import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../../core/constants/app_constants.dart';

class LockScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const LockScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  void initState() {
    super.initState();
    print('🔒🔒🔒 LockScreen initState() called');
    // Hide system UI (status bar and navigation bars) when locked
    _hideSystemUI();
    print('🔒🔒🔒 System UI hidden');
  }

  @override
  void dispose() {
    // Restore system UI when screen is disposed (unlocked)
    _showSystemUI();
    super.dispose();
  }

  void _hideSystemUI() {
    // Hide system UI bars completely - immersive fullscreen mode
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    // Set system UI overlay style to match lock screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _showSystemUI() {
    // Restore system UI when unlocked
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🔒🔒🔒 LockScreen build() called');
    // Listen to lock status changes
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final isLocked = widget.viewModel.isLocked;
        print('🔒🔒🔒 LockScreen builder - isLocked: $isLocked');
        
        // If unlocked, restore system UI
        if (!isLocked) {
          print('🔒🔒🔒 LockScreen: Device unlocked, restoring system UI');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSystemUI();
          });
        }
        
        print('🔒🔒🔒 LockScreen: Building lock screen UI');
        // Block all system navigation (back button, home button, etc.)
        return PopScope(
          canPop: false,
          child: GestureDetector(
            // Block all gestures that might trigger navigation
            onTap: () {},
            onPanStart: (_) {},
            onPanUpdate: (_) {},
            onPanEnd: (_) {},
            child: Container(
              // Full screen container that covers everything including system bars
              width: double.infinity,
              height: double.infinity,
              color: Colors.red[900],
              child: SafeArea(
                // SafeArea ensures content doesn't overlap with notches, but we want fullscreen
                top: false,
                bottom: false,
                left: false,
                right: false,
                child: ScreenLock(
                  correctString: '1234',
                  title: _buildTitle(),
                  onUnlocked: () {
                    // Unlock successful - this is called when correct PIN is entered
                    widget.viewModel.unlock('1234');
                    HapticFeedback.lightImpact();
                    // Restore system UI after unlock
                    _showSystemUI();
                  },
                  config: ScreenLockConfig(
                    backgroundColor: Colors.red[900]!,
                  ),
                  footer: _buildFooter(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Column(
          children: [
            // Lock Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            // Title Text
            Text(
              'Phone Locked',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'by Parent',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 24),
            // Connection Status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.viewModel.isConnected
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.viewModel.isConnected
                        ? 'Connected to Parent'
                        : 'Disconnected',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Enter PIN to Unlock',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        if (widget.viewModel.isConnected) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: TextButton.icon(
              onPressed: () {
                _showUnlockRequestDialog(context);
              },
              icon: Icon(Icons.lock_open, color: Colors.white),
              label: Text(
                'Request Unlock from Parent',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  void _showUnlockRequestDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Request Unlock',
          style: TextStyle(fontFamily: AppConstants.fontFamily),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send a request to parent to unlock your phone.',
              style: TextStyle(fontFamily: AppConstants.fontFamily),
            ),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g., Need to call someone',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.viewModel.requestUnlock(
                reason: reasonController.text.isEmpty
                    ? null
                    : reasonController.text,
              );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unlock request sent to parent'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
