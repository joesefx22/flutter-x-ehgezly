import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConstants {
  // API Endpoints
  static const String baseUrl = 'https://api.ehgezly.com';
  static const String apiVersion = '/api/v1';
  
  // API Routes
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String stadiums = '/stadiums';
  static const String bookings = '/bookings';
  static const String payments = '/payments';
  static const String playRequests = '/play-requests';
  static const String notifications = '/notifications';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String fcmTokenKey = 'fcm_token';
  
  // App Constants
  static const String appName = 'احجزلي';
  static const String appVersion = '1.0.0';
  static const int bookingTimeoutMinutes = 10;
  static const double depositPercentage = 0.3;
  
  // Pagination
  static const int itemsPerPage = 10;
  static const int stadiumsPerPage = 12;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxPhoneLength = 15;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Initialize app services
  static Future<void> initializeApp() async {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize SharedPreferences
    await SharedPreferences.getInstance();
  }
  
  // Helper methods
  static String get apiBaseUrl => '$baseUrl$apiVersion';
  
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': token != null ? 'Bearer $token' : '',
      'Accept-Language': 'ar',
    };
  }
}
