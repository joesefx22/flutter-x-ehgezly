import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type; // booking, payment, play_request, system
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;
  final String? userId;
  final String? stadiumId;
  final String? bookingId;
  final String? playRequestId;
  
  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.userId,
    this.stadiumId,
    this.bookingId,
    this.playRequestId,
  });
  
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      data: json['data'],
      userId: json['userId'],
      stadiumId: json['stadiumId'],
      bookingId: json['bookingId'],
      playRequestId: json['playRequestId'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      if (data != null) 'data': data,
      if (userId != null) 'userId': userId,
      if (stadiumId != null) 'stadiumId': stadiumId,
      if (bookingId != null) 'bookingId': bookingId,
      if (playRequestId != null) 'playRequestId': playRequestId,
    };
  }
  
  // Helper methods
  IconData get icon {
    switch (type) {
      case 'booking':
        return Icons.calendar_today_outlined;
      case 'payment':
        return Icons.payment_outlined;
      case 'play_request':
        return Icons.group_outlined;
      case 'system':
        return Icons.notifications_outlined;
      default:
        return Icons.info_outline;
    }
  }
  
  Color get iconColor {
    switch (type) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'play_request':
        return Colors.orange;
      case 'system':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} يوم';
    } else {
      return '${difference.inDays ~/ 30} شهر';
    }
  }
  
  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    isRead,
    createdAt,
  ];
  
  Notification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    String? userId,
    String? stadiumId,
    String? bookingId,
    String? playRequestId,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      userId: userId ?? this.userId,
      stadiumId: stadiumId ?? this.stadiumId,
      bookingId: bookingId ?? this.bookingId,
      playRequestId: playRequestId ?? this.playRequestId,
    );
  }
}
