import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<User> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? role,
  }) async {
    final response = await _apiClient.post<User>(
      AppConstants.signup,
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role,
      },
      fromJson: (json) => User.fromJson(json),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      // Save token if provided
      final token = (response.rawData as Map<String, dynamic>)['token'];
      if (token != null) {
        _apiClient.setToken(token as String);
      }
      
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> login({
    required String identifier, // phone or email
    required String password,
  }) async {
    final response = await _apiClient.post<User>(
      AppConstants.login,
      body: {
        'identifier': identifier,
        'password': password,
      },
      fromJson: (json) => User.fromJson(json),
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      // Save token
      final token = (response.rawData as Map<String, dynamic>)['token'];
      if (token != null) {
        _apiClient.setToken(token as String);
      }
      
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(
        '/auth/logout',
        requiresAuth: true,
      );
    } finally {
      _apiClient.clearToken();
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _apiClient.get<User>(
      '/auth/me',
      fromJson: (json) => User.fromJson(json),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (profileImage != null) body['profileImage'] = profileImage;

    final response = await _apiClient.put<User>(
      '/auth/profile',
      body: body.isNotEmpty ? body : null,
      fromJson: (json) => User.fromJson(json),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      '/auth/forgot-password',
      body: {'email': email},
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      '/auth/reset-password',
      body: {
        'token': token,
        'password': newPassword,
      },
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> verifyEmail(String token) async {
    final response = await _apiClient.post(
      '/auth/verify-email',
      body: {'token': token},
      requiresAuth: false,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> verifyPhone(String code) async {
    final response = await _apiClient.post(
      '/auth/verify-phone',
      body: {'code': code},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> switchPrimaryRole(String role) async {
    final response = await _apiClient.post(
      '/auth/switch-role',
      body: {'role': role},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<bool> checkAuth() async {
    try {
      await getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
