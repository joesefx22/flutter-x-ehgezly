import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PaymentSuccessScreen extends StatelessWidget {
  static const routeName = '/payment/success';
  
  final String bookingId;
  final String transactionId;
  
  const PaymentSuccessScreen({
    super.key,
    required this.bookingId,
    required this.transactionId,
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
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'تم الدفع بنجاح!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'تم تأكيد حجزك بنجاح. ستتلقى تأكيداً بالبريد الإلكتروني والرسائل النصية.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Booking Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('رقم الحجز', bookingId.substring(0, 8)),
                    const SizedBox(height: 12),
                    _buildInfoRow('رقم المعاملة', transactionId.substring(0, 8)),
                    const SizedBox(height: 12),
                    _buildInfoRow('التاريخ', Helpers.formatDate(DateTime.now())),
                    const SizedBox(height: 12),
                    _buildInfoRow('الوقت', Helpers.formatTime(DateTime.now())),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Column(
                children: [
                  AppButton(
                    onPressed: () {
                      // Navigate to booking details
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/player/bookings',
                        (route) => false,
                      );
                    },
                    text: 'عرض تفاصيل الحجز',
                    size: ButtonSize.large,
                    type: ButtonType.primary,
                    fullWidth: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  AppButton(
                    onPressed: () {
                      // Share booking
                      _shareBooking(context);
                    },
                    text: 'مشاركة الحجز',
                    size: ButtonSize.large,
                    type: ButtonType.outline,
                    icon: Icons.share_outlined,
                    fullWidth: true,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                    child: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
  
  void _shareBooking(BuildContext context) {
    // TODO: Implement share functionality
    Helpers.showSuccessSnackbar(context, 'تم نسخ معلومات الحجز');
  }
}
