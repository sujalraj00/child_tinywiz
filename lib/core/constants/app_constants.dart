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
  static const String fontFamily = 'ComicNeue';

  // Colors
  static const int primaryColorValue = 0xFF4A148C;
  static const int deepPurpleValue = 0xFF673AB7;
  static const int greenValue = 0xFF4CAF50;
  static const int orangeValue = 0xFFFF9800;
  static const int pinkValue = 0xFFE91E63;
}
