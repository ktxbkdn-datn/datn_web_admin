import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../feature/auth/presentation/bloc/auth_state.dart';
import '../error/failures.dart';

class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException({this.message = 'Phiên hết hạn. Vui lòng đăng nhập lại.'});
  
  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  String? _token;
  String? _refreshToken;
  bool _isInitialized = false;
  final _secureStorage = const FlutterSecureStorage();
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
      try {
        await _initializeTokens();
        _isInitialized = true;
      } catch (e) {
        print('Error initializing ApiService: $e');
        _isInitialized = false;
      }
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

    if (_token != null && _refreshToken != null) {
      final isValid = await _isTokenValid(_token!);
      if (!isValid) {
        print('Access token is invalid or expired, attempting to refresh');
        try {
          await refreshAccessToken();
        } catch (e) {
          print('Failed to refresh token: $e');
          // Do not clear tokens here; let _onCheckAuthStatus handle the state
        }
      }
    }
  }

  Future<bool> _isTokenValid(String token) async {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final exp = decodedToken['exp'] as int?;
      final iat = decodedToken['iat'] as int?;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

      if (exp == null || iat == null) {
        print('Token missing exp or iat claim');
        return false;
      }

      final isValid = now >= iat && now < exp;
      print('Token validity check: now=$now, iat=$iat, exp=$exp, isValid=$isValid');
      return isValid;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }

  Future<void> setToken(String? token, {String? refreshToken, bool rememberMe = false}) async {
    _token = token;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

    if (token != null) {
      await prefs.setString('auth_token', token);
      print('Saved access_token to SharedPreferences: $token');
    } else {
      await prefs.remove('auth_token');
      print('Removed access_token from SharedPreferences');
    }

    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    } else {
      await prefs.remove('refresh_token');

    }

    if (!kIsWeb) {
      if (token != null) {
        await _secureStorage.write(key: 'auth_token', value: token);
        // Verify storage
        final storedToken = await _secureStorage.read(key: 'auth_token');
      } else {
        await _secureStorage.delete(key: 'auth_token');
      }

      if (refreshToken != null) {
        await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        // Verify storage
        final storedRefreshToken = await _secureStorage.read(key: 'refresh_token');
      } else {
        await _secureStorage.delete(key: 'refresh_token');
      }
    }

    await prefs.setBool('remember_me', rememberMe);
    // Verify storage
    final storedRememberMe = prefs.getBool('remember_me');

  }

  Future<void> clearToken({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;

    if (force) { // Chỉ xóa token khi được yêu cầu rõ ràng (ví dụ, đăng xuất)
      _token = null;
      _refreshToken = null;
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      if (!rememberMe) { // Chỉ xóa saved_username và saved_password nếu !rememberMe
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }

      const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
      if (!kIsWeb) {
        await _secureStorage.delete(key: 'auth_token');
        await _secureStorage.delete(key: 'refresh_token');
      }
    } else {
      print('Keeping tokens (force: $force, rememberMe: $rememberMe)');
    }
  }

  Future<String?> getUserIdFromToken() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_token == null) return null;
    try {
      final decodedToken = JwtDecoder.decode(_token!);
      final userId = decodedToken['sub'] as String?;

      return userId;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<void> refreshAccessToken() async {
    print('Attempting to refresh access token');
    if (_refreshToken == null) {
      throw AuthFailure('No refresh token available');
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
          newRefreshToken ??= _refreshToken;

          await setToken(newAccessToken, refreshToken: newRefreshToken);

          return;
        } else {
          throw ServerFailure('No access token in refresh response');
        }
      } else {
        throw AuthFailure('Failed to refresh token: ${response.statusCode}');
      }
    } catch (e) {

      if (e is SocketException) {
        throw NetworkFailure('Network error while refreshing token: $e');
      }
      throw AuthFailure('Error refreshing token: $e');
    }
  }

  void _checkToken() {

    if (_token == null) {

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
        return null;
      }
      final responseBody = jsonDecode(bodyString);
      return responseBody;
    } catch (e) {
      print('Error parsing response body: $e');
      throw Exception('Lỗi: $e');
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
        if (!isPublic && _token != null) {
          final isValid = await _isTokenValid(_token!);
          if (!isValid) {
  
            await refreshAccessToken();
          }
        }

        final response = await requestFunction();

        if (isSuccess(response)) {
          return await parseResponse(response);
        }

        if (response.statusCode == 401 && !isPublic) {

          try {
            await refreshAccessToken();
          } catch (e) {
            // Nếu refresh token cũng hết hạn, throw SessionExpiredException
            throw SessionExpiredException();
          }
          retryCount++;

          continue;
        }

        if (response.statusCode == 429) {
          throw ServerFailure('Quá nhiều yêu cầu, vui lòng thử lại sau.');
        }

        final responseData = await _parseResponseBody(response);
        throw ServerFailure(
            responseData['message'] ?? 'Lỗi server: ${response.statusCode}');
      } on SocketException catch (e) {
   
        throw NetworkFailure('Lỗi: Không thể kết nối đến server');
      } on AuthFailure catch (e) {
   
        // Nếu là lỗi xác thực, throw SessionExpiredException
        throw SessionExpiredException();
      } catch (e) {
     
        throw ServerFailure('Lỗi: $e');
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
    return await _performRequestWithRefresh(
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
    return await _performRequestWithRefresh(
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
    return await _performRequestWithRefresh(
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
    return await _performRequestWithRefresh(
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
    return await _performRequestWithRefresh(
      () async {
        final uri = Uri.parse('$baseUrl$endpoint');


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
      

        if (fields != null) {
          request.fields.addAll(fields);
        
        } else {
          print('PUT Multipart Request Fields: None');
        }

        if (files != null) {
          request.files.addAll(files);
       
        } else {
          print('PUT Multipart Request Files: None');
        }

        final streamedResponse = await request.send().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('PUT Multipart request timed out after 30 seconds: $uri');
          },
        );

 

        return await http.Response.fromStream(streamedResponse);
      },
      endpoint,
      (response) async {
        try {
          final decodedResponse = await _parseResponseBody(response);
 
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
    return await _performRequestWithRefresh(
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

  Future<Uint8List> getFile(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    print('Starting GET FILE request to $endpoint');
    _checkToken();
    final requestHeaders = {
      'Authorization': 'Bearer $_token',
      if (headers != null) ...headers,
    };
    final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: requestHeaders);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    } else if (response.statusCode == 401) {
      // Thử refresh token nếu cần
      await refreshAccessToken();
      final retryResponse = await http.get(uri, headers: requestHeaders);
      if (retryResponse.statusCode >= 200 && retryResponse.statusCode < 300) {
        return retryResponse.bodyBytes;
      }
    }
    throw ServerFailure('Lỗi tải file: ${response.statusCode}');
  }

  // Phương thức để tải file binary (như PDF) mà không parse JSON
  Future<Uint8List> getRaw(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    print('Starting GET RAW request to $endpoint');
    return await _performRequestWithRefresh(
      () async {
        _checkToken();
        final requestHeaders = {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/pdf,application/octet-stream',
          if (headers != null) ...headers,
        };
        print('GET RAW request headers: $requestHeaders');

        final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);

        print('Sending GET RAW request...');
        return await http.get(
          uri,
          headers: requestHeaders,
        );
      },
      endpoint,
      (response) async {
        // Trả về binary data thay vì parse JSON
        return response.bodyBytes;
      },
      (response) => response.statusCode >= 200 && response.statusCode < 300,
    );
  }
}