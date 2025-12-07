import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ehgezly_app/services/notification_service.dart';
import 'package:ehgezly_app/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final NotificationService _notificationService = NotificationService();
  
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      await _setupPushNotifications();
    } catch (e) {
      debugPrint('FirebaseService.initialize error: $e');
    }
  }
  
  static Future<void> _setupPushNotifications() async {
    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      debugPrint('User granted permission: ${settings.authorizationStatus}');
      
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
        await _notificationService.subscribeToPushNotifications(token);
      }
      
      // Listen for messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
      
    } catch (e) {
      debugPrint('FirebaseService._setupPushNotifications error: $e');
    }
  }
  
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Received foreground message: ${message.notification?.title}');
    
    // Show local notification
    _showLocalNotification(message);
    
    // Update notifications in provider
    // Note: You'll need to access provider through navigator key or similar
  }
  
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Received background message: ${message.notification?.title}');
    
    // Update notifications when app is opened from background
    // Note: You'll need to refresh notifications when app resumes
  }
  
  static void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    
    if (notification != null) {
      // You can use flutter_local_notifications package here
      // For simplicity, we'll just show a snackbar if we have context
      debugPrint('Local Notification: ${notification.title} - ${notification.body}');
    }
  }
  
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('FirebaseService.getFCMToken error: $e');
      return null;
    }
  }
  
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('FirebaseService.subscribeToTopic error: $e');
    }
  }
  
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('FirebaseService.unsubscribeFromTopic error: $e');
    }
  }
  
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('FirebaseService.deleteToken error: $e');
    }
  }
}
