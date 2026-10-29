import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../storage/token_storage.dart';

class AuthService {
  final TokenStorage _tokenStorage = TokenStorage();

  // =========================================================
  // PSEUDOCODE LOGIN
  // =========================================================
  //
  // 1. User memasukkan email dan password.
  //
  // 2. Flutter mengirim:
  //      POST /api/auth/login
  //
  // 3. Backend melakukan:
  //      - mencari user berdasarkan email
  //      - mengecek password BCrypt
  //      - mengecek account status
  //      - membuat access token
  //      - membuat refresh token
  //
  // 4. Backend mengembalikan:
  //      - accessToken
  //      - refreshToken
  //      - tokenType
  //      - expiresInSeconds
  //
  // 5. Flutter menyimpan accessToken dan refreshToken
  //    menggunakan TokenStorage.
  //
  // 6. AuthResponse dikembalikan ke pemanggil.
  //
  // =========================================================

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/auth/login',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final responseData = _decodeBody(response.body);

      if (response.statusCode == 200) {
        if (responseData is! Map) {
          throw const AuthException(
            'Login gagal. Coba lagi.',
          );
        }

        final authResponse = AuthResponse.fromJson(
          Map<String, dynamic>.from(responseData),
        );

        await _tokenStorage.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        return authResponse;
      }

      throw _loginFailure(
        response.statusCode,
        responseData,
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'Waktu koneksi habis. Coba lagi.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    } on FormatException {
      throw const AuthException('Login gagal. Coba lagi.');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/auth/register',
    );

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'full_name': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final responseData = _decodeBody(response.body);

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        return;
      }

      throw _registerFailure(
        response.statusCode,
        responseData,
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      throw const AuthException(
        'Waktu koneksi habis. Coba lagi.',
      );
    } on http.ClientException {
      throw const AuthException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    } on FormatException {
      throw const AuthException(
        'Registrasi gagal. Coba lagi.',
      );
    }
  }

  // Membaca claim role untuk memilih layar awal.
  // Ini bukan verifikasi tanda tangan JWT.
  String? roleFromAccessToken(String accessToken) {
    final data = _payload(accessToken);
    if (data == null) {
      return null;
    }
    const claimKeys = [
      'role',
      'roles',
      'authorities',
      'authority',
    ];
    for (final key in claimKeys) {
      final role = _matchRole(data[key]);
      if (role != null) {
        return role;
      }
    }
    return null;
  }

  // Claim UI saja. Bukan verifikasi tanda tangan JWT.
  String? fullNameFromAccessToken(String accessToken) {
    final name = _payload(accessToken)?['fullName'];
    if (name is! String || name.trim().isEmpty) {
      return null;
    }
    return name.trim();
  }

  // Claim UI saja. Subject JWT adalah email.
  String? emailFromAccessToken(String accessToken) {
    final data = _payload(accessToken);
    if (data == null) {
      return null;
    }
    for (final key in ['sub', 'email']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  // =========================================================
  // PSEUDOCODE REFRESH TOKEN
  // =========================================================
  //
  // 1. Ambil refresh token dari TokenStorage.
  //
  // 2. Kirim refresh token ke:
  //      POST /api/auth/refresh
  //
  // 3. Backend memvalidasi refresh token.
  //
  // 4. Jika valid:
  //      - backend membuat access token baru
  //
  // 5. Flutter menyimpan access token baru.
  //
  // 6. Jika refresh token tidak valid:
  //      - login ulang diperlukan.
  //
  // =========================================================

  Future<AuthResponse> refreshToken() async {
    final refreshToken = await _tokenStorage
        .getRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('Refresh token tidak ditemukan');
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/auth/refresh',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(const Duration(seconds: 20));

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(
        responseData,
      );

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    final message =
        responseData['message'] ?? 'Refresh token gagal';

    throw Exception(message);
  }

  // Logout
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}

Map<String, dynamic>? _payload(String accessToken) {
  final parts = accessToken.split('.');
  if (parts.length < 2) {
    return null;
  }
  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(
      base64Url.decode(normalized),
    );
    final data = jsonDecode(payload);
    if (data is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(data);
  } on FormatException {
    return null;
  }
}

Object? _decodeBody(String body) {
  if (body.trim().isEmpty) {
    return null;
  }
  return jsonDecode(body);
}

AuthException _registerFailure(
  int statusCode,
  Object? body,
) {
  final message = _safeMessage(body);
  if (statusCode == 409) {
    return AuthException(
      message ?? 'Email sudah terdaftar.',
    );
  }
  if (statusCode == 400) {
    return AuthException(
      message ?? 'Data registrasi tidak valid.',
    );
  }
  if (statusCode >= 500) {
    return const AuthException(
      'Terjadi gangguan pada server. Coba lagi nanti.',
    );
  }
  return AuthException(
    message ?? 'Registrasi gagal. Coba lagi.',
  );
}

AuthException _loginFailure(int statusCode, Object? body) {
  final message = _safeMessage(body);
  if (statusCode == 400 || statusCode == 401) {
    return AuthException(
      message ?? 'Email atau password salah.',
    );
  }
  if (statusCode == 403) {
    return AuthException(
      message ?? 'Anda tidak memiliki akses.',
    );
  }
  if (statusCode >= 500) {
    return const AuthException(
      'Terjadi gangguan pada server. Coba lagi nanti.',
    );
  }
  return AuthException(
    message ?? 'Login gagal. Coba lagi.',
  );
}

String? _safeMessage(Object? body) {
  if (body is! Map) {
    return null;
  }
  final raw = body['message'];
  if (raw is! String) {
    return null;
  }
  final text = raw.trim();
  if (text.isEmpty || text.length > 160) {
    return null;
  }
  final lower = text.toLowerCase();
  const blocked = [
    'token',
    'exception',
    'sql',
    'stack',
    'bcrypt',
    'bearer',
  ];
  for (final word in blocked) {
    if (lower.contains(word)) {
      return null;
    }
  }
  return text;
}

String? _matchRole(Object? value) {
  if (value is List) {
    for (final item in value) {
      final role = _matchRole(item);
      if (role != null) {
        return role;
      }
    }
    return null;
  }
  if (value is! String) {
    return null;
  }
  var text = value.trim().toUpperCase();
  if (text.startsWith('ROLE_')) {
    text = text.substring(5);
  }
  if (text == 'ADMIN' || text == 'PETUGAS') {
    return text;
  }
  return null;
}
