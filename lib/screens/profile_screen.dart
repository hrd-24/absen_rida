import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/services/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'login_screen.dart'; // Import LoginScreen

// lib/screens/profile_screen.dart
class ProfileScreen extends StatefulWidget {
  final ApiService apiService;
  final User currentUser;
  final Function(User) onUpdateUser; // Callback untuk update user di MyApp

  const ProfileScreen({
    super.key,
    required this.apiService,
    required this.currentUser,
    required this.onUpdateUser,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  User? _userProfile;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _userProfile = widget.currentUser; // Inisialisasi dengan currentUser dari widget
    _nameController.text = _userProfile?.name ?? '';
    _fetchProfile(); // Tetap panggil API untuk data terbaru
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.getProfile();
      setState(() {
        _userProfile = response.data;
        _nameController.text = _userProfile?.name ?? '';
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
        _userProfile = null; // Clear data on error
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengambil profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _userProfile = null; // Clear data on error
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await widget.apiService.editProfile(_nameController.text);
      if (response.data != null) {
        widget.onUpdateUser(response.data!); // Panggil callback untuk update user di MyApp
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        setState(() {
          _isEditing = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        String errorMessage = e.message;
        if (e.errors != null) {
          e.errors!.forEach((key, value) {
            errorMessage += '\n${value.join(', ')}';
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat memperbarui profil: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(child: Text('Gagal memuat data profil.'))
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
                                'Detail Profil',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                enabled: _isEditing,
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: TextEditingController(text: _userProfile!.email),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                ),
                                readOnly: true, // Email biasanya tidak bisa diedit
                              ),
                              const SizedBox(height: 15),
                              Text('Dibuat pada: ${_userProfile!.createdAt ?? '-'}'),
                              Text('Diperbarui pada: ${_userProfile!.updatedAt ?? '-'}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            widget.apiService.setAuthToken(null); // Hapus token dari ApiService
                            // Hapus token dari SharedPreferences juga
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove('authToken'); // Gunakan kunci yang sama dengan yang disimpan

                            // Kembali ke halaman login dan hapus semua rute sebelumnya
                            if (mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => LoginScreen(
                                  apiService: widget.apiService,
                                  authRepository: AuthRepository(
                                    apiService: widget.apiService,
                                    sharedPreferences: prefs, // Teruskan instance prefs yang sama
                                  ),
                                  onLoginSuccess: (user) { /* do nothing, main will handle */ },
                                )),
                                (Route<dynamic> route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Profile
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/history');
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
