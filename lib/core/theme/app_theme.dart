import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(AppConstants.primaryColorValue),
        primary: Color(AppConstants.primaryColorValue),
        secondary: Color(AppConstants.pinkValue),
        background: Color(0xFFF8F9FA),
        surface: Colors.white,
      ),
      fontFamily: AppConstants.fontFamily,
      scaffoldBackgroundColor: Color(0xFFF8F9FA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(AppConstants.primaryColorValue),
        iconTheme: IconThemeData(color: Color(AppConstants.primaryColorValue)),
        titleTextStyle: TextStyle(
          fontFamily: AppConstants.fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(AppConstants.primaryColorValue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: Color(AppConstants.primaryColorValue),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

