import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/payment_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/payment/payment_methods.dart';
import 'package:ehgezly_app/widgets/payment/voucher_input.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment';
  
  final String bookingId;
  
  const PaymentScreen({
    super.key,
    required this.bookingId,
  });
  
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _voucherController = TextEditingController();
  String _selectedMethod = 'card';
  bool _isApplyingVoucher = false;
  bool _isProcessing = false;
  Voucher? _appliedVoucher;
  
  @override
  void initState() {
    super.initState();
    _loadBooking();
  }
  
  Future<void> _loadBooking() async {
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    await bookingProvider.loadBookingById(widget.bookingId);
  }
  
  Future<void> _applyVoucher(String code) async {
    if (code.isEmpty) return;
    
    setState(() => _isApplyingVoucher = true);
    
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
    final voucher = await paymentProvider.validateVoucher(
      code: code,
      bookingId: widget.bookingId,
    );
    
    setState(() {
      _isApplyingVoucher = false;
      _appliedVoucher = voucher;
    });
    
    if (voucher != null) {
      Helpers.showSuccessSnackbar(context, 'تم تطبيق الكود بنجاح');
    } else {
      Helpers.showErrorSnackbar(context, 'كود غير صالح أو منتهي الصلاحية');
    }
  }
  
  Future<void> _processPayment() async {
    final booking = Provider.of<BookingProvider>(context, listen: false)
        .getBookingById(widget.bookingId);
    
    if (booking == null) {
      Helpers.showErrorSnackbar(context, 'الحجز غير موجود');
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final result = await paymentProvider.processPayment(
        bookingId: widget.bookingId,
        amount: _calculateFinalAmount(booking),
        method: _selectedMethod,
        voucherCode: _appliedVoucher?.code,
      );
      
      if (result.success) {
        // Navigate to success screen
        Navigator.pushReplacementNamed(
          context,
          '/payment/success',
          arguments: {
            'bookingId': widget.bookingId,
            'transactionId': result.transactionId,
          },
        );
      } else {
        // Navigate to failed screen
        Navigator.pushReplacementNamed(
          context,
          '/payment/failed',
          arguments: {
            'bookingId': widget.bookingId,
            'error': result.error,
          },
        );
      }
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في عملية الدفع: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  double _calculateFinalAmount(Booking booking) {
    double finalAmount = booking.amount;
    
    if (_appliedVoucher != null) {
      switch (_appliedVoucher!.type) {
        case 'percentage':
          finalAmount = finalAmount * (1 - (_appliedVoucher!.value / 100));
          break;
        case 'fixed':
          finalAmount = finalAmount - _appliedVoucher!.value;
          break;
        case 'free':
          finalAmount = 0;
          break;
      }
    }
    
    return finalAmount > 0 ? finalAmount : 0;
  }
  
  Widget _buildBookingSummary() {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final booking = bookingProvider.getBookingById(widget.bookingId);
    
    if (booking == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الحجز',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          _buildSummaryRow('الملعب', booking.stadiumName),
          _buildSummaryRow('التاريخ', Helpers.formatDate(booking.date)),
          _buildSummaryRow('الوقت', booking.slot.startTime),
          _buildSummaryRow('عدد اللاعبين', booking.playersCount.toString()),
          
          const Divider(height: 24),
          
          _buildAmountRow(
            'السعر الإجمالي',
            Helpers.formatCurrency(booking.amount),
            isTotal: false,
          ),
          
          if (_appliedVoucher != null)
            _buildAmountRow(
              'خصم (${_appliedVoucher!.code})',
              '-${Helpers.formatCurrency(booking.amount - _calculateFinalAmount(booking))}',
              isTotal: false,
              isDiscount: true,
            ),
          
          _buildAmountRow(
            'المبلغ النهائي',
            Helpers.formatCurrency(_calculateFinalAmount(booking)),
            isTotal: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAmountRow(String label, String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 16,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVoucherSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كود الخصم',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          VoucherInput(
            controller: _voucherController,
            isLoading: _isApplyingVoucher,
            onApply: _applyVoucher,
            appliedVoucher: _appliedVoucher,
            onRemove: () {
              setState(() {
                _appliedVoucher = null;
                _voucherController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethods() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طريقة الدفع',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          
          PaymentMethods(
            selectedMethod: _selectedMethod,
            onMethodSelected: (method) {
              setState(() => _selectedMethod = method);
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isProcessing) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBookingSummary(),
            const SizedBox(height: 16),
            _buildVoucherSection(),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            
            // Payment Button
            AppButton(
              onPressed: _isProcessing ? null : _processPayment,
              text: 'ادفع الآن',
              isLoading: _isProcessing,
              size: ButtonSize.xlarge,
              type: ButtonType.primary,
              icon: Icons.lock_outline,
              fullWidth: true,
            ),
            
            const SizedBox(height: 8),
            
            // Cancel Button
            AppButton(
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              text: 'إلغاء',
              size: ButtonSize.xlarge,
              type: ButtonType.outline,
              fullWidth: true,
            ),
            
            const SizedBox(height: 20),
            
            // Security Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'مدفوعات آمنة ومشفرة',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
