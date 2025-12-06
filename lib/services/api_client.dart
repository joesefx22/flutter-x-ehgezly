import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final dynamic rawData;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.rawData,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? 'حدث خطأ',
      data: json['data'] != null ? fromJson(json['data']) : null,
      statusCode: json['statusCode'] as int?,
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'rawData': rawData,
    };
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (${statusCode ?? 0})';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String _baseUrl = AppConstants.apiBaseUrl;
  late String _token;
  final Map<String, String> _headers = {};

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.tokenKey) ?? '';
    _updateHeaders();
  }

  void _updateHeaders() {
    _headers.clear();
    _headers.addAll(AppConstants.getHeaders(_token));
  }

  void setToken(String token) async {
    _token = token;
    _updateHeaders();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  void clearToken() async {
    _token = '';
    _headers.remove('Authorization');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _request<T>(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _request<T>(
      'POST',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      fromJson: fromJson,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _request<T>(
      'PUT',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      fromJson: fromJson,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _request<T>(
      'PATCH',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      fromJson: fromJson,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    return _request<T>(
      'DELETE',
      endpoint,
      body: body,
      queryParameters: queryParameters,
      fromJson: fromJson,
      requiresAuth: requiresAuth,
    );
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      // Build URL
      String url = '$_baseUrl$endpoint';
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final uri = Uri.parse(url).replace(
          queryParameters: queryParameters.map(
            (key, value) => MapEntry(key, value.toString()),
          ),
        );
        url = uri.toString();
      }

      // Prepare request
      final uri = Uri.parse(url);
      final requestHeaders = Map<String, String>.from(_headers);
      
      if (requiresAuth && _token.isEmpty) {
        throw const ApiException(message: 'يجب تسجيل الدخول أولاً');
      }

      if (!requiresAuth) {
        requestHeaders.remove('Authorization');
      }

      // Make request
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConstants.apiTimeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConstants.apiTimeout);
          break;
        case 'PATCH':
          response = await http
              .patch(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConstants.apiTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(AppConstants.apiTimeout);
          break;
        case 'GET':
        default:
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(AppConstants.apiTimeout);
          break;
      }

      // Parse response
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (kDebugMode) {
        print('[$method] $url - ${response.statusCode}');
        print('Response: $responseBody');
      }

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null) {
          return ApiResponse<T>.fromJson(responseBody, fromJson);
        } else {
          return ApiResponse<T>(
            success: true,
            message: responseBody['message'] as String? ?? 'تمت العملية بنجاح',
            data: responseBody['data'] as T?,
            statusCode: response.statusCode,
            rawData: responseBody,
          );
        }
      } else {
        throw ApiException(
          message: responseBody['message'] as String? ?? 'حدث خطأ في الخادم',
          statusCode: response.statusCode,
          data: responseBody,
        );
      }
    } on TimeoutException {
      throw const ApiException(message: 'انتهت مهلة الاتصال');
    } on http.ClientException {
      throw const ApiException(message: 'فشل في الاتصال بالخادم');
    } on FormatException {
      throw const ApiException(message: 'تنسيق بيانات غير صحيح');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  // Multipart file upload
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fieldName = 'file',
    Map<String, String>? fields,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
  }) async {
    try {
      final url = '$_baseUrl$endpoint';
      final uri = Uri.parse(url);
      
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      if (requiresAuth) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.headers['Accept'] = 'application/json';
      
      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);
      
      // Add other fields
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Parse response
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null) {
          return ApiResponse<T>.fromJson(responseBody, fromJson);
        } else {
          return ApiResponse<T>(
            success: true,
            message: responseBody['message'] as String? ?? 'تم رفع الملف بنجاح',
            data: responseBody['data'] as T?,
            statusCode: response.statusCode,
            rawData: responseBody,
          );
        }
      } else {
        throw ApiException(
          message: responseBody['message'] as String? ?? 'فشل رفع الملف',
          statusCode: response.statusCode,
          data: responseBody,
        );
      }
    } catch (e) {
      throw ApiException(message: 'فشل رفع الملف: ${e.toString()}');
    }
  }
}
