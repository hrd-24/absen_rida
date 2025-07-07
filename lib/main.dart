import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/services/auth_repository.dart';
import 'package:app_absen_rida/utils/constatns.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authRepository = AuthRepository(
    apiService: apiService,
    sharedPreferences: sharedPreferences,
  );

  // Muat token saat aplikasi dimulai
  await authRepository.loadAuthToken();

  runApp(
    MyApp(
      authRepository: authRepository,
      sharedPreferences: sharedPreferences,
      apiService: apiService,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepository authRepository;
  final SharedPreferences sharedPreferences;
  final ApiService apiService;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.sharedPreferences,
    required this.apiService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _currentUser;
  bool _isLoggedIn = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadThemeMode();
  }

  Future<void> _checkLoginStatus() async {
    setState(() {
      _isLoggedIn = widget.authRepository.isLoggedIn();
      _currentUser = widget.authRepository.getUserData();
    });
  }

  Future<void> _loadThemeMode() async {
    final themeString = widget.sharedPreferences.getString(
      Constants.THEME_MODE_KEY,
    );
    setState(() {
      if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeString == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  void _onLoginSuccess(User user) {
    setState(() {
      _currentUser = user;
      _isLoggedIn = true;
    });
  }

  void _onLogout() {
    // Panggil logout dari AuthRepository
    widget.authRepository.logout();
    setState(() {
      _currentUser = null;
      _isLoggedIn = false;
    });
  }

  Future<void> _toggleTheme(bool isDarkMode) async {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
    await widget.sharedPreferences.setString(
      Constants.THEME_MODE_KEY,
      isDarkMode ? 'dark' : 'light',
    );
  }

  void _updateUserProfile(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
    widget.authRepository.saveUserData(
      updatedUser,
    ); // Pastikan data di SharedPreferences juga terupdate
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      // Menggunakan home untuk rute awal berdasarkan status login
      home:
          _isLoggedIn
              ? DashboardScreen(
                apiService: widget.apiService,
                currentUser: _currentUser!,
                onLogout: _onLogout,
                toggleTheme: _toggleTheme,
                currentThemeMode: _themeMode,
                updateUserProfile: () {
                  _updateUserProfile(
                    _currentUser!,
                  ); // Panggil update user profile
                },
              )
              : LoginScreen(
                apiService: widget.apiService,
                authRepository: widget.authRepository,
                onLoginSuccess: _onLoginSuccess,
              ),
      // Rute bernama untuk navigasi antar layar
      routes: {
        '/register':
            (context) => RegisterScreen(
              apiService: widget.apiService,
              authRepository: widget.authRepository,
              onRegisterSuccess:
                  _onLoginSuccess, // Setelah register, langsung login dan update state
            ),
        // Rute untuk dashboard, history, dan profile akan dihandle oleh Navigator.push
        // karena mereka membutuhkan parameter (apiService, currentUser, dll.)
      },
      onGenerateRoute: (settings) {
        // Ini digunakan untuk rute yang membutuhkan argumen atau inisialisasi kompleks
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(
            builder:
                (context) => DashboardScreen(
                  apiService: widget.apiService,
                  currentUser: _currentUser!,
                  onLogout: _onLogout,
                  toggleTheme: _toggleTheme,
                  currentThemeMode: _themeMode,
                  updateUserProfile: () {},
                ),
          );
        } else if (settings.name == '/history') {
          return MaterialPageRoute(
            builder: (context) => HistoryScreen(apiService: widget.apiService),
          );
        } else if (settings.name == '/profile') {
          return MaterialPageRoute(
            builder:
                (context) => ProfileScreen(
                  apiService: widget.apiService,
                  currentUser: _currentUser!,
                  onUpdateUser: _updateUserProfile, // Pass callback
                ),
          );
        }
        return null; // Biarkan rute lain ditangani oleh routes: jika ada
      },
    );
  }
}
