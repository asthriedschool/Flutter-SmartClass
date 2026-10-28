import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.unauthorized = false,
  });

  final String message;
  final bool unauthorized;
}

class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage ?? TokenStorage();

  final TokenStorage _tokenStorage;

  Future<List<Map<String, dynamic>>> getList(
    String path,
  ) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: {
              'Accept': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          throw const ApiException(
            'Data dari server tidak sesuai.',
          );
        }
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      throw _failure(response.statusCode);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'Waktu koneksi habis. Coba lagi.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server.',
      );
    } on FormatException {
      throw const ApiException(
        'Data dari server tidak sesuai.',
      );
    }
  }

  ApiException _failure(int statusCode) {
    if (statusCode == 401) {
      return const ApiException(
        'Sesi tidak valid. Silakan login kembali.',
        unauthorized: true,
      );
    }
    if (statusCode == 403) {
      return const ApiException(
        'Anda tidak memiliki akses ke data ini.',
      );
    }
    if (statusCode >= 500) {
      return const ApiException(
        'Terjadi gangguan pada server. Coba lagi.',
      );
    }
    return const ApiException('Data beranda gagal dimuat.');
  }
}
