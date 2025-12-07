import 'package:equatable/equatable.dart';

class PaymentTransaction extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String status; // pending, success, failed, refunded
  final String paymentMethod; // card, wallet, cash, bank
  final String? paymentGateway; // paymob, etc.
  final String? gatewayTransactionId;
  final String? voucherCode;
  final String? bookingId;
  final String? stadiumId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  
  const PaymentTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'EGP',
    required this.status,
    required this.paymentMethod,
    this.paymentGateway,
    this.gatewayTransactionId,
    this.voucherCode,
    this.bookingId,
    this.stadiumId,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });
  
  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentGateway: json['paymentGateway'],
      gatewayTransactionId: json['gatewayTransactionId'],
      voucherCode: json['voucherCode'],
      bookingId: json['bookingId'],
      stadiumId: json['stadiumId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      metadata: json['metadata'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      if (paymentGateway != null) 'paymentGateway': paymentGateway,
      if (gatewayTransactionId != null) 'gatewayTransactionId': gatewayTransactionId,
      if (voucherCode != null) 'voucherCode': voucherCode,
      if (bookingId != null) 'bookingId': bookingId,
      if (stadiumId != null) 'stadiumId': stadiumId,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
  
  // Helper methods
  Color get statusColor {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  String get statusText {
    switch (status) {
      case 'success':
        return 'ناجحة';
      case 'failed':
        return 'فاشلة';
      case 'pending':
        return 'قيد الانتظار';
      case 'refunded':
        return 'تم الاسترداد';
      default:
        return status;
    }
  }
  
  String get methodText {
    switch (paymentMethod) {
      case 'card':
        return 'بطاقة ائتمان';
      case 'wallet':
        return 'محفظة إلكترونية';
      case 'cash':
        return 'نقدي';
      case 'bank':
        return 'تحويل بنكي';
      default:
        return paymentMethod;
    }
  }
  
  bool get isSuccessful => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
  
  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    status,
    paymentMethod,
    bookingId,
    createdAt,
  ];
  
  PaymentTransaction copyWith({
    String? id,
    String? userId,
    double? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? paymentGateway,
    String? gatewayTransactionId,
    String? voucherCode,
    String? bookingId,
    String? stadiumId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      voucherCode: voucherCode ?? this.voucherCode,
      bookingId: bookingId ?? this.bookingId,
      stadiumId: stadiumId ?? this.stadiumId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
