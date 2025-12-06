import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class Voucher {
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final int usesLeft;
  final DateTime expiryDate;
  final String? description;
  final bool isActive;

  const Voucher({
    required this.code,
    required this.type,
    required this.value,
    required this.usesLeft,
    required this.expiryDate,
    this.description,
    this.isActive = true,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      usesLeft: json['usesLeft'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'usesLeft': usesLeft,
      'expiryDate': expiryDate.toIso8601String(),
      'description': description,
      'isActive': isActive,
    };
  }

  double calculateDiscount(double amount) {
    if (type == 'percentage') {
      return amount * (value / 100);
    } else {
      return value;
    }
  }

  bool get isValid => isActive && usesLeft > 0 && expiryDate.isAfter(DateTime.now());
}

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> createPaymentOrder({
    required String bookingId,
    required double amount,
    String? voucherCode,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${AppConstants.payments}/create-order',
      body: {
        'bookingId': bookingId,
        'amount': amount,
        if (voucherCode != null && voucherCode.isNotEmpty) 'voucherCode': voucherCode,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> processCardPayment({
    required String bookingId,
    required String cardToken,
    required double amount,
    bool saveCard = false,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${AppConstants.payments}/process-card',
      body: {
        'bookingId': bookingId,
        'cardToken': cardToken,
        'amount': amount,
        'saveCard': saveCard,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Voucher> validateVoucher({
    required String code,
    required double amount,
  }) async {
    final response = await _apiClient.post<Voucher>(
      '${AppConstants.payments}/validate-voucher',
      body: {
        'code': code,
        'amount': amount,
      },
      fromJson: (json) => Voucher.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.payments}/$paymentId/status',
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.payments}/verify',
      body: {
        'paymentId': paymentId,
        'transactionId': transactionId,
      },
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'paymentId': paymentId,
    };
    
    if (amount != null) body['amount'] = amount;
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;

    final response = await _apiClient.post<Map<String, dynamic>>(
      '${AppConstants.payments}/refund',
      body: body,
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await _apiClient.get<List<Map<String, dynamic>>>(
      '${AppConstants.payments}/methods',
      fromJson: (json) => (json as List<dynamic>)
          .map((method) => Map<String, dynamic>.from(method as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory({
    int page = 1,
    int limit = AppConstants.itemsPerPage,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (fromDate != null) {
      queryParameters['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParameters['toDate'] = toDate.toIso8601String();
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _apiClient.get<List<Map<String, dynamic>>>(
      '${AppConstants.payments}/history',
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((payment) => Map<String, dynamic>.from(payment as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getPaymentStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? stadiumId,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (fromDate != null) {
      queryParameters['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParameters['toDate'] = toDate.toIso8601String();
    }
    if (stadiumId != null) {
      queryParameters['stadiumId'] = stadiumId;
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.payments}/stats',
      queryParameters: queryParameters,
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> savePaymentMethod({
    required String methodType,
    required Map<String, dynamic> methodData,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.payments}/methods/save',
      body: {
        'methodType': methodType,
        'methodData': methodData,
      },
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<List<Map<String, dynamic>>> getSavedPaymentMethods() async {
    final response = await _apiClient.get<List<Map<String, dynamic>>>(
      '${AppConstants.payments}/methods/saved',
      fromJson: (json) => (json as List<dynamic>)
          .map((method) => Map<String, dynamic>.from(method as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> removePaymentMethod(String methodId) async {
    final response = await _apiClient.delete(
      '${AppConstants.payments}/methods/$methodId',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<String> generatePaymentLink({
    required String bookingId,
    required double amount,
    String? returnUrl,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${AppConstants.payments}/generate-link',
      body: {
        'bookingId': bookingId,
        'amount': amount,
        if (returnUrl != null && returnUrl.isNotEmpty) 'returnUrl': returnUrl,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!['paymentUrl'] as String;
    } else {
      throw Exception(response.message);
    }
  }
}
