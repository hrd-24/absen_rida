// lib/utils/constants.dart
class Constants {
  // BASE_URL tidak lagi diperlukan di sini karena sudah ada di ApiService
  static const String AUTH_TOKEN_KEY = 'authToken'; // Masih digunakan untuk persistensi token di SharedPreferences
  static const String USER_ID_KEY = 'userId';
  static const String USER_NAME_KEY = 'userName';
  static const String USER_EMAIL_KEY = 'userEmail';
  static const String THEME_MODE_KEY = 'themeMode';
}
