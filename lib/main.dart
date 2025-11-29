import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/story_time_viewmodel.dart';
import 'presentation/viewmodels/parent_gatekeeper_viewmodel.dart';
import 'presentation/views/home/home_screen.dart';
import 'presentation/views/story_time/story_time_screen.dart';
import 'presentation/views/parent_gatekeeper/parent_gatekeeper_screen.dart';
import 'presentation/views/activity/activity_screen.dart';
import 'presentation/views/lock/lock_screen.dart';

void main() {
  runApp(TinyWizApp());
}

class TinyWizApp extends StatelessWidget {
  const TinyWizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  MainNavigatorState createState() => MainNavigatorState();
}

class MainNavigatorState extends State<MainNavigator> {
  late final HomeViewModel _homeViewModel;
  late final StoryTimeViewModel _storyTimeViewModel;
  late final ParentGatekeeperViewModel _parentGatekeeperViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = ServiceLocator.homeViewModel;
    _storyTimeViewModel = ServiceLocator.storyTimeViewModel;
    _parentGatekeeperViewModel = ServiceLocator.parentGatekeeperViewModel;

    // Initialize socket connection
    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    await _homeViewModel.initializeSocket(
      AppConstants.defaultChildId,
      serverUrl: AppConstants.defaultServerUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _homeViewModel,
      builder: (context, _) {
        final isLocked = _homeViewModel.isLocked;
        print('🏗️ MainNavigator build() - isLocked: $isLocked');

        // Show lock screen if device is locked - wrap in PopScope to block all navigation
        if (isLocked) {
          print('🔒🔒🔒 SHOWING LOCK SCREEN 🔒🔒🔒');
          return PopScope(
            canPop: false,
            child: LockScreen(viewModel: _homeViewModel),
          );
        }

        print('✅ App is unlocked, showing normal screen');

        // Show appropriate screen based on current index
        Widget screen;
        switch (_homeViewModel.currentIndex) {
          case 0:
            screen = HomeScreen(viewModel: _homeViewModel);
            break;
          case 1:
            screen = StoryTimeScreen(
              viewModel: _storyTimeViewModel,
              onBack: () => _homeViewModel.navigateTo(0),
            );
            break;
          case 2:
            screen = ActivityScreen(
              title: 'Fun Quiz',
              icon: Icons.star_rounded,
              color: Color(0xFFFF9800),
              onBack: () => _homeViewModel.navigateTo(0),
            );
            break;
          case 3:
            screen = ActivityScreen(
              title: 'Sing Along',
              icon: Icons.music_note_rounded,
              color: Color(0xFFE91E63),
              onBack: () => _homeViewModel.navigateTo(0),
            );
            break;
          case 4:
            screen = ParentGatekeeperScreen(
              viewModel: _parentGatekeeperViewModel,
              onBack: () => _homeViewModel.navigateTo(0),
              onUnlock: () => _homeViewModel.navigateTo(0),
            );
            break;
          default:
            screen = HomeScreen(viewModel: _homeViewModel);
        }

        return AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: screen,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    _storyTimeViewModel.dispose();
    _parentGatekeeperViewModel.dispose();
    ServiceLocator.dispose();
    super.dispose();
  }
}
