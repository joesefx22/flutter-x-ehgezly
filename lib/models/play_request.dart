import 'package:equatable/equatable.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlayRequestJoiner {
  final String userId;
  final String userName;
  final String userPhone;
  final DateTime joinedAt;
  final String? notes;

  const PlayRequestJoiner({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.joinedAt,
    this.notes,
  });

  factory PlayRequestJoiner.fromJson(Map<String, dynamic> json) {
    return PlayRequestJoiner(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhone: json['userPhone'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'joinedAt': joinedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

class PlayRequest extends Equatable {
  final String id;
  final String stadiumId;
  final String? bookingId;
  final String creatorId;
  final String creatorName;
  final String creatorPhone;
  final String stadiumName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int requiredPlayers;
  final int currentPlayers;
  final String ageGroup; // under_18, 18_30, 30_45, over_45
  final String level; // beginner, intermediate, advanced, professional
  final String status; // open, partial, closed, cancelled
  final List<PlayRequestJoiner> joiners;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const PlayRequest({
    required this.id,
    required this.stadiumId,
    this.bookingId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorPhone,
    required this.stadiumName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.requiredPlayers,
    required this.currentPlayers,
    required this.ageGroup,
    required this.level,
    required this.status,
    required this.joiners,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory PlayRequest.fromJson(Map<String, dynamic> json) {
    return PlayRequest(
      id: json['id'] as String,
      stadiumId: json['stadiumId'] as String,
      bookingId: json['bookingId'] as String?,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      creatorPhone: json['creatorPhone'] as String,
      stadiumName: json['stadiumName'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      requiredPlayers: json['requiredPlayers'] as int,
      currentPlayers: json['currentPlayers'] as int,
      ageGroup: json['ageGroup'] as String,
      level: json['level'] as String,
      status: json['status'] as String,
      joiners: (json['joiners'] as List<dynamic>?)
              ?.map((joiner) =>
                  PlayRequestJoiner.fromJson(joiner as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stadiumId': stadiumId,
      'bookingId': bookingId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhone': creatorPhone,
      'stadiumName': stadiumName,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'requiredPlayers': requiredPlayers,
      'currentPlayers': currentPlayers,
      'ageGroup': ageGroup,
      'level': level,
      'status': status,
      'joiners': joiners.map((joiner) => joiner.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  PlayRequest copyWith({
    String? id,
    String? stadiumId,
    String? bookingId,
    String? creatorId,
    String? creatorName,
    String? creatorPhone,
    String? stadiumName,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? requiredPlayers,
    int? currentPlayers,
    String? ageGroup,
    String? level,
    String? status,
    List<PlayRequestJoiner>? joiners,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PlayRequest(
      id: id ?? this.id,
      stadiumId: stadiumId ?? this.stadiumId,
      bookingId: bookingId ?? this.bookingId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorPhone: creatorPhone ?? this.creatorPhone,
      stadiumName: stadiumName ?? this.stadiumName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      requiredPlayers: requiredPlayers ?? this.requiredPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      ageGroup: ageGroup ?? this.ageGroup,
      level: level ?? this.level,
      status: status ?? this.status,
      joiners: joiners ?? this.joiners,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isOpen => status == 'open';
  bool get isPartial => status == 'partial';
  bool get isClosed => status == 'closed';
  bool get isCancelled => status == 'cancelled';

  int get remainingPlayers => requiredPlayers - currentPlayers;
  double get completionPercentage => (currentPlayers / requiredPlayers) * 100;

  bool get isFull => currentPlayers >= requiredPlayers;
  bool get hasAvailableSpots => currentPlayers < requiredPlayers;

  String get formattedDate => Helpers.formatDate(date);
  String get formattedTime => '$startTime - $endTime';
  String get formattedDateTime => '$formattedDate - $formattedTime';

  String get ageGroupText {
    switch (ageGroup) {
      case 'under_18':
        return 'تحت 18 سنة';
      case '18_30':
        return '18 - 30 سنة';
      case '30_45':
        return '30 - 45 سنة';
      case 'over_45':
        return 'فوق 45 سنة';
      default:
        return ageGroup;
    }
  }

  String get levelText {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      case 'professional':
        return 'محترف';
      default:
        return level;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'closed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool hasUserJoined(String userId) {
    return joiners.any((joiner) => joiner.userId == userId);
  }

  bool get canJoin => isOpen && hasAvailableSpots;

  @override
  List<Object?> get props => [
        id,
        stadiumId,
        bookingId,
        creatorId,
        creatorName,
        creatorPhone,
        stadiumName,
        date,
        startTime,
        endTime,
        requiredPlayers,
        currentPlayers,
        ageGroup,
        level,
        status,
        joiners,
        notes,
        createdAt,
        updatedAt,
      ];

  static const empty = PlayRequest(
    id: '',
    stadiumId: '',
    creatorId: '',
    creatorName: '',
    creatorPhone: '',
    stadiumName: '',
    date: DateTime(2024),
    startTime: '',
    endTime: '',
    requiredPlayers: 0,
    currentPlayers: 0,
    ageGroup: '18_30',
    level: 'intermediate',
    status: 'open',
    joiners: [],
    createdAt: DateTime(2024),
  );
}
