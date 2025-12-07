import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ehgezly_app/services/firebase_service.dart';

class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.ehgezly.com';
  static const String apiVersion = 'v1';
  
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  
  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authSignup = '/auth/signup';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  
  static const String stadiums = '/stadiums';
  static const String stadiumsSearch = '/stadiums/search';
  static const String stadiumsAvailableSlots = '/stadiums/:id/slots/available';
  
  static const String bookings = '/bookings';
  static const String bookingsCreate = '/bookings/create';
  static const String bookingsCancel = '/bookings/:id/cancel';
  static const String bookingsConfirm = '/bookings/:id/confirm';
  
  static const String playRequests = '/play-requests';
  static const String playRequestsJoin = '/play-requests/:id/join';
  static const String playRequestsLeave = '/play-requests/:id/leave';
  
  static const String payments = '/payments';
  static const String paymentsCreateOrder = '/payments/create-order';
  static const String paymentsValidateVoucher = '/payments/validate-voucher';
  static const String paymentsWebhook = '/payments/webhook/paymob';
  
  static const String notifications = '/notifications';
  static const String notificationsMarkRead = '/notifications/:id/read';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  
  static const String users = '/users';
  static const String usersUpdateProfile = '/users/profile';
  static const String usersChangePassword = '/users/change-password';
  
  static const String adminReports = '/admin/reports';
  static const String adminUsers = '/admin/users';
  static const String adminVouchers = '/admin/vouchers';
  
  // Storage Keys
  static const String storageAuthToken = 'auth_token';
  static const String storageRefreshToken = 'refresh_token';
  static const String storageUserData = 'user_data';
  static const String storageThemeMode = 'theme_mode';
  static const String storageLanguage = 'language';
  static const String storageFcmToken = 'fcm_token';
  
  // App Constants
  static const String appName = 'احجزلي';
  static const String appVersion = '1.0.0';
  static const int apiTimeout = 30000; // 30 seconds
  static const int debounceTime = 500; // 500ms
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxPlayersPerBooking = 50;
  static const int maxImagesPerStadium = 10;
  
  // Booking Constants
  static const int bookingConfirmationTimeout = 10; // minutes
  static const int maxCancellationHours = 2; // hours before booking
  static const double defaultDepositPercentage = 30.0;
  
  // Payment Constants
  static const String currency = 'EGP';
  static const String currencySymbol = 'ج.م';
  static const List<String> supportedPaymentMethods = [
    'card',
    'wallet',
    'cash',
    'bank',
  ];
  
  // Time Constants
  static const int defaultSlotDuration = 60; // minutes
  static const List<String> weekDaysArabic = [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];
  
  // Location Constants
  static const double defaultMapZoom = 15.0;
  static const double maxSearchRadius = 50.0; // kilometers
  static const String defaultCountryCode = 'EG';
  static const String defaultCity = 'القاهرة';
  
  // Initialize app
  static Future<void> initializeApp() async {
    try {
      // Initialize shared preferences
      await SharedPreferences.getInstance();
      
      // Initialize other services if needed
    } catch (e) {
      print('AppConstants initialization error: $e');
      rethrow;
    }
  }
  
  // Helper methods
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static String getApiUrl(String endpoint, {Map<String, String>? params}) {
    String url = '$apiBaseUrl$endpoint';
    
    if (params != null && params.isNotEmpty) {
      final queryString = params.entries
          .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
          .join('&');
      url = '$url?$queryString';
    }
    
    return url;
  }
  
  static Map<String, String> getDefaultHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Validation regex patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^01[0-9]{9}$', // Egyptian phone numbers
  );
  
  static final RegExp passwordRegex = RegExp(
    r'^.{6,}$', // At least 6 characters
  );
  
  // Format constants
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayTimeFormat = 'hh:mm a';
}
