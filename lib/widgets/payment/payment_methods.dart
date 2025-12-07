import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PaymentMethods extends StatelessWidget {
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;
  
  const PaymentMethods({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final methods = [
      _PaymentMethod(
        id: 'card',
        title: 'بطاقة ائتمان/مدى',
        icon: Icons.credit_card_outlined,
        description: 'Visa, MasterCard, Mada',
      ),
      _PaymentMethod(
        id: 'wallet',
        title: 'المحفظة الإلكترونية',
        icon: Icons.account_balance_wallet_outlined,
        description: 'Paymob, Vodafone Cash, etc.',
      ),
      _PaymentMethod(
        id: 'cash',
        title: 'الدفع عند الوصول',
        icon: Icons.money_outlined,
        description: 'الدفع نقداً في الملعب',
      ),
      _PaymentMethod(
        id: 'bank',
        title: 'التحويل البنكي',
        icon: Icons.account_balance_outlined,
        description: 'تحويل مباشر للبنك',
      ),
    ];
    
    return Column(
      children: methods.map((method) {
        final isSelected = method.id == selectedMethod;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onMethodSelected(method.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      method.icon,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          method.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethod {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  
  _PaymentMethod({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
