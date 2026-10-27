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

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      final authResponse =
          AuthResponse.fromJson(responseData);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    final message =
        responseData['message'] ??
        'Login gagal';

    throw Exception(message);
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
    final refreshToken =
        await _tokenStorage.getRefreshToken();

    if (refreshToken == null ||
        refreshToken.isEmpty) {
      throw Exception(
        'Refresh token tidak ditemukan',
      );
    }

    final url = Uri.parse(
      '${ApiConfig.baseUrl}/auth/refresh',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refreshToken': refreshToken,
      }),
    );

    final responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200) {
      final authResponse =
          AuthResponse.fromJson(responseData);

      await _tokenStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );

      return authResponse;
    }

    final message =
        responseData['message'] ??
        'Refresh token gagal';

    throw Exception(message);
  }

  // Logout
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}