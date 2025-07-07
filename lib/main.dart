import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/services/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart'; // Import SplashScreen
import 'screens/history_screen.dart'; // Import HistoryScreen
import 'screens/register_screen.dart'; // Import RegisterScreen
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Panggil inisialisasi data lokal untuk 'id_ID' di sini
  await initializeDateFormatting('id_ID', null);

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authRepository = AuthRepository(
    apiService: apiService,
    sharedPreferences: sharedPreferences,
  );

  runApp(
    MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // themeMode akan diatur oleh SplashScreen dan diteruskan ke layar anak
      // di sini kita tidak bisa langsung menggunakan _themeMode karena ini bukan StatefulWidget

      // Menggunakan SplashScreen sebagai home (rute awal)
      home: SplashScreen(
        authRepository: authRepository,
        sharedPreferences: sharedPreferences,
        apiService: apiService,
      ),
      // Named routes (opsional, karena navigasi utama akan dari SplashScreen)
      routes: {
        // '/login': (context) => LoginScreen(
        //   apiService: apiService,
        //   authRepository: authRepository,
        //   onLoginSuccess: (user) { /* Handled by SplashScreen's callback */ },
        // ),
        '/register':
            (context) => RegisterScreen(
              apiService: apiService,
              authRepository: authRepository,
              onRegisterSuccess: (user) {
                /* Handled by SplashScreen's callback */
              },
            ),
        // Dashboard, History, Profile akan di-push sebagai MaterialPageRoute dari SplashScreen
        // atau dari dalam layar itu sendiri jika navigasi bottom bar.
        // Tidak perlu didefinisikan di sini jika hanya diakses via push/pushReplacement
      },
      onGenerateRoute: (settings) {
        // Ini akan menangani rute yang membutuhkan argumen atau inisialisasi kompleks
        // atau rute yang tidak secara langsung didefinisikan di 'routes' map.
        // Penting: Pastikan semua callback yang diperlukan diteruskan.
        if (settings.name == '/dashboard') {
          // DashboardScreen membutuhkan currentUser, onLogout, toggleTheme, currentThemeMode, updateUserProfile
          // Ini harusnya datang dari SplashScreen setelah login.
          // Jika Navigator.pushNamed('/dashboard') dipanggil tanpa argumen, ini akan error.
          // Sebaiknya navigasi ke DashboardScreen selalu menggunakan MaterialPageRoute dari SplashScreen
          // atau dari layar yang memicu login/register.
          return null; // Biarkan SplashScreen yang mengarahkan ke Dashboard
        } else if (settings.name == '/history') {
          return MaterialPageRoute(
            builder: (context) => HistoryScreen(apiService: apiService),
          );
        } else if (settings.name == '/profile') {
          // ProfileScreen membutuhkan currentUser dan onUpdateUser
          // Ini juga harusnya datang dari SplashScreen setelah login.
          return null; // Biarkan SplashScreen yang mengarahkan ke Profile
        }
        return null;
      },
    ),
  );
}
