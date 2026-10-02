import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  // Configurable base URL
  static String? _customBaseUrl;
  static set customBaseUrl(String url) => _customBaseUrl = url;

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:5001/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        // Android emulator maps 10.0.2.2 to host machine's 127.0.0.1
        return 'http://10.0.2.2:5001/api/v1';
      }
    } catch (_) {}

    return 'http://localhost:5001/api/v1';
  }

  String? _authToken;
  Map<String, dynamic>? _currentUser;

  String? get token => _authToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null;

  void setSession(String token, Map<String, dynamic> user) {
    _authToken = token;
    _currentUser = user;
  }

  void clearSession() {
    _authToken = null;
    _currentUser = null;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uriString = '$baseUrl$endpoint';
      if (queryParams != null && queryParams.isNotEmpty) {
        final query = Uri(queryParameters: queryParams).query;
        uriString += '?$query';
      }

      final uri = Uri.parse(uriString);
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      return _handleNetworkError(e);
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded['data'] ?? decoded;
    } else {
      final message = decoded['error']?['message'] ??
          decoded['message'] ??
          'Request failed with status: ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }
  }

  dynamic _handleNetworkError(dynamic error) {
    if (error is ApiException) throw error;
    throw ApiException(
      'Unable to connect to backend server. Make sure the Node.js API is running on $baseUrl.',
      statusCode: 0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => message;
}
