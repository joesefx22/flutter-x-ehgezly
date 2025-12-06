import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/services/auth_service.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  final AuthService _authService = AuthService();

  AuthProvider() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.userKey);
      
      if (userJson != null) {
        final userMap = Map<String, dynamic>.from(json.decode(userJson));
        _user = User.fromJson(userMap);
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stored user: $e');
      }
    }
  }

  Future<void> _saveUser(User user) async {
    _user = user;
    _isAuthenticated = true;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
    
    notifyListeners();
  }

  Future<void> _clearUser() async {
    _user = null;
    _isAuthenticated = false;
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userKey);
    
    notifyListeners();
  }

  Future<bool> checkExistingAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_user == null) {
        await _loadStoredUser();
      }

      if (_user != null) {
        // Verify token is still valid
        final isValid = await _authService.checkAuth();
        if (!isValid) {
          await _clearUser();
          return false;
        }
        
        // Refresh user data
        final currentUser = await _authService.getCurrentUser();
        await _saveUser(currentUser);
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Auth check error: $e');
      }
      await _clearUser();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.login(
        identifier: identifier,
        password: password,
      );

      await _saveUser(user);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signup(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      await _saveUser(user);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      await _clearUser();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
      );

      await _saveUser(updatedUser);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> switchPrimaryRole(String role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      if (!_user!.roles.contains(role)) {
        throw Exception('ليس لديك صلاحية هذا الدور');
      }

      await _authService.switchPrimaryRole(role);
      
      // Update local user
      final updatedUser = _user!.copyWith(primaryRole: role);
      await _saveUser(updatedUser);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    try {
      if (_user == null) return;

      final currentUser = await _authService.getCurrentUser();
      await _saveUser(currentUser);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user: $e');
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool hasRole(String role) {
    return _user?.roles.contains(role) ?? false;
  }

  bool get isPlayer => hasRole('player');
  bool get isStaff => hasRole('staff');
  bool get isOwner => hasRole('owner');
  bool get isAdmin => hasRole('admin');

  String get primaryRole => _user?.primaryRole ?? 'player';
}
