class AppConstants {
  static const String appName = 'TinyWiz';
  static const String defaultChildName = 'Nitin';
  static const int totalStars = 5;
  static const String defaultPin = '1234';
  // Use your hosted server URL below once deployed (e.g. 'https://tinywiz-server.onrender.com')
  // String.fromEnvironment allows passing the URL at build time: --dart-define=SERVER_URL=...
  static const String defaultServerUrl = String.fromEnvironment(
    'SERVER_URL',
    defaultValue: 'https://child-tinywiz.onrender.com',
  );

  static const String defaultChildId = 'child456';
  static const String fontFamily = 'Cera Pro';

  // Colors
  static const int primaryColorValue = 0xFF6C63FF; // Modern indigo/purple
  static const int deepPurpleValue = 0xFF8A2BE2; // Vibrant purple
  static const int greenValue = 0xFF00E676; // Bright green
  static const int orangeValue = 0xFFFF9100; // Deep orange
  static const int pinkValue = 0xFFFF4081; // Pink accent
}
