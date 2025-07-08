// lib/screens/dashboard_screen.dart
import 'package:app_absen_rida/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';

class HomeScreen extends StatelessWidget {
  final ApiService apiService;
  final User currentUser;
  final VoidCallback onLogout;
  final Function(User) updateUserProfile;
  final Function(bool) toggleTheme;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.apiService,
    required this.currentUser,
    required this.updateUserProfile,
    required this.onLogout,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMMyyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => toggleTheme(currentThemeMode == ThemeMode.light),
        ),
        title: const Text('Dashboard Absensi'),
        centerTitle: true,
        actions: [PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'back') {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else if (value == 'history') {
      Navigator.of(context).pushNamed('/history');
   } else if (value == 'profile') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileScreen(
        apiService: apiService,
        currentUser: currentUser,
        onUpdateUser: updateUserProfile,
      ),
    ),
  );
}

  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'back',
      child: Row(
        children: [
          Icon(Icons.logout, size: 20), // ganti ikon jika perlu
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'history',
      child: Row(
        children: [
          Icon(Icons.history, size: 20),
          SizedBox(width: 8),
          Text('History Absensi'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'profile',
      child: Row(
        children: [
          Icon(Icons.person, size: 20),
          SizedBox(width: 8),
          Text('Profile'),
        ],
      ),
    ),
  ],
),

        ],
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${currentUser.name}!',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Tanggal Hari Ini: $today',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.login),
                            label: const Text('Absen Masuk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.logout),
                            label: const Text('Absen Pulang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Status Absensi Hari Ini:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada data absensi hari ini.'),
              ),
            ),
            const SizedBox(height: 20),
            Text('Statistik Absensi:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Belum ada statistik absensi.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
