import 'package:flutter/material.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class SupportScreen extends StatelessWidget {
  static const routeName = '/help/support';
  
  const SupportScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الدعم والمساعدة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Methods
            const Text(
              'طرق الاتصال',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildContactMethod(
              context,
              icon: Icons.phone_outlined,
              title: 'الاتصال الهاتفي',
              description: '01234567890',
              onTap: () => Helpers.launchPhone('01234567890'),
            ),
            
            const SizedBox(height: 12),
            
            _buildContactMethod(
              context,
              icon: Icons.email_outlined,
              title: 'البريد الإلكتروني',
              description: 'support@ehgezly.com',
              onTap: () => Helpers.launchEmail('support@ehgezly.com'),
            ),
            
            const SizedBox(height: 12),
            
            _buildContactMethod(
              context,
              icon: Icons.chat_outlined,
              title: 'الدردشة المباشرة',
              description: 'متاحة 24/7',
              onTap: () {
                // TODO: Implement chat
              },
            ),
            
            const SizedBox(height: 24),
            
            // FAQ
            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildFAQItem(
              question: 'كيف يمكنني إلغاء الحجز؟',
              answer: 'يمكنك إلغاء الحجز من صفحة "حجوزاتي" قبل ساعتين من موعد الحجز.',
            ),
            
            _buildFAQItem(
              question: 'ماذا يحدث إذا تأخرت عن موعد الحجز؟',
              answer: 'يحق للملعب إلغاء الحجز بعد 15 دقيقة من التأخير.',
            ),
            
            _buildFAQItem(
              question: 'كيف يمكنني استرداد المبلغ؟',
              answer: 'يتم الاسترداد خلال 5-7 أيام عمل على نفس طريقة الدفع.',
            ),
            
            _buildFAQItem(
              question: 'كيف أتأكد من حجزي؟',
              answer: 'ستتلقى تأكيداً بالبريد والرسائل النصية بعد الدفع الناجح.',
            ),
            
            const SizedBox(height: 24),
            
            // Report Problem
            const Text(
              'الإبلاغ عن مشكلة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            AppButton(
              onPressed: () {
                _showReportProblemDialog(context);
              },
              text: 'الإبلاغ عن مشكلة',
              icon: Icons.report_problem_outlined,
              type: ButtonType.outline,
              fullWidth: true,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactMethod(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showReportProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن مشكلة'),
        content: const ReportProblemForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Submit report
              Navigator.pop(context);
              Helpers.showSuccessSnackbar(context, 'تم إرسال التقرير');
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}

class ReportProblemForm extends StatefulWidget {
  const ReportProblemForm({super.key});
  
  @override
  State<ReportProblemForm> createState() => _ReportProblemFormState();
}

class _ReportProblemFormState extends State<ReportProblemForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'technical';
  
  final categories = [
    {'value': 'technical', 'label': 'مشكلة تقنية'},
    {'value': 'payment', 'label': 'مشكلة في الدفع'},
    {'value': 'booking', 'label': 'مشكلة في الحجز'},
    {'value': 'other', 'label': 'أخرى'},
  ];
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField(
            value: _selectedCategory,
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category['value'],
                child: Text(category['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategory = value!);
            },
            decoration: const InputDecoration(
              labelText: 'نوع المشكلة',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'عنوان المشكلة',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال عنوان المشكلة';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'وصف المشكلة',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى وصف المشكلة';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
