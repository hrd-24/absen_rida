// import 'package:app_absen_rida/models/api_model.dart';
// import 'package:app_absen_rida/services/api_services.dart';
// import 'package:app_absen_rida/services/auth_repository.dart';
// import 'package:app_absen_rida/utils/constatns.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dashboard_screen.dart';
// import 'login_screen.dart';

// // lib/screens/splash_screen.dart
// class SplashScreen extends StatefulWidget {
//   final AuthRepository authRepository;
//   final SharedPreferences sharedPreferences;
//   final ApiService apiService;

//   const SplashScreen({
//     super.key,
//     required this.authRepository,
//     required this.sharedPreferences,
//     required this.apiService,
//   });

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   User? _currentUser;
//   bool _isLoggedIn = false;
//   ThemeMode _themeMode = ThemeMode.system;

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     // Muat token saat aplikasi dimulai ke ApiService
//     await widget.authRepository.loadAuthToken();

//     // Periksa status login
//     setState(() {
//       _isLoggedIn = widget.authRepository.isLoggedIn();
//       _currentUser = widget.authRepository.getUserData();
//     });

//     // Muat preferensi tema
//     final themeString = widget.sharedPreferences.getString(
//       Constants.THEME_MODE_KEY,
//     );
//     setState(() {
//       if (themeString == 'dark') {
//         _themeMode = ThemeMode.dark;
//       } else if (themeString == 'light') {
//         _themeMode = ThemeMode.light;
//       } else {
//         _themeMode = ThemeMode.system;
//       }
//     });

//     // Setelah inisialisasi, arahkan ke layar yang sesuai
//     if (_isLoggedIn && _currentUser != null) {
//       // Tunggu sebentar untuk efek splash
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder:
//                 (context) => DashboardScreen(
//                   apiService: widget.apiService,
//                   currentUser: _currentUser!,
//                   onLogout: _onLogout,
//                   toggleTheme: _toggleTheme,
//                   currentThemeMode: _themeMode,
//                   updateUserProfile: _updateUserProfile,
//                 ),
//           ),
//         );
//       }
//     } else {
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) {
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder:
//                 (context) => LoginScreen(
//                   apiService: widget.apiService,
//                   authRepository: widget.authRepository,
//                   onLoginSuccess: _onLoginSuccess,
//                 ),
//           ),
//         );
//       }
//     }
//   }

//   // Callback untuk login berhasil (dari LoginScreen/RegisterScreen)
//   void _onLoginSuccess(User user) {
//     setState(() {
//       _currentUser = user;
//       _isLoggedIn = true;
//     });
//     // Setelah login, arahkan ke dashboard
//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder:
//               (context) => DashboardScreen(
//                 apiService: widget.apiService,
//                 currentUser: _currentUser!,
//                 onLogout: _onLogout,
//                 toggleTheme: _toggleTheme,
//                 currentThemeMode: _themeMode,
//                 updateUserProfile: _updateUserProfile,
//               ),
//         ),
//       );
//     }
//   }

//   // Callback untuk logout (dari DashboardScreen/ProfileScreen)
//   void _onLogout() async {
//     await widget.authRepository.logout();
//     setState(() {
//       _currentUser = null;
//       _isLoggedIn = false;
//     });
//     // Setelah logout, arahkan ke login
//     if (mounted) {
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder:
//               (context) => LoginScreen(
//                 apiService: widget.apiService,
//                 authRepository: widget.authRepository,
//                 onLoginSuccess: _onLoginSuccess,
//               ),
//         ),
//         (Route<dynamic> route) => false,
//       );
//     }
//   }

//   // Callback untuk mengubah tema (dari DashboardScreen)
//   Future<void> _toggleTheme(bool isDarkMode) async {
//     setState(() {
//       _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
//     });
//     await widget.sharedPreferences.setString(
//       Constants.THEME_MODE_KEY,
//       isDarkMode ? 'dark' : 'light',
//     );
//   }

//   // Callback untuk memperbarui profil pengguna (dari ProfileScreen)
//   void _updateUserProfile(User updatedUser) {
//     setState(() {
//       _currentUser = updatedUser;
//     });
//     widget.authRepository.saveUserData(
//       updatedUser,
//     ); // Pastikan data di SharedPreferences juga terupdate
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Tampilkan indikator loading atau logo splash screen
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             Text('Memuat Aplikasi...'),
//           ],
//         ),
//       ),
//     );
//   }
// }
