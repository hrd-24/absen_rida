import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/services/auth_repository.dart';
import 'package:flutter/material.dart';

// lib/screens/register_screen.dart
class RegisterScreen extends StatefulWidget {
  final ApiService apiService;
  final AuthRepository authRepository;
  final Function(User) onRegisterSuccess; // Callback setelah register berhasil

  const RegisterScreen({
    super.key,
    required this.apiService,
    required this.authRepository,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _batchIdController = TextEditingController(
    text: '1',
  ); // Placeholder
  final TextEditingController _trainingIdController = TextEditingController(
    text: '1',
  ); // Placeholder
  String? _selectedGender; // New field for gender
  bool _isLoading = false;

  Future<void> _register() async {
    // Validasi sederhana untuk jenis kelamin
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jenis kelamin wajib dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await widget.authRepository.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        int.parse(_batchIdController.text),
        int.parse(_trainingIdController.text),
        _selectedGender!, // Pass the selected gender
      );
      if (user != null) {
        widget.onRegisterSuccess(
          user,
        ); // Panggil callback untuk update state di MyApp
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(
            context,
          ).pushReplacementNamed('/login'); // Langsung ke dashboard
        }
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
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: $e'),
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
      appBar: AppBar(title: const Text('Daftar Akun Baru'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Daftar', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 15),
                  // Dropdown for Jenis Kelamin
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: Icon(Icons.people),
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Jenis Kelamin'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    items:
                        <String>[
                          'L',
                          'P',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _batchIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID Batch (contoh: 1)',
                      prefixIcon: Icon(Icons.group),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _trainingIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID Training (contoh: 1)',
                      prefixIcon: Icon(Icons.school),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Daftar'),
                      ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Kembali ke halaman login
                    },
                    child: const Text('Sudah punya akun? Login di sini'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
