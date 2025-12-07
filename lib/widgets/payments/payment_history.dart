import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PaymentHistory extends StatelessWidget {
  final List<PaymentTransaction> transactions;
  final bool isLoading;
  final VoidCallback onLoadMore;
  
  const PaymentHistory({
    super.key,
    required this.transactions,
    this.isLoading = false,
    required this.onLoadMore,
  });
  
  @override
  Widget build(BuildContext context) {
    if (isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text('لا توجد معاملات سابقة'),
          ],
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length + (isLoading ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == transactions.length) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final transaction = transactions[index];
        return _buildTransactionCard(context, transaction);
      },
    );
  }
  
  Widget _buildTransactionCard(BuildContext context, PaymentTransaction transaction) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: transaction.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.statusText,
                  style: TextStyle(
                    color: transaction.statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                Helpers.formatCurrency(transaction.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow('رقم المعاملة', transaction.id.substring(0, 8)),
          _buildInfoRow('طريقة الدفع', transaction.paymentMethod),
          _buildInfoRow('التاريخ', Helpers.formatDate(transaction.createdAt)),
          
          if (transaction.bookingId != null)
            _buildInfoRow('رقم الحجز', transaction.bookingId!.substring(0, 8)),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for PaymentTransaction
class PaymentTransaction {
  final String id;
  final double amount;
  final String status; // success, failed, pending, refunded
  final String paymentMethod; // card, wallet, cash, bank
  final DateTime createdAt;
  final String? bookingId;
  final String? voucherCode;
  
  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.bookingId,
    this.voucherCode,
  });
  
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
}
