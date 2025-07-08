// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:app_absen_rida/services/api_services.dart';

class HistoryScreen extends StatelessWidget {
  final ApiService apiService;

  const HistoryScreen({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
      ),
      body: const Center(
        child: Text('Belum ada data riwayat.'),
      ),
    );
  }
}
