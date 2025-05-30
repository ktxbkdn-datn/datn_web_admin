import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../feature/auth/presentation/bloc/auth_state.dart';
import '../error/failures.dart';

class ApiService {
  final String baseUrl;
  String? _token;
  String? _refreshToken;
  bool _isInitialized = false;
  final _secureStorage = const FlutterSecureStorage();
  // Public endpoints that don't require authentication
  static const _publicEndpoints = [
    '/auth/admin/login',
    '/auth/user/login',
    '/auth/logout',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/refresh',
  ];

  ApiService({required this.baseUrl}) {
    print('Creating new ApiService instance: $this');
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await _initializeTokens();
      _isInitialized = true;
    }
  }

  String? get token => _token;
  String? get refreshToken => _refreshToken;

  Future<void> _initializeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
    print('Token from shared preferences: $_token');
    print('Refresh token from shared preferences: $_refreshToken');

    if (_token == null || _refreshToken == null) {
      const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
      if (!kIsWeb) {
        _token = await _secureStorage.read(key: 'auth_token');
        _refreshToken = await _secureStorage.read(key: 'refresh_token');
        print('Token from secure storage: $_token');
        print('Refresh token from secure storage: $_refreshToken');
        if (_token != null && _refreshToken != null) {
          await prefs.setString('auth_token', _token!);
          await prefs.setString('refresh_token', _refreshToken!);
          print('Saved tokens to shared preferences from secure storage');
        }
      }
    }
  }

  Future<void> setToken(String? token, {String? refreshToken}) async {
    _token = token;
    _refreshToken = refreshToken ?? _refreshToken;
    final prefs = await SharedPreferences.getInstance();
    const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

    if (token != null) {
      await prefs.setString('auth_token', token);
      print('Saved token to shared preferences: $token');
    } else {
      await prefs.remove('auth_token');
      print('Removed token from shared preferences');
    }

    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
      print('Saved refresh token to shared preferences: $refreshToken');
    } else if (token == null) {
      await prefs.remove('refresh_token');
      print('Removed refresh token from shared preferences');
    }

    if (!kIsWeb) {
      if (token != null) {
        await _secureStorage.write(key: 'auth_token', value: token);
        print('Saved token to secure storage: $token');
      } else {
        await _secureStorage.delete(key: 'auth_token');
        print('Removed token from secure storage');
      }

      if (refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        print('Saved refresh token to secure storage: $refreshToken');
      } else if (token == null) {
        await _secureStorage.delete(key: 'refresh_token');
        print('Removed refresh token from secure storage');
      }
    }
  }

  Future<void> clearToken() async {
    await setToken(null);
  }

  Future<String?> getUserIdFromToken() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_token == null) return null;
    try {
      final decodedToken = JwtDecoder.decode(_token!);
      final userId = decodedToken['sub'] as String?;
      print('Extracted user ID from token: $userId');
      return userId;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<bool> refreshAccessToken() async {
    print('Attempting to refresh access token');
    if (_refreshToken == null) {
      print('No refresh token available');
      return false;
    }

    final uri = Uri.parse('$baseUrl/auth/refresh');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'refresh_token=$_refreshToken',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerFailure('Refresh token request timed out after 30 seconds');
        },
      );

      print('Refresh token response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access_token'] as String?;
        if (newAccessToken != null) {
          String? newRefreshToken;
          final setCookieHeader = response.headers['set-cookie'];
          if (setCookieHeader != null) {
            final cookies = setCookieHeader.split(';');
            for (var cookie in cookies) {
              if (cookie.trim().startsWith('refresh_token=')) {
                newRefreshToken = cookie.trim().split('=')[1];
                break;
              }
            }
          }
          newRefreshToken ??= _refreshToken; // Keep existing if not rotated

          await setToken(newAccessToken, refreshToken: newRefreshToken);
          print('Access token refreshed successfully');
          return true;
        } else {
          print('No access token in refresh response');
          return false;
        }
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  void _checkToken() {
    print('Checking token: $_token');
    if (_token == null) {
      print('Token is null');
      throw AuthFailure('Token không tồn tại. Vui lòng đăng nhập lại.');
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<dynamic> _parseResponseBody(http.Response response) async {
    try {
      final bodyString = response.body;
      if (bodyString.isEmpty) {
        return null; // Trả về null nếu body rỗng
      }
      final responseBody = jsonDecode(bodyString); // Không ép kiểu
      return responseBody; // Có thể là Map, List, hoặc kiểu khác
    } catch (e) {
      print('Error parsing response body: $e');
      throw Exception('Lỗi parse JSON: $e');
    }
  }

  Future<T> _performRequestWithRefresh<T>(
      Future<http.Response> Function() requestFunction,
      String endpoint,
      Future<T> Function(http.Response) parseResponse,
      bool Function(http.Response) isSuccess,
      ) async {
    const int maxRetries = 2;
    int retryCount = 0;
    bool isPublic = _publicEndpoints.any((publicEndpoint) =>
    endpoint == publicEndpoint ||
        endpoint.startsWith(publicEndpoint.endsWith('/') ? publicEndpoint : '$publicEndpoint/'));

    while (retryCount < maxRetries) {
      try {
        final response = await requestFunction();
        print('Response status for $endpoint: ${response.statusCode} - ${response.body}');

        if (isSuccess(response)) {
          return await parseResponse(response);
        }

        if (response.statusCode == 401 && !isPublic) {
          print('Received 401 Unauthorized for $endpoint, attempting to refresh token');
          final refreshed = await refreshAccessToken();
          if (refreshed) {
            retryCount++;
            print('Retrying request with new access token ($retryCount/$maxRetries) for $endpoint');
            continue;
          } else {
            print('Failed to refresh token for $endpoint, logging out');
            await clearToken();
            throw AuthFailure('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
          }
        }

        if (response.statusCode == 429) {
          throw ServerFailure('Quá nhiều yêu cầu, vui lòng thử lại sau.');
        }

        final responseData = await _parseResponseBody(response);
        throw ServerFailure(
            responseData['message'] ?? 'Lỗi server: ${response.statusCode}');
      } on SocketException catch (e) {
        print('SocketException for $endpoint: $e');
        throw NetworkFailure('Lỗi kết nối: Không thể kết nối đến server');
      } catch (e) {
        print('Unexpected error for $endpoint: $e');
        throw ServerFailure('Lỗi không xác định: $e');
      }
    }

    throw ServerFailure('Failed to complete request after $maxRetries retries for $endpoint');
  }

  Future<dynamic> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, String>? queryParams,
      }) async {
    print('Starting GET request to $endpoint');
    return _performRequestWithRefresh(
          () async {
        _checkToken();
        final requestHeaders = {
          'Authorization': 'Bearer $_token',
          if (headers != null) ...headers,
        };
        print('GET request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

        print('Sending GET request...');
        return await http.get(
          uri,
          headers: requestHeaders,
        );
      },
      endpoint,
          (response) async => await _parseResponseBody(response),
          (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body, {
        Map<String, String>? headers,
      }) async {
    print('Starting POST request to $endpoint');
    return _performRequestWithRefresh(
          () async {
        final requestHeaders = {
          if (_token != null) 'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('POST request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        print('Sending POST request...');
        return await http.post(
          uri,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
      },
      endpoint,
          (response) async => await _parseResponseBody(response),
          (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<dynamic> postMultipart(
      String endpoint, {
        Map<String, String>? fields,
        required List<http.MultipartFile> files,
      }) async {
    return _performRequestWithRefresh(
          () async {
        final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
        if (fields != null) {
          request.fields.addAll(fields);
        }
        request.files.addAll(files);
        request.headers['Authorization'] = 'Bearer $_token';
        print('Request headers: ${request.headers}');

        final streamedResponse = await request.send();
        return await http.Response.fromStream(streamedResponse);
      },
      endpoint,
          (response) async => await _parseResponseBody(response),
          (response) => response.statusCode == 200 || response.statusCode == 201,
    );
  }

  Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> body, {
        Map<String, String>? headers,
      }) async {
    print('Starting PUT request to $endpoint');
    return _performRequestWithRefresh(
          () async {
        _checkToken();
        final requestHeaders = {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('PUT request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        print('Sending PUT request...');
        return await http.put(
          uri,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
      },
      endpoint,
          (response) async => await _parseResponseBody(response),
          (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  Future<dynamic> putMultipart(
      String endpoint, {
        Map<String, String>? fields,
        List<http.MultipartFile>? files,
        Map<String, String>? headers,
      }) async {
    return _performRequestWithRefresh(
          () async {
        final uri = Uri.parse('$baseUrl$endpoint');
        print('PUT Multipart Request URL: $uri');

        var request = http.MultipartRequest('PUT', uri);

        final token = await _getAuthToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        } else {
          print('PUT Multipart Warning: No auth token found');
        }

        if (headers != null) {
          request.headers.addAll(headers);
        }
        print('PUT Multipart Request Headers: ${request.headers}');

        if (fields != null) {
          request.fields.addAll(fields);
          print('PUT Multipart Request Fields: $fields');
        } else {
          print('PUT Multipart Request Fields: None');
        }

        if (files != null) {
          request.files.addAll(files);
          print('PUT Multipart Request Files: ${files.map((f) => f.filename).toList()}');
        } else {
          print('PUT Multipart Request Files: None');
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('PUT Multipart request timed out after 30 seconds: $uri');
          },
        );

        print('PUT Multipart Response Status: ${streamedResponse.statusCode}');

        return await http.Response.fromStream(streamedResponse);
      },
      endpoint,
          (response) async {
        try {
          final decodedResponse = await _parseResponseBody(response);
          print('PUT Multipart Decoded Response: $decodedResponse');
          return decodedResponse;
        } catch (e) {
          print('PUT Multipart JSON Decode Error: $e');
          throw Exception('Failed to decode JSON response: ${response.body}');
        }
      },
          (response) => response.statusCode == 200 || response.statusCode == 201,
    );
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, String>? headers,
        dynamic data,
      }) async {
    print('Starting DELETE request to $endpoint in ApiService $this');
    return _performRequestWithRefresh(
          () async {
        if (!_isInitialized) {
          await initialize();
        }
        final requestHeaders = {
          if (_token != null) 'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          if (headers != null) ...headers,
        };
        print('DELETE request headers in ApiService $this: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint');

        final encodedBody = data != null ? jsonEncode(data) : null;
        print('DELETE request body in ApiService $this: $encodedBody');
        return await http.delete(
          uri,
          headers: requestHeaders,
          body: encodedBody,
        );
      },
      endpoint,
          (response) async {
        if (response.statusCode == 204) {
          return {};
        }
        return await _parseResponseBody(response);
      },
          (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }
}