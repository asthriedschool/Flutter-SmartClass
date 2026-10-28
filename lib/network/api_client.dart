import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/api_config.dart';
import '../services/auth_service.dart';
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
  static Future<bool>? _refreshInFlight;

  Future<List<Map<String, dynamic>>> getList(
    String path,
  ) async {
    try {
      final response = await _request(
        'GET',
        Uri.parse('${ApiConfig.baseUrl}$path'),
        headers: const {'Accept': 'application/json'},
      );

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
    } on SocketException {
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
    } on SocketException {
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
    } on SocketException {
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
  }) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path')
        .replace(queryParameters: query);
    return _request(
      method,
      uri,
      headers: {
        'Accept': 'application/json',
        if (body != null)
          'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> _request(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Object? body,
    bool allowRefresh = true,
  }) async {
    final token = await _tokenStorage.getAccessToken();
    final sent = Map<String, String>.from(headers);
    if (token != null && token.isNotEmpty) {
      sent['Authorization'] = 'Bearer $token';
    }
    final response = await _dispatch(
      method,
      uri,
      headers: sent,
      body: body,
    );
    if (response.statusCode != 401 || !allowRefresh) {
      return response;
    }
    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      return response;
    }
    return _request(
      method,
      uri,
      headers: headers,
      body: body,
      allowRefresh: false,
    );
  }

  Future<bool> _refreshAccessToken() {
    final current = _refreshInFlight;
    if (current != null) {
      return current;
    }
    late final Future<bool> created;
    created = () async {
      try {
        await AuthService().refreshToken();
        return true;
      } catch (_) {
        return false;
      } finally {
        if (identical(_refreshInFlight, created)) {
          _refreshInFlight = null;
        }
      }
    }();
    _refreshInFlight = created;
    return created;
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Object? body,
  }) async {
    final io = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..idleTimeout = const Duration(seconds: 1)
      ..findProxy = (_) => 'DIRECT';
    final client = IOClient(io);
    try {
      final Future<http.Response> request;
      switch (method) {
        case 'GET':
          request = client.get(uri, headers: headers);
        case 'POST':
          request = client.post(
            uri,
            headers: headers,
            body: body,
          );
        case 'PUT':
          request = client.put(
            uri,
            headers: headers,
            body: body,
          );
        case 'PATCH':
          request = client.patch(
            uri,
            headers: headers,
            body: body,
          );
        case 'DELETE':
          request = client.delete(uri, headers: headers);
        default:
          throw ArgumentError(
            'Metode $method tidak didukung.',
          );
      }
      return await request.timeout(
        const Duration(seconds: 20),
      );
    } finally {
      client.close();
    }
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
