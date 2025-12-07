import 'package:flutter/material.dart';
import 'package:ehgezly_app/services/notification_service.dart';
import 'package:ehgezly_app/models/notification.dart' as notif;

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<notif.Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  List<notif.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<notif.Notification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  
  List<notif.Notification> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();
  
  int get unreadCount => unreadNotifications.length;
  
  Future<void> loadNotifications({String? userId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _notifications = await _notificationService.getNotifications(
        userId: userId,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('NotificationProvider.loadNotifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('NotificationProvider.markAsRead error: $e');
      rethrow;
    }
  }
  
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllAsRead(userId);
      
      _notifications = _notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationProvider.markAllAsRead error: $e');
      rethrow;
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      debugPrint('NotificationProvider.deleteNotification error: $e');
      rethrow;
    }
  }
  
  Future<int> getUnreadCount(String userId) async {
    try {
      return await _notificationService.getUnreadCount(userId);
    } catch (e) {
      debugPrint('NotificationProvider.getUnreadCount error: $e');
      return 0;
    }
  }
  
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
      await _notificationService.sendNotification(
        title: title,
        body: body,
        type: type,
        userId: userId,
        stadiumId: stadiumId,
        bookingId: bookingId,
        data: data,
      );
    } catch (e) {
      debugPrint('NotificationProvider.sendNotification error: $e');
      rethrow;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
