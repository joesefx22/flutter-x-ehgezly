import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/app.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/language_provider.dart';
import 'package:ehgezly_app/providers/theme_provider.dart';
import 'package:ehgezly_app/providers/notification_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/providers/payment_provider.dart';
import 'package:ehgezly_app/services/firebase_service.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize services
    await AppConstants.initializeApp();
    
    // Initialize Firebase (silently catch errors for development)
    try {
      await FirebaseService.initialize();
    } catch (e) {
      print('Firebase initialization failed: $e');
      // Continue without Firebase in development
    }
    
    runApp(
      MultiProvider(
        providers: [
          // Theme & Language Providers
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          
          // Auth Provider
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          
          // Notification Provider
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          
          // Stadium Provider
          ChangeNotifierProvider(create: (_) => StadiumProvider()),
          
          // Booking Provider
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          
          // Play Request Provider
          ChangeNotifierProvider(create: (_) => PlayRequestProvider()),
          
          // Payment Provider
          ChangeNotifierProvider(create: (_) => PaymentProvider()),
          
          // User Provider (for admin)
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const EhgezlyApp(),
      ),
    );
  } catch (e) {
    print('App initialization failed: $e');
    // Fallback to basic app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                Text(
                  'فشل في تهيئة التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Error: $e',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
