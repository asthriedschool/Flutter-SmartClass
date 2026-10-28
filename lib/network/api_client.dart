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

  Future<Map<String, dynamic>> sendObject(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String fallback = 'Permintaan gagal. Coba lagi.',
  }) async {
    try {
      final response = await _send(
        method,
        path,
        body: body,
        query: query,
      );
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map) {
          throw const ApiException(
            'Data dari server tidak sesuai.',
          );
        }
        return Map<String, dynamic>.from(decoded);
      }
      throw _failure(
        response.statusCode,
        body: response.body,
        fallback: fallback,
      );
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

  Future<void> delete(
    String path, {
    String fallback = 'Data gagal dihapus.',
  }) async {
    try {
      final response = await _send('DELETE', path);
      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return;
      }
      throw _failure(
        response.statusCode,
        body: response.body,
        fallback: fallback,
      );
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
    }
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
    final encoded = body == null ? null : jsonEncode(body);
    final Future<http.Response> request;
    switch (method) {
      case 'POST':
        request = http.post(
          uri,
          headers: headers,
          body: encoded,
        );
      case 'PUT':
        request = http.put(
          uri,
          headers: headers,
          body: encoded,
        );
      case 'PATCH':
        request = http.patch(
          uri,
          headers: headers,
          body: encoded,
        );
      case 'DELETE':
        request = http.delete(uri, headers: headers);
      default:
        throw ArgumentError(
          'Metode $method tidak didukung.',
        );
    }
    return request.timeout(const Duration(seconds: 20));
  }

  ApiException _failure(
    int statusCode, {
    String? body,
    String fallback = 'Data beranda gagal dimuat.',
  }) {
    if (statusCode == 401) {
      return const ApiException(
        'Sesi tidak valid. Silakan login kembali.',
        unauthorized: true,
      );
    }
    final parsed = _safeMessage(body);
    if (parsed != null) {
      return ApiException(parsed);
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
    return ApiException(fallback);
  }

  String? _safeMessage(String? body) {
    if (body == null || body.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        return null;
      }
      final message = decoded['message'];
      if (message is! String) {
        return null;
      }
      final compact = message.trim();
      if (compact.isEmpty ||
          compact.length > 160 ||
          compact.contains('Exception') ||
          compact.contains('SQL')) {
        return null;
      }
      return compact;
    } on FormatException {
      return null;
    }
  }
}
