import 'package:flutter/foundation.dart';
import 'package:ehgezly_app/services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  Map<String, dynamic>? _paymentOrder;
  List<Map<String, dynamic>> _paymentMethods = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  Map<String, dynamic>? _selectedVoucher;
  bool _isProcessing = false;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  Map<String, dynamic> _paymentStats = {};

  Map<String, dynamic>? get paymentOrder => _paymentOrder;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  List<Map<String, dynamic>> get paymentHistory => _paymentHistory;
  Map<String, dynamic>? get selectedVoucher => _selectedVoucher;
  bool get isProcessing => _isProcessing;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  Map<String, dynamic> get paymentStats => _paymentStats;

  Future<Map<String, dynamic>> createPaymentOrder({
    required String bookingId,
    required double amount,
    String? voucherCode,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final order = await _paymentService.createPaymentOrder(
        bookingId: bookingId,
        amount: amount,
        voucherCode: voucherCode,
      );

      _paymentOrder = order;
      return order;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> processCardPayment({
    required String bookingId,
    required String cardToken,
    required double amount,
    bool saveCard = false,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final result = await _paymentService.processCardPayment(
        bookingId: bookingId,
        cardToken: cardToken,
        amount: amount,
        saveCard: saveCard,
      );

      _successMessage = 'تمت عملية الدفع بنجاح';
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> validateVoucher({
    required String code,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final voucher = await _paymentService.validateVoucher(
        code: code,
        amount: amount,
      );

      _selectedVoucher = voucher.toJson();
      return {
        'valid': true,
        'voucher': voucher.toJson(),
        'discountAmount': voucher.calculateDiscount(amount),
      };
    } catch (e) {
      _selectedVoucher = null;
      return {
        'valid': false,
        'error': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaymentMethods() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final methods = await _paymentService.getPaymentMethods();
      _paymentMethods = methods;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaymentHistory({
    int page = 1,
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final history = await _paymentService.getPaymentHistory(
        page: page,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
      );

      if (page == 1) {
        _paymentHistory = history;
      } else {
        _paymentHistory.addAll(history);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPaymentStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? stadiumId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stats = await _paymentService.getPaymentStats(
        fromDate: fromDate,
        toDate: toDate,
        stadiumId: stadiumId,
      );

      _paymentStats = stats;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedPaymentMethods() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final savedMethods = await _paymentService.getSavedPaymentMethods();
      _paymentMethods.addAll(savedMethods);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePaymentMethod({
    required String methodType,
    required Map<String, dynamic> methodData,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _paymentService.savePaymentMethod(
        methodType: methodType,
        methodData: methodData,
      );

      _successMessage = 'تم حفظ طريقة الدفع بنجاح';
      await loadSavedPaymentMethods();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> removePaymentMethod(String methodId) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _paymentService.removePaymentMethod(methodId);

      _successMessage = 'تم حذف طريقة الدفع بنجاح';
      _paymentMethods.removeWhere((method) => method['id'] == methodId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getPaymentStatus(String paymentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final status = await _paymentService.getPaymentStatus(paymentId);
      return status;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      await _paymentService.verifyPayment(
        paymentId: paymentId,
        transactionId: transactionId,
      );

      _successMessage = 'تم التحقق من الدفع بنجاح';
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    double? amount,
    String? reason,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final result = await _paymentService.refundPayment(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );

      _successMessage = 'تم استرداد المبلغ بنجاح';
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> generatePaymentLink({
    required String bookingId,
    required double amount,
    String? returnUrl,
  }) async {
    try {
      _isProcessing = true;
      _error = null;
      notifyListeners();

      final paymentUrl = await _paymentService.generatePaymentLink(
        bookingId: bookingId,
        amount: amount,
        returnUrl: returnUrl,
      );

      return paymentUrl;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void clearVoucher() {
    _selectedVoucher = null;
    notifyListeners();
  }

  void clearPaymentOrder() {
    _paymentOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  void clearAll() {
    _paymentOrder = null;
    _selectedVoucher = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  double calculateDiscount(double amount) {
    if (_selectedVoucher != null) {
      final voucher = Voucher.fromJson(_selectedVoucher!);
      return voucher.calculateDiscount(amount);
    }
    return 0.0;
  }

  double calculateFinalAmount(double amount) {
    final discount = calculateDiscount(amount);
    return amount - discount;
  }
}
