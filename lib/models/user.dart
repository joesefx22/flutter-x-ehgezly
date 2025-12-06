import 'package:equatable/equatable.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final List<String> roles;
  final String primaryRole;
  final List<String> stadiums; // stadium IDs
  final String? profileImage;
  final bool isVerified;
  final DateTime? emailVerifiedAt;
  final DateTime? phoneVerifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fcmToken;
  final Map<String, dynamic>? metadata;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.roles,
    required this.primaryRole,
    required this.stadiums,
    this.profileImage,
    this.isVerified = false,
    this.emailVerifiedAt,
    this.phoneVerifiedAt,
    required this.createdAt,
    this.updatedAt,
    this.fcmToken,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] ?? ['player']),
      primaryRole: json['primaryRole'] as String? ?? 'player',
      stadiums: List<String>.from(json['stadiums'] ?? []),
      profileImage: json['profileImage'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.parse(json['emailVerifiedAt'] as String)
          : null,
      phoneVerifiedAt: json['phoneVerifiedAt'] != null
          ? DateTime.parse(json['phoneVerifiedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      fcmToken: json['fcmToken'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'roles': roles,
      'primaryRole': primaryRole,
      'stadiums': stadiums,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'phoneVerifiedAt': phoneVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'fcmToken': fcmToken,
      'metadata': metadata,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    List<String>? roles,
    String? primaryRole,
    List<String>? stadiums,
    String? profileImage,
    bool? isVerified,
    DateTime? emailVerifiedAt,
    DateTime? phoneVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      primaryRole: primaryRole ?? this.primaryRole,
      stadiums: stadiums ?? this.stadiums,
      profileImage: profileImage ?? this.profileImage,
      isVerified: isVerified ?? this.isVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      phoneVerifiedAt: phoneVerifiedAt ?? this.phoneVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isPlayer => roles.contains('player');
  bool get isStaff => roles.contains('staff');
  bool get isOwner => roles.contains('owner');
  bool get isAdmin => roles.contains('admin');

  bool get hasMultipleRoles => roles.length > 1;

  String get maskedPhone => Helpers.maskPhoneNumber(phone);

  String get formattedCreatedAt => Helpers.getRelativeTime(createdAt);

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        roles,
        primaryRole,
        stadiums,
        profileImage,
        isVerified,
        emailVerifiedAt,
        phoneVerifiedAt,
        createdAt,
        updatedAt,
        fcmToken,
      ];

  static const empty = User(
    id: '',
    name: '',
    phone: '',
    email: '',
    roles: [],
    primaryRole: 'player',
    stadiums: [],
    createdAt: DateTime(2024),
  );
}
