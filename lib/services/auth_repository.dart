import 'package:app_absen_rida/models/api_model.dart';
import 'package:app_absen_rida/services/api_services.dart';
import 'package:app_absen_rida/utils/constatns.dart';
import 'package:shared_preferences/shared_preferences.dart';

// lib/auth_repository.dart
class AuthRepository {
  final ApiService apiService;
  final SharedPreferences sharedPreferences;

  AuthRepository({required this.apiService, required this.sharedPreferences});

  /// Melakukan proses login dan menyimpan token serta data pengguna
  Future<User?> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);
      if (response.data != null) {
        apiService.setAuthToken(response.data!.token); // Simpan token di ApiService
        await sharedPreferences.setString(Constants.AUTH_TOKEN_KEY, response.data!.token); // Simpan token di SharedPreferences
        await saveUserData(response.data!.user); // Simpan data user di SharedPreferences
        return response.data!.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Melakukan proses register dan menyimpan token serta data pengguna
  Future<User?> register(String name, String email, String password, int batchId, int trainingId, String gender) async {
    try {
      final response = await apiService.register(name, email, password, batchId, trainingId, gender);
      if (response.data != null) {
        apiService.setAuthToken(response.data!.token);
        await sharedPreferences.setString(Constants.AUTH_TOKEN_KEY, response.data!.token);
        await saveUserData(response.data!.user);
        return response.data!.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Melakukan logout dengan menghapus token dan data pengguna
  Future<void> logout() async {
    apiService.setAuthToken(null);
    await sharedPreferences.remove(Constants.AUTH_TOKEN_KEY);
    await deleteUserData();
  }

  String? getToken() {
    return apiService.authToken;
  }

  /// Menyimpan data pengguna ke SharedPreferences
  Future<void> saveUserData(User user) async {
    await sharedPreferences.setInt(Constants.USER_ID_KEY, user.id);
    await sharedPreferences.setString(Constants.USER_NAME_KEY, user.name);
    await sharedPreferences.setString(Constants.USER_EMAIL_KEY, user.email);
    if (user.batchId != null) {
      await sharedPreferences.setInt('userBatchId', user.batchId!);
    }
    if (user.trainingId != null) {
      await sharedPreferences.setInt('userTrainingId', user.trainingId!);
    }
  }

  /// Mengambil data pengguna dari SharedPreferences
  User? getUserData() {
    final id = sharedPreferences.getInt(Constants.USER_ID_KEY);
    final name = sharedPreferences.getString(Constants.USER_NAME_KEY);
    final email = sharedPreferences.getString(Constants.USER_EMAIL_KEY);
    final batchId = sharedPreferences.getInt('userBatchId');
    final trainingId = sharedPreferences.getInt('userTrainingId');

    if (id != null && name != null && email != null) {
      return User(
        id: id,
        name: name,
        email: email,
        batchId: batchId,
        trainingId: trainingId,
        createdAt: '',
        updatedAt: '',
      );
    }
    return null;
  }

  Future<void> deleteUserData() async {
    await sharedPreferences.remove(Constants.USER_ID_KEY);
    await sharedPreferences.remove(Constants.USER_NAME_KEY);
    await sharedPreferences.remove(Constants.USER_EMAIL_KEY);
    await sharedPreferences.remove('userBatchId');
    await sharedPreferences.remove('userTrainingId');
  }

  bool isLoggedIn() {
    return apiService.authToken != null;
  }

  Future<void> loadAuthToken() async {
    final storedToken = sharedPreferences.getString(Constants.AUTH_TOKEN_KEY);
    if (storedToken != null) {
      apiService.setAuthToken(storedToken);
    }
  }

  /// ✅ Getter tambahan untuk mengakses user dengan lebih mudah
  User? get currentUser => getUserData();
}
