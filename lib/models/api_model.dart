// lib/models/register_model.dart
class RegisterResponse {
  final String message;
  final RegisterData? data; // Nullable for error cases

  RegisterResponse({
    required this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String,
      data: json['data'] != null ? RegisterData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class RegisterData {
  final String token;
  final User user;

  RegisterData({
    required this.token,
    required this.user,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

// lib/models/login_model.dart
class LoginResponse {
  final String message;
  final LoginData? data; // Nullable for error cases

  LoginResponse({
    required this.message,
    this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      data: json['data'] != null ? LoginData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class LoginData {
  final String token;
  final User user;

  LoginData({
    required this.token,
    required this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}


// lib/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt; // Nullable
  final String? createdAt;
  final String? updatedAt;
  final int? batchId; // From Register Request Body
  final int? trainingId; // From Register Request Body

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.batchId,
    this.trainingId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      batchId: json['batch_id'] as int?,
      trainingId: json['training_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'batch_id': batchId,
      'training_id': trainingId,
    };
  }
}

// lib/models/absen_check_in_model.dart
class AbsenCheckInResponse {
  final String message;
  final AbsenData? data; // Nullable for error cases

  AbsenCheckInResponse({
    required this.message,
    this.data,
  });

  factory AbsenCheckInResponse.fromJson(Map<String, dynamic> json) {
    return AbsenCheckInResponse(
      message: json['message'] as String,
      data: json['data'] != null ? AbsenData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AbsenCheckInRequest {
  final String checkInLat;
  final String checkInLng;
  final String checkInAddress;
  final String status;
  final String? alasanIzin;

  AbsenCheckInRequest({
    required this.checkInLat,
    required this.checkInLng,
    required this.checkInAddress,
    required this.status,
    this.alasanIzin,
  });

  Map<String, dynamic> toJson() {
    return {
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_in_address': checkInAddress,
      'status': status,
      'alasan_izin': alasanIzin,
    };
  }
}

// lib/models/absen_check_out_model.dart
class AbsenCheckOutResponse {
  final String message;
  final AbsenData? data; // Nullable for error cases

  AbsenCheckOutResponse({
    required this.message,
    this.data,
  });

  factory AbsenCheckOutResponse.fromJson(Map<String, dynamic> json) {
    return AbsenCheckOutResponse(
      message: json['message'] as String,
      data: json['data'] != null ? AbsenData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AbsenCheckOutRequest {
  final String checkOutLat;
  final String checkOutLng;
  final String checkOutAddress;

  AbsenCheckOutRequest({
    required this.checkOutLat,
    required this.checkOutLng,
    required this.checkOutAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
      'check_out_address': checkOutAddress,
    };
  }
}

// lib/models/absen_data_model.dart
class AbsenData {
  final int id;
  final int userId;
  final String checkIn;
  final String checkInLocation;
  final String checkInAddress;
  final String? checkOut; // Nullable
  final String? checkOutLocation; // Nullable
  final String? checkOutAddress; // Nullable
  final String status;
  final String? alasanIzin; // Nullable
  final String? createdAt;
  final String? updatedAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  AbsenData({
    required this.id,
    required this.userId,
    required this.checkIn,
    required this.checkInLocation,
    required this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    required this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory AbsenData.fromJson(Map<String, dynamic> json) {
    return AbsenData(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      checkIn: json['check_in'] as String,
      checkInLocation: json['check_in_location'] as String,
      checkInAddress: json['check_in_address'] as String,
      checkOut: json['check_out'] as String?,
      checkOutLocation: json['check_out_location'] as String?,
      checkOutAddress: json['check_out_address'] as String?,
      status: json['status'] as String,
      alasanIzin: json['alasan_izin'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      checkInLat: (json['check_in_lat'] as num?)?.toDouble(),
      checkInLng: (json['check_in_lng'] as num?)?.toDouble(),
      checkOutLat: (json['check_out_lat'] as num?)?.toDouble(),
      checkOutLng: (json['check_out_lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'check_in': checkIn,
      'check_in_location': checkInLocation,
      'check_in_address': checkInAddress,
      'check_out': checkOut,
      'check_out_location': checkOutLocation,
      'check_out_address': checkOutAddress,
      'status': status,
      'alasan_izin': alasanIzin,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'check_in_lat': checkInLat,
      'check_in_lng': checkInLng,
      'check_out_lat': checkOutLat,
      'check_out_lng': checkOutLng,
    };
  }
}

// lib/models/absen_today_model.dart
class AbsenTodayResponse {
  final String message;
  final AbsenTodayData? data; // Nullable for "Belum ada data absensi hari ini"

  AbsenTodayResponse({
    required this.message,
    this.data,
  });

  factory AbsenTodayResponse.fromJson(Map<String, dynamic> json) {
    return AbsenTodayResponse(
      message: json['message'] as String,
      data: json['data'] != null ? AbsenTodayData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AbsenTodayData {
  final String tanggal;
  final String jamMasuk;
  final String? jamKeluar; // Nullable
  final String alamatMasuk;
  final String? alamatKeluar; // Nullable
  final String status;
  final String? alasanIzin; // Nullable

  AbsenTodayData({
    required this.tanggal,
    required this.jamMasuk,
    this.jamKeluar,
    required this.alamatMasuk,
    this.alamatKeluar,
    required this.status,
    this.alasanIzin,
  });

  factory AbsenTodayData.fromJson(Map<String, dynamic> json) {
    return AbsenTodayData(
      tanggal: json['tanggal'] as String,
      jamMasuk: json['jam_masuk'] as String,
      jamKeluar: json['jam_keluar'] as String?,
      alamatMasuk: json['alamat_masuk'] as String,
      alamatKeluar: json['alamat_keluar'] as String?,
      status: json['status'] as String,
      alasanIzin: json['alasan_izin'] as String?,
    );
  }

  get checkInLat => null;

  get checkOutLat => null;

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'alamat_masuk': alamatMasuk,
      'alamat_keluar': alamatKeluar,
      'status': status,
      'alasan_izin': alasanIzin,
    };
  }
}

// lib/models/absen_stats_model.dart
class AbsenStatsResponse {
  final String message;
  final AbsenStatsData? data; // Nullable for error cases

  AbsenStatsResponse({
    required this.message,
    this.data,
  });

  factory AbsenStatsResponse.fromJson(Map<String, dynamic> json) {
    return AbsenStatsResponse(
      message: json['message'] as String,
      data: json['data'] != null ? AbsenStatsData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AbsenStatsData {
  final int totalAbsen;
  final int totalMasuk;
  final int totalIzin;
  final bool sudahAbsenHariIni;

  AbsenStatsData({
    required this.totalAbsen,
    required this.totalMasuk,
    required this.totalIzin,
    required this.sudahAbsenHariIni,
  });

  factory AbsenStatsData.fromJson(Map<String, dynamic> json) {
    return AbsenStatsData(
      totalAbsen: json['total_absen'] as int,
      totalMasuk: json['total_masuk'] as int,
      totalIzin: json['total_izin'] as int,
      sudahAbsenHariIni: json['sudah_absen_hari_ini'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_absen': totalAbsen,
      'total_masuk': totalMasuk,
      'total_izin': totalIzin,
      'sudah_absen_hari_ini': sudahAbsenHariIni,
    };
  }
}

// lib/models/error_response_model.dart
class ErrorResponse {
  final String message;
  final Map<String, dynamic>? errors; // Nullable as it might not always be present

  ErrorResponse({
    required this.message,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] as String,
      errors: json['errors'] is Map ? Map<String, dynamic>.from(json['errors'] as Map) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errors': errors,
    };
  }
}

// lib/models/training_model.dart
class Training {
  final int id;
  final String title;
  final String? description;
  final int? participantCount;
  final String? standard;
  final String? duration;
  final String? createdAt;
  final String? updatedAt;
  final List<dynamic>? units; // Assuming units can be dynamic or another model
  final List<dynamic>? activities; // Assuming activities can be dynamic or another model

  Training({
    required this.id,
    required this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
    this.units,
    this.activities,
  });

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      participantCount: json['participant_count'] as int?,
      standard: json['standard'] as String?,
      duration: json['duration'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      units: json['units'] as List<dynamic>?,
      activities: json['activities'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'participant_count': participantCount,
      'standard': standard,
      'duration': duration,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'units': units,
      'activities': activities,
    };
  }
}

// lib/models/batch_model.dart
// Assuming a simple batch model based on common API patterns,
// as the Postman collection didn't provide a detailed batch response body.
class Batch {
  final int id;
  final String name; // Example field

  Batch({
    required this.id,
    required this.name,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

// lib/models/profile_model.dart
class ProfileResponse {
  final String message;
  final User? data;

  ProfileResponse({
    required this.message,
    this.data,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      message: json['message'] as String,
      data: json['data'] != null ? User.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// lib/models/history_absen_model.dart
class HistoryAbsenResponse {
  final String message;
  final List<AbsenData> data;

  HistoryAbsenResponse({
    required this.message,
    required this.data,
  });

  factory HistoryAbsenResponse.fromJson(Map<String, dynamic> json) {
    return HistoryAbsenResponse(
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => AbsenData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

// lib/models/forgot_password_model.dart
class ForgotPasswordResponse {
  final String message;

  ForgotPasswordResponse({required this.message});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] as String,
    );
  }
}

// lib/models/reset_password_model.dart
class ResetPasswordResponse {
  final String message;

  ResetPasswordResponse({required this.message});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      message: json['message'] as String,
    );
  }
}
