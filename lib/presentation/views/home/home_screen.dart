import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildConnectionStatus(),
                        _buildExitButton(context),
                      ],
                    ),
                    FadeInDown(child: _buildAvatar()),
                    FadeInUp(child: _buildGreeting()),
                    ZoomIn(child: _buildActivityMenu()),
                    FadeInUp(child: _buildProgressBar()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isConnected ? Color(AppConstants.greenValue) : Colors.redAccent,
              boxShadow: [
                BoxShadow(
                  color: (viewModel.isConnected ? Color(AppConstants.greenValue) : Colors.redAccent).withOpacity(0.5),
                  blurRadius: 4,
                )
              ],
            ),
          ),
          SizedBox(width: 8),
          Text(
            viewModel.isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return GestureDetector(
      onTap: () => viewModel.openParentGatekeeper(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.lock_rounded, color: Color(AppConstants.primaryColorValue), size: 22),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(AppConstants.primaryColorValue), Color(AppConstants.deepPurpleValue)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(AppConstants.primaryColorValue).withOpacity(0.4),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 5),
      ),
      child: Stack(
        children: [
          Center(child: Icon(Icons.child_care_rounded, size: 80, color: Colors.white)),
          Positioned(
            bottom: 4,
            right: 12,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(AppConstants.greenValue),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      children: [
        Text(
          'Hello, ${AppConstants.defaultChildName}!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: AppConstants.fontFamily,
            shadows: [
              Shadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Ready to play?',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.9),
            fontFamily: AppConstants.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActivityButton(
          icon: Icons.menu_book_rounded,
          label: 'Story Time',
          color: Color(AppConstants.greenValue),
          size: 90,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(1);
          },
        ),
        _buildActivityButton(
          icon: Icons.chat_bubble_rounded,
          label: 'Smart AI',
          color: Color(AppConstants.orangeValue),
          size: 90,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(2);
          },
        ),
        _buildActivityButton(
          icon: Icons.bar_chart_rounded,
          label: 'Usage Stats',
          color: Color(AppConstants.pinkValue),
          size: 90,
          onTap: () {
            viewModel.collectStar();
            viewModel.navigateTo(3);
          },
        ),
      ],
    );
  }

  Widget _buildActivityButton({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 4),
            ),
            child: Icon(icon, size: size * 0.45, color: Colors.white),
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = viewModel.progress;
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Today\'s stars: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
                SizedBox(width: 10),
                Row(
                  children: List.generate(progress.totalStars, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        index < progress.collectedStars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: index < progress.collectedStars
                            ? Colors.amberAccent
                            : Colors.white.withOpacity(0.5),
                        size: 32,
                        shadows: index < progress.collectedStars
                            ? [Shadow(color: Colors.orangeAccent, blurRadius: 8)]
                            : [],
                      ),
                    );
                  }),
                ),
                SizedBox(width: 12),
                if (progress.collectedStars < progress.totalStars)
                  GestureDetector(
                    onTap: () => viewModel.collectStar(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(AppConstants.primaryColorValue),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
