import 'package:flutter/material.dart';
import 'package:ehgezly_app/models/notification.dart' as notif;
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();
  
  Future<List<notif.Notification>> getNotifications({
    String? userId,
    bool? unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final params = {
        if (userId != null) 'userId': userId,
        if (unreadOnly != null) 'unreadOnly': unreadOnly.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: params,
      );
      
      if (response.success) {
        final List data = response.data['notifications'] ?? [];
        return data.map((item) => notif.Notification.fromJson(item)).toList();
      }
      
      throw Exception('Failed to load notifications');
    } catch (e) {
      debugPrint('NotificationService.getNotifications error: $e');
      rethrow;
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.patch(
        '/notifications/$notificationId/read',
        data: {'isRead': true},
      );
    } catch (e) {
      debugPrint('NotificationService.markAsRead error: $e');
      rethrow;
    }
  }
  
  Future<void> markAllAsRead(String userId) async {
    try {
      await _apiClient.post(
        '/notifications/mark-all-read',
        data: {'userId': userId},
      );
    } catch (e) {
      debugPrint('NotificationService.markAllAsRead error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('/notifications/$notificationId');
    } catch (e) {
      debugPrint('NotificationService.deleteNotification error: $e');
      rethrow;
    }
  }
  
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _apiClient.get(
        '/notifications/unread-count',
        queryParameters: {'userId': userId},
      );
      
      if (response.success) {
        return response.data['count'] ?? 0;
      }
      
      return 0;
    } catch (e) {
      debugPrint('NotificationService.getUnreadCount error: $e');
      return 0;
    }
  }
  
  // Send notification (for admin/staff)
  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    String? userId,
    String? stadiumId,
    String? bookingId,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _apiClient.post(
        '/notifications/send',
        data: {
          'title': title,
          'body': body,
          'type': type,
          if (userId != null) 'userId': userId,
          if (stadiumId != null) 'stadiumId': stadiumId,
          if (bookingId != null) 'bookingId': bookingId,
          if (data != null) 'data': data,
        },
      );
    } catch (e) {
      debugPrint('NotificationService.sendNotification error: $e');
      rethrow;
    }
  }
  
  // Subscribe to push notifications
  Future<void> subscribeToPushNotifications(String fcmToken) async {
    try {
      await _apiClient.post(
        '/notifications/subscribe',
        data: {'fcmToken': fcmToken},
      );
    } catch (e) {
      debugPrint('NotificationService.subscribeToPushNotifications error: $e');
      rethrow;
    }
  }
  
  // Unsubscribe from push notifications
  Future<void> unsubscribeFromPushNotifications(String fcmToken) async {
    try {
      await _apiClient.post(
        '/notifications/unsubscribe',
        data: {'fcmToken': fcmToken},
      );
    } catch (e) {
      debugPrint('NotificationService.unsubscribeFromPushNotifications error: $e');
      rethrow;
    }
  }
}
