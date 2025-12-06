import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useSystemTheme = false;

  ThemeMode get themeMode => _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(AppConstants.themeKey);
      final systemThemeValue = prefs.getBool('use_system_theme') ?? false;

      _useSystemTheme = systemThemeValue;

      if (themeValue == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (themeValue == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading theme: $e');
      }
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String themeValue;
    
    if (_useSystemTheme) {
      themeValue = 'system';
    } else {
      themeValue = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    }
    
    await prefs.setString(AppConstants.themeKey, themeValue);
    await prefs.setBool('use_system_theme', _useSystemTheme);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _useSystemTheme = false;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _useSystemTheme = false;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    _useSystemTheme = value;
    if (value) {
      _themeMode = ThemeMode.system;
    }
    await _saveTheme();
    notifyListeners();
  }

  void updateFromSystemBrightness(bool isSystemDark) {
    if (_useSystemTheme) {
      _themeMode = isSystemDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
}
