import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/screens/history_screen.dart';
import 'package:app_absen_rida/screens/profile_screen.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'map_screen.dart'; // Import MapScreen

// lib/screens/dashboard_screen.dart
class DashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final User currentUser;
  final VoidCallback onLogout;
  final VoidCallback updateUserProfile; // Callback untuk update user di MyApp
  final Function(bool) toggleTheme;
  final ThemeMode currentThemeMode;
  

  const DashboardScreen({
    super.key,
    required this.apiService,
    required this.currentUser,
    required this.updateUserProfile, // Tambahkan parameter untuk callback update user
    required this.onLogout,
    required this.toggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AbsenTodayData? _absenTodayData;
  AbsenStatsData? _absenStatsData;
  bool _isLoadingAbsenData = false;
  bool _isPerformingAbsen = false;

  @override
  void initState() {
    super.initState();
    _fetchAbsenData();
  }

  Future<void> _fetchAbsenData() async {
    setState(() {
      _isLoadingAbsenData = true;
    });

    try {
      final absenTodayResponse = await widget.apiService.getAbsenToday();
      final absenStatsResponse = await widget.apiService.getAbsenStats();

      setState(() {
        _absenTodayData = absenTodayResponse.data;
        _absenStatsData = absenStatsResponse.data;
      });
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _absenTodayData = null; // Clear data on error
        _absenStatsData = null; // Clear data on error
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengambil data absensi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _absenTodayData = null; // Clear data on error
        _absenStatsData = null; // Clear data on error
      });
    } finally {
      setState(() {
        _isLoadingAbsenData = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi dinonaktifkan.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _performAbsen(String type) async {
    setState(() {
      _isPerformingAbsen = true;
    });

    try {
      Position position = await _determinePosition();
      String lat = position.latitude.toString();
      String lng = position.longitude.toString();
      String address = 'Lokasi Tidak Diketahui'; // Anda bisa menggunakan geocoding di sini

      if (type == 'check_in') {
        final request = AbsenCheckInRequest(
          checkInLat: lat,
          checkInLng: lng,
          checkInAddress: address,
          status: 'masuk',
        );
        await widget.apiService.absenCheckIn(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absen masuk berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (type == 'check_out') {
        final request = AbsenCheckOutRequest(
          checkOutLat: lat,
          checkOutLng: lng,
          checkOutAddress: address,
        );
        await widget.apiService.absenCheckOut(request);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Absen pulang berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      _fetchAbsenData(); // Refresh data setelah absen
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isPerformingAbsen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMMMyyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Absensi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              widget.toggleTheme(widget.currentThemeMode == ThemeMode.light);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              widget.onLogout(); // Panggil callback logout
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
          ),
        ],
      ),
      body: _isLoadingAbsenData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${widget.currentUser.name}!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal Hari Ini: $today',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isPerformingAbsen ? null : () => _performAbsen('check_in'),
                                  icon: _isPerformingAbsen && _absenTodayData?.jamMasuk == null
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.login),
                                  label: const Text('Absen Masuk'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isPerformingAbsen ? null : () => _performAbsen('check_out'),
                                  icon: _isPerformingAbsen && _absenTodayData?.jamKeluar == null
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.logout),
                                  label: const Text('Absen Pulang'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
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
                  Text(
                    'Status Absensi Hari Ini:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _absenTodayData == null
                          ? const Center(child: Text('Belum ada data absensi hari ini.'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tanggal: ${_absenTodayData!.tanggal}'),
                                Text('Jam Masuk: ${_absenTodayData!.jamMasuk}'),
                                Text('Jam Keluar: ${_absenTodayData!.jamKeluar ?? '-'}'),
                                Text('Alamat Masuk: ${_absenTodayData!.alamatMasuk}'),
                                Text('Alamat Keluar: ${_absenTodayData!.alamatKeluar ?? '-'}'),
                                Text('Status: ${_absenTodayData!.status}'),
                                if (_absenTodayData!.alasanIzin != null)
                                  Text('Alasan Izin: ${_absenTodayData!.alasanIzin}'),
                                const SizedBox(height: 10),
                                if (_absenTodayData!.checkInLat != null && _absenTodayData!.checkInLat != null)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                            latitude: _absenTodayData!.checkInLat!,
                                            longitude: _absenTodayData!.checkInLat!,
                                            title: 'Lokasi Absen Masuk',
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.map),
                                    label: const Text('Lihat Lokasi Masuk'),
                                  ),
                                if (_absenTodayData!.checkOutLat != null && _absenTodayData!.checkOutLat != null && _absenTodayData!.jamKeluar != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                              latitude: _absenTodayData!.checkOutLat!,
                                              longitude: _absenTodayData!.checkOutLat!,
                                              title: 'Lokasi Absen Pulang',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.map),
                                      label: const Text('Lihat Lokasi Pulang'),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Statistik Absensi:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _absenStatsData == null
                          ? const Center(child: Text('Belum ada statistik absensi.'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Absen: ${_absenStatsData!.totalAbsen}'),
                                Text('Total Masuk: ${_absenStatsData!.totalMasuk}'),
                                Text('Total Izin: ${_absenStatsData!.totalIzin}'),
                                Text('Sudah Absen Hari Ini: ${_absenStatsData!.sudahAbsenHariIni ? 'Ya' : 'Tidak'}'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Dashboard
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => HistoryScreen(apiService: widget.apiService),
            ));
          } else if (index == 2) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ProfileScreen(
                apiService: widget.apiService,
                currentUser: widget.currentUser,
                onUpdateUser: (user) => widget.updateUserProfile(), // Pass callback with User parameter
              ),
            ));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
