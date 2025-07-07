import 'dart:convert';
import 'package:app_absen_rida/models/api_model.dart';
import 'package:http/http.dart' as http;

// No longer importing '../utils/constants.dart' for BASE_URL here
// as it will be defined directly in ApiService.

class ApiService {
  // Base URL langsung di dalam kelas ApiService
  final String baseUrl = 'https://appabsensi.mobileprojp.com/api';
  
  // Token otentikasi yang disimpan secara internal
  String? _authToken;

  // Http client untuk melakukan request
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengatur token otentikasi
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Mengambil token otentikasi
  String? get authToken => _authToken;

  /// Helper method untuk mendapatkan header request
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    // Menambahkan Authorization header jika diminta dan token tersedia
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Helper method untuk menangani permintaan POST umum
  Future<Map<String, dynamic>> _post(
      String endpoint, Map<String, dynamic> body,
      {bool includeAuth = true}) async { // Parameter token dihapus, diganti includeAuth
    final url = Uri.parse('$baseUrl/$endpoint');
    
    try {
      final response =
          await _client.post(url, headers: _getHeaders(includeAuth: includeAuth), body: json.encode(body));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Gagal terhubung ke server: $e', statusCode: 0);
    }
  }

  /// Helper method untuk menangani permintaan GET umum
  Future<Map<String, dynamic>> _get(String endpoint, {bool includeAuth = true, Map<String, dynamic>? queryParams}) async { // Parameter token dihapus
    Uri url = Uri.parse('$baseUrl/$endpoint');
    if (queryParams != null) {
      url = url.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }

    try {
      final response = await _client.get(url, headers: _getHeaders(includeAuth: includeAuth));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Gagal terhubung ke server: $e', statusCode: 0);
    }
  }

  /// Helper method untuk menangani permintaan PUT umum
  Future<Map<String, dynamic>> _put(
      String endpoint, Map<String, dynamic> body,
      {bool includeAuth = true}) async { // Parameter token dihapus
    final url = Uri.parse('$baseUrl/$endpoint');
    
    try {
      final response =
          await _client.put(url, headers: _getHeaders(includeAuth: includeAuth), body: json.encode(body));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Gagal terhubung ke server: $e', statusCode: 0);
    }
  }

  /// Helper method untuk menangani permintaan DELETE umum
  Future<Map<String, dynamic>> _delete(String endpoint, {bool includeAuth = true}) async { // Parameter token dihapus
    final url = Uri.parse('$baseUrl/$endpoint');
    
    try {
      final response = await _client.delete(url, headers: _getHeaders(includeAuth: includeAuth));
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Gagal terhubung ke server: $e', statusCode: 0);
    }
  }

  /// Menangani respons HTTP dan melemparkan ApiException jika ada kesalahan
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = json.decode(response.body) as Map<String, dynamic>;
      throw ApiException(
          message: errorBody['message'] as String? ?? 'Terjadi kesalahan tidak dikenal',
          statusCode: response.statusCode,
          errors: errorBody['errors'] as Map<String, dynamic>?);
    }
  }

  /// Layanan Autentikasi
  Future<RegisterResponse> register(String name, String email, String password,
      int batchId, int trainingId) async {
    final responseData = await _post(
      'register',
      {
        'name': name,
        'email': email,
        'password': password,
        'batch_id': batchId,
        'training_id': trainingId,
      },
      includeAuth: false, // Register tidak memerlukan token
    );
    return RegisterResponse.fromJson(responseData);
  }

  Future<LoginResponse> login(String email, String password) async {
    final responseData = await _post(
      'login',
      {
        'email': email,
        'password': password,
      },
      includeAuth: false, // Login tidak memerlukan token
    );
    return LoginResponse.fromJson(responseData);
  }

  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    final responseData = await _post(
      'forgot-password',
      {'email': email},
      includeAuth: false, // Forgot password tidak memerlukan token
    );
    return ForgotPasswordResponse.fromJson(responseData);
  }

  Future<ResetPasswordResponse> resetPassword(String email, String otp, String newPassword) async {
    final responseData = await _post(
      'reset-password',
      {'email': email, 'otp': otp, 'password': newPassword},
      includeAuth: false, // Reset password tidak memerlukan token
    );
    return ResetPasswordResponse.fromJson(responseData);
  }

  /// Layanan Absensi
  Future<AbsenCheckInResponse> absenCheckIn(AbsenCheckInRequest request) async {
    final responseData = await _post(
      'absen/check-in',
      request.toJson(),
      includeAuth: true, // Memerlukan token
    );
    return AbsenCheckInResponse.fromJson(responseData);
  }

  Future<AbsenCheckOutResponse> absenCheckOut(AbsenCheckOutRequest request) async {
    final responseData = await _post(
      'absen/check-out',
      request.toJson(),
      includeAuth: true, // Memerlukan token
    );
    return AbsenCheckOutResponse.fromJson(responseData);
  }

  Future<AbsenTodayResponse> getAbsenToday() async {
    final responseData = await _get(
      'absen/today',
      includeAuth: true, // Memerlukan token
    );
    return AbsenTodayResponse.fromJson(responseData);
  }

  Future<AbsenStatsResponse> getAbsenStats() async {
    final responseData = await _get(
      'absen/stats',
      includeAuth: true, // Memerlukan token
    );
    return AbsenStatsResponse.fromJson(responseData);
  }

  Future<HistoryAbsenResponse> getAbsenHistory({String? startDate, String? endDate}) async {
    Map<String, dynamic> queryParams = {};
    if (startDate != null) {
      queryParams['start'] = startDate;
    }
    if (endDate != null) {
      queryParams['end'] = endDate;
    }
    final responseData = await _get(
      'absen/history',
      includeAuth: true, // Memerlukan token
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    return HistoryAbsenResponse.fromJson(responseData);
  }

  Future<Map<String, dynamic>> deleteAbsen(int absenId) async {
    final responseData = await _delete(
      'absen/$absenId',
      includeAuth: true, // Memerlukan token
    );
    return responseData;
  }

  /// Layanan Profil
  Future<ProfileResponse> getProfile() async {
    final responseData = await _get(
      'profile',
      includeAuth: true, // Memerlukan token
    );
    return ProfileResponse.fromJson(responseData);
  }

  Future<ProfileResponse> editProfile(String name) async {
    final responseData = await _put(
      'profile',
      {'name': name},
      includeAuth: true, // Memerlukan token
    );
    return ProfileResponse.fromJson(responseData);
  }

  /// Layanan Umum (dari Postman collection)
  Future<List<Training>> getTrainings() async {
    final responseData = await _get('trainings', includeAuth: false); // Tidak memerlukan token
    return (responseData['data'] as List)
        .map((e) => Training.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Training> getTrainingDetail(int id) async {
    final responseData = await _get('trainings/$id', includeAuth: false); // Tidak memerlukan token
    return Training.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<List<User>> getAllUsers() async {
    final responseData = await _get('users', includeAuth: true); // Memerlukan token
    return (responseData['data'] as List)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Batch>> getAllBatches() async {
    final responseData = await _get('batches', includeAuth: true); // Memerlukan token
    return (responseData['data'] as List)
        .map((e) => Batch.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException: StatusCode $statusCode, Message: $message, Errors: $errors';
  }
}
