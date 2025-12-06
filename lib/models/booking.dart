import 'package:equatable/equatable.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class Booking extends Equatable {
  final String id;
  final String stadiumId;
  final String userId;
  final String stadiumName;
  final String userName;
  final String userPhone;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final double depositAmount;
  final double paidAmount;
  final String status; // pending, confirmed, cancelled, completed
  final String paymentStatus; // pending, partial, paid, refunded
  final int playersCount;
  final String? notes;
  final String? voucherCode;
  final double? discountAmount;
  final String? cancellationReason;
  final String? cancelledBy;
  final DateTime? cancelledAt;
  final String? paymentMethod;
  final String? paymentId;
  final DateTime? paymentDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Booking({
    required this.id,
    required this.stadiumId,
    required this.userId,
    required this.stadiumName,
    required this.userName,
    required this.userPhone,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    required this.depositAmount,
    required this.paidAmount,
    required this.status,
    required this.paymentStatus,
    this.playersCount = 1,
    this.notes,
    this.voucherCode,
    this.discountAmount,
    this.cancellationReason,
    this.cancelledBy,
    this.cancelledAt,
    this.paymentMethod,
    this.paymentId,
    this.paymentDate,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      stadiumId: json['stadiumId'] as String,
      userId: json['userId'] as String,
      stadiumName: json['stadiumName'] as String,
      userName: json['userName'] as String,
      userPhone: json['userPhone'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      status: json['status'] as String,
      paymentStatus: json['paymentStatus'] as String,
      playersCount: (json['playersCount'] as int? ?? 1),
      notes: json['notes'] as String?,
      voucherCode: json['voucherCode'] as String?,
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      cancellationReason: json['cancellationReason'] as String?,
      cancelledBy: json['cancelledBy'] as String?,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] as String?,
      paymentId: json['paymentId'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
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
      'userId': userId,
      'stadiumName': stadiumName,
      'userName': userName,
      'userPhone': userPhone,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'depositAmount': depositAmount,
      'paidAmount': paidAmount,
      'status': status,
      'paymentStatus': paymentStatus,
      'playersCount': playersCount,
      'notes': notes,
      'voucherCode': voucherCode,
      'discountAmount': discountAmount,
      'cancellationReason': cancellationReason,
      'cancelledBy': cancelledBy,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  Booking copyWith({
    String? id,
    String? stadiumId,
    String? userId,
    String? stadiumName,
    String? userName,
    String? userPhone,
    DateTime? date,
    String? startTime,
    String? endTime,
    double? totalAmount,
    double? depositAmount,
    double? paidAmount,
    String? status,
    String? paymentStatus,
    int? playersCount,
    String? notes,
    String? voucherCode,
    double? discountAmount,
    String? cancellationReason,
    String? cancelledBy,
    DateTime? cancelledAt,
    String? paymentMethod,
    String? paymentId,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Booking(
      id: id ?? this.id,
      stadiumId: stadiumId ?? this.stadiumId,
      userId: userId ?? this.userId,
      stadiumName: stadiumName ?? this.stadiumName,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      playersCount: playersCount ?? this.playersCount,
      notes: notes ?? this.notes,
      voucherCode: voucherCode ?? this.voucherCode,
      discountAmount: discountAmount ?? this.discountAmount,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentPartial => paymentStatus == 'partial';
  bool get isPaymentPaid => paymentStatus == 'paid';
  bool get isPaymentRefunded => paymentStatus == 'refunded';

  double get remainingAmount => totalAmount - paidAmount;
  double get discountPercentage => discountAmount != null
      ? (discountAmount! / totalAmount) * 100
      : 0.0;

  String get formattedDate => Helpers.formatDate(date);
  String get formattedTime => '$startTime - $endTime';
  String get formattedDateTime => '$formattedDate - $formattedTime';
  
  String get formattedTotalAmount => Helpers.formatCurrency(totalAmount);
  String get formattedPaidAmount => Helpers.formatCurrency(paidAmount);
  String get formattedRemainingAmount => Helpers.formatCurrency(remainingAmount);
  String get formattedDepositAmount => Helpers.formatCurrency(depositAmount);

  Color get statusColor => Helpers.getStatusColor(status);

  bool get canCancel {
    if (isCancelled) return false;
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(startTime.split(':')[0]),
    );
    final difference = bookingDateTime.difference(now);
    return difference.inHours > 2; // Can cancel up to 2 hours before
  }

  bool get canPay => isPending && remainingAmount > 0;

  @override
  List<Object?> get props => [
        id,
        stadiumId,
        userId,
        stadiumName,
        userName,
        userPhone,
        date,
        startTime,
        endTime,
        totalAmount,
        depositAmount,
        paidAmount,
        status,
        paymentStatus,
        playersCount,
        notes,
        voucherCode,
        discountAmount,
        cancellationReason,
        cancelledBy,
        cancelledAt,
        paymentMethod,
        paymentId,
        paymentDate,
        createdAt,
        updatedAt,
      ];

  static const empty = Booking(
    id: '',
    stadiumId: '',
    userId: '',
    stadiumName: '',
    userName: '',
    userPhone: '',
    date: DateTime(2024),
    startTime: '',
    endTime: '',
    totalAmount: 0.0,
    depositAmount: 0.0,
    paidAmount: 0.0,
    status: 'pending',
    paymentStatus: 'pending',
    createdAt: DateTime(2024),
  );
}
