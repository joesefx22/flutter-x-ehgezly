import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PaymentFailedScreen extends StatelessWidget {
  static const routeName = '/payment/failed';
  
  final String bookingId;
  final String error;
  
  const PaymentFailedScreen({
    super.key,
    required this.bookingId,
    required this.error,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Failed Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'فشل في الدفع',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              Text(
                error.isNotEmpty ? error : 'حدث خطأ أثناء عملية الدفع',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Common Errors
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الأسباب الشائعة:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildReason('• رصيد غير كافي في البطاقة'),
                    _buildReason('• بيانات البطاقة غير صحيحة'),
                    _buildReason('• تجاوز الحد اليومي للعمليات'),
                    _buildReason('• مشكلة في الاتصال بالبنك'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  AppButton(
                    onPressed: () {
                      // Retry payment
                      Navigator.pop(context);
                    },
                    text: 'إعادة المحاولة',
                    size: ButtonSize.large,
                    type: ButtonType.primary,
                    fullWidth: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AppButton(
                    onPressed: () {
                      // Try different method
                      Navigator.pushReplacementNamed(
                        context,
                        '/payment',
                        arguments: {'bookingId': bookingId},
                      );
                    },
                    text: 'طريقة دفع أخرى',
                    size: ButtonSize.large,
                    type: ButtonType.outline,
                    fullWidth: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/player/bookings',
                        (route) => false,
                      );
                    },
                    child: const Text('العودة للحجوزات'),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Contact Support
              InkWell(
                onTap: () {
                  Helpers.launchPhone('01234567890');
                },
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'اتصل بالدعم الفني',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReason(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
