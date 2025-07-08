import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app_absen_rida/screens/home_screen.dart';
import 'package:app_absen_rida/screens/login_screen.dart';
import 'package:app_absen_rida/screens/register_screen.dart';
import 'package:app_absen_rida/screens/history_screen.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/services/auth_repository.dart';
import 'package:app_absen_rida/models/api_model.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final sharedPreferences = await SharedPreferences.getInstance();
  final apiService = ApiService();
  final authRepository = AuthRepository(
    apiService: apiService,
    sharedPreferences: sharedPreferences,
  );

  runApp(MyApp(apiService: apiService, authRepository: authRepository));
}

class MyApp extends StatefulWidget {
  final ApiService apiService;
  final AuthRepository authRepository;

  const MyApp({
    super.key,
    required this.apiService,
    required this.authRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? _currentUser;
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _onLogout() {
    setState(() {
      _currentUser = null;
    });
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _updateUserProfile(User user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Absensi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder:
                  (_) => LoginScreen(
                    apiService: widget.apiService,
                    authRepository: widget.authRepository,
                    onLoginSuccess: (user) {
                      setState(() => _currentUser = user);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(context, '/home');
                      });
                    },
                  ),
            );
          case '/register':
            return MaterialPageRoute(
              builder:
                  (_) => RegisterScreen(
                    apiService: widget.apiService,
                    authRepository: widget.authRepository,
                   onRegisterSuccess: (user) {
  setState(() => _currentUser = user);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Navigator.pushReplacementNamed(context, '/login');
  });
},

                  ),
            );
          case '/home':
            if (_currentUser == null) {
              // Jika user belum login, redirect ke login
              return MaterialPageRoute(
                builder:
                    (_) => LoginScreen(
                      apiService: widget.apiService,
                      authRepository: widget.authRepository,
                      onLoginSuccess: (user) {
                        setState(() => _currentUser = user);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushReplacementNamed(context, '/home');
                        });
                      },
                    ),
              );
            }
            return MaterialPageRoute(
              builder:
                  (_) => HomeScreen(
                    apiService: widget.apiService,
                    currentUser: _currentUser!,
                    updateUserProfile: _updateUserProfile,
                    onLogout: _onLogout,
                    toggleTheme: _toggleTheme,
                    currentThemeMode: _themeMode,
                  ),
            );
          case '/history':
            return MaterialPageRoute(
              builder: (_) => HistoryScreen(apiService: widget.apiService),
            );
          default:
            return null;
        }
      },
    );
  }
}
