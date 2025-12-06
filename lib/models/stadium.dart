import 'package:equatable/equatable.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StadiumSlot {
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final bool isAvailable;
  final String? bookingId;
  final String? bookedBy;
  final bool isPeakHour;

  const StadiumSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.isAvailable = true,
    this.bookingId,
    this.bookedBy,
    this.isPeakHour = false,
  });

  factory StadiumSlot.fromJson(Map<String, dynamic> json) {
    return StadiumSlot(
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      bookingId: json['bookingId'] as String?,
      bookedBy: json['bookedBy'] as String?,
      isPeakHour: json['isPeakHour'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'isAvailable': isAvailable,
      'bookingId': bookingId,
      'bookedBy': bookedBy,
      'isPeakHour': isPeakHour,
    };
  }

  String get formattedTime => '$startTime - $endTime';
  String get formattedDate => Helpers.formatDate(date);
  double get depositAmount => price * 0.3; // 30% deposit
}

class Stadium extends Equatable {
  final String id;
  final String name;
  final String type; // 'football' or 'paddle'
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> images;
  final List<String> features;
  final double pricePerHour;
  final double depositPercentage;
  final String ownerId;
  final List<String> staffIds;
  final List<StadiumSlot> slots;
  final double rating;
  final int totalReviews;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Stadium({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.features,
    required this.pricePerHour,
    this.depositPercentage = 0.3,
    required this.ownerId,
    required this.staffIds,
    required this.slots,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      features: List<String>.from(json['features'] ?? []),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      depositPercentage: (json['depositPercentage'] as num? ?? 0.3).toDouble(),
      ownerId: json['ownerId'] as String,
      staffIds: List<String>.from(json['staffIds'] ?? []),
      slots: (json['slots'] as List<dynamic>?)
              ?.map((slot) => StadiumSlot.fromJson(slot as Map<String, dynamic>))
              .toList() ??
          [],
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      totalReviews: (json['totalReviews'] as int? ?? 0),
      isActive: json['isActive'] as bool? ?? true,
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
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'features': features,
      'pricePerHour': pricePerHour,
      'depositPercentage': depositPercentage,
      'ownerId': ownerId,
      'staffIds': staffIds,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'rating': rating,
      'totalReviews': totalReviews,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Stadium copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? features,
    double? pricePerHour,
    double? depositPercentage,
    String? ownerId,
    List<String>? staffIds,
    List<StadiumSlot>? slots,
    double? rating,
    int? totalReviews,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Stadium(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      features: features ?? this.features,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      depositPercentage: depositPercentage ?? this.depositPercentage,
      ownerId: ownerId ?? this.ownerId,
      staffIds: staffIds ?? this.staffIds,
      slots: slots ?? this.slots,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isFootball => type == 'football';
  bool get isPaddle => type == 'paddle';

  String get formattedPrice => Helpers.formatCurrency(pricePerHour);
  String get depositAmountFormatted =>
      Helpers.formatCurrency(pricePerHour * depositPercentage);

  String get mainImage => images.isNotEmpty ? images.first : '';

  List<StadiumSlot> get availableSlots =>
      slots.where((slot) => slot.isAvailable).toList();

  List<StadiumSlot> get todaySlots {
    final today = DateTime.now();
    return slots
        .where((slot) => Helpers.isSameDay(slot.date, today))
        .toList();
  }

  List<StadiumSlot> get slotsByDate {
    final Map<String, List<StadiumSlot>> grouped = {};
    for (final slot in slots) {
      final dateKey = Helpers.formatDate(slot.date);
      grouped.putIfAbsent(dateKey, () => []).add(slot);
    }
    return grouped.values.expand((x) => x).toList();
  }

  double get totalEarnings {
    final bookedSlots = slots.where((slot) => !slot.isAvailable);
    return bookedSlots.fold(0.0, (sum, slot) => sum + slot.price);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        address,
        latitude,
        longitude,
        images,
        features,
        pricePerHour,
        depositPercentage,
        ownerId,
        staffIds,
        slots,
        rating,
        totalReviews,
        isActive,
        createdAt,
        updatedAt,
      ];

  static const empty = Stadium(
    id: '',
    name: '',
    type: 'football',
    description: '',
    address: '',
    latitude: 0.0,
    longitude: 0.0,
    images: [],
    features: [],
    pricePerHour: 0.0,
    ownerId: '',
    staffIds: [],
    slots: [],
    createdAt: DateTime(2024),
  );
}
