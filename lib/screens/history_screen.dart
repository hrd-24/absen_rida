import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


// lib/screens/history_screen.dart
class HistoryScreen extends StatefulWidget {
  final ApiService apiService;

  const HistoryScreen({super.key, required this.apiService});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AbsenData> _historyList = [];
  bool _isLoading = true;
  String? _selectedStartDate;
  String? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.getAbsenHistory(
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
      );
      setState(() {
        _historyList = response.data;
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
        _historyList = []; // Clear data on error
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengambil riwayat absensi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _historyList = []; // Clear data on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, {bool isStartDate = true}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
        if (isStartDate) {
          _selectedStartDate = formattedDate;
        } else {
          _selectedEndDate = formattedDate;
        }
      });
      _fetchHistory(); // Fetch history after date selection
    }
  }

  Future<void> _deleteAbsen(int absenId) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus data absensi ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.apiService.deleteAbsen(absenId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data absensi berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchHistory(); // Refresh history after deletion
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
              content: Text('Terjadi kesalahan saat menghapus absensi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Absensi'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStartDate: true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Mulai',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_selectedStartDate ?? 'Pilih Tanggal'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, isStartDate: false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Akhir',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(_selectedEndDate ?? 'Pilih Tanggal'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : _historyList.isEmpty
                  ? const Expanded(
                      child: Center(child: Text('Tidak ada riwayat absensi.')))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          final absen = _historyList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal: ${absen.checkIn.split(' ')[0]}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Jam Masuk: ${absen.checkIn.split(' ')[1]}'),
                                  Text('Alamat Masuk: ${absen.checkInAddress}'),
                                  if (absen.checkOut != null) ...[
                                    Text('Jam Keluar: ${absen.checkOut!.split(' ')[1]}'),
                                    Text('Alamat Keluar: ${absen.checkOutAddress ?? '-'}'),
                                  ],
                                  Text('Status: ${absen.status}'),
                                  if (absen.alasanIzin != null)
                                    Text('Alasan Izin: ${absen.alasanIzin}'),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteAbsen(absen.id),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // History
        onTap: (index) {
          if (index == 0) {
            // Kembali ke Dashboard, perlu pop dan pushReplacementNamed
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (index == 2) {
            // Ke Profil, perlu pop dan pushReplacementNamed
            Navigator.of(context).pushReplacementNamed('/profile');
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
