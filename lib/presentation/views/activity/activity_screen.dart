import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class ActivityScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onBack;

  const ActivityScreen({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text(title, style: TextStyle(fontFamily: AppConstants.fontFamily)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: color),
            SizedBox(height: 20),
            Text(
              '$title Screen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This is a placeholder for the $title activity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

