import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/common/button.dart';

class VoucherInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onApply;
  final Voucher? appliedVoucher;
  final VoidCallback onRemove;
  
  const VoucherInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onApply,
    this.appliedVoucher,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) {
    if (appliedVoucher != null) {
      return _buildAppliedVoucher(context);
    }
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'أدخل كود الخصم',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                onApply(value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          onPressed: () {
            final code = controller.text.trim();
            if (code.isNotEmpty) {
              onApply(code);
            }
          },
          text: 'تطبيق',
          isLoading: isLoading,
          size: ButtonSize.medium,
          type: ButtonType.outline,
        ),
      ],
    );
  }
  
  Widget _buildAppliedVoucher(BuildContext context) {
    final voucher = appliedVoucher!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.discount_outlined,
            color: Colors.green[700],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.code,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getVoucherDescription(voucher),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.green[700],
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
  
  String _getVoucherDescription(Voucher voucher) {
    switch (voucher.type) {
      case 'percentage':
        return 'خصم ${voucher.value}%';
      case 'fixed':
        return 'خصم ${voucher.value} جنيه';
      case 'free':
        return 'حجز مجاني';
      default:
        return 'خصم';
    }
  }
}

// Helper class for Voucher
class Voucher {
  final String code;
  final String type; // percentage, fixed, free
  final double value;
  
  Voucher({
    required this.code,
    required this.type,
    required this.value,
  });
}
