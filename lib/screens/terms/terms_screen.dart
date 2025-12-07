import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  static const routeName = '/terms';
  
  const TermsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشروط والأحكام'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'شروط وأحكام استخدام تطبيق "احجزلي"',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSection(
              title: '1. القبول',
              content: 'باستخدامك تطبيق "احجزلي"، فإنك توافق على الالتزام بهذه الشروط والأحكام.',
            ),
            
            _buildSection(
              title: '2. تعريفات',
              content: '''
"التطبيق": يشير إلى تطبيق "احجزلي" للهواتف المحمولة.
"المستخدم": أي شخص يستخدم التطبيق.
"الملعب": المنشأة الرياضية المعروضة في التطبيق.
"الحجز": عملية حجز ملعب عبر التطبيق.
''',
            ),
            
            _buildSection(
              title: '3. التسجيل',
              content: '''
- يجب أن تكون 18 عاماً أو أكثر لاستخدام التطبيق.
- أنت مسؤول عن الحفاظ على سرية حسابك وكلمة المرور.
- أنت مسؤول عن جميع الأنشطة التي تحدث تحت حسابك.
''',
            ),
            
            _buildSection(
              title: '4. الحجوزات',
              content: '''
- الحجوزات تعتمد على توفر الملاعب.
- يمكنك إلغاء الحجز قبل 2 ساعة من الموعد.
- بعد ذلك، قد يتم تطبيق رسوم إلغاء.
- يحق للملعب رفض الحجز إذا لم يحضر المستخدم في الوقت المحدد.
''',
            ),
            
            _buildSection(
              title: '5. المدفوعات',
              content: '''
- جميع المدفوعات تتم عبر بوابات دفع آمنة.
- الأسعار تشمل الضرائب المطبقة.
- يتم خصم العربون عند الحجز والباقي يدفع في الملعب.
- الاسترداد يكون وفق سياسة الملعب.
''',
            ),
            
            _buildSection(
              title: '6. إلغاء الحساب',
              content: '''
- يمكنك إلغاء حسابك في أي وقت.
- سيتم حذف بياناتك الشخصية خلال 30 يوماً.
- الحجوزات النشطة تمنع إلغاء الحساب.
''',
            ),
            
            _buildSection(
              title: '7. المسؤولية',
              content: '''
- التطبيق ليس مسؤولاً عن أي إصابات تحدث أثناء استخدام الملاعب.
- المستخدم يتحمل المسؤولية الكاملة عن سلامته.
- التطبيق وسيط فقط بين المستخدم ومالك الملعب.
''',
            ),
            
            _buildSection(
              title: '8. التعديلات',
              content: '''
- نحتفظ بالحق في تعديل هذه الشروط في أي وقت.
- سيتم إعلام المستخدمين بأي تغييرات جوهرية.
- الاستمرار في استخدام التطبيق بعد التعديلات يعني الموافقة عليها.
''',
            ),
            
            _buildSection(
              title: '9. القانون الحاكم',
              content: '''
تخضع هذه الشروط والأحكام لقوانين جمهورية مصر العربية.
أي نزاعات تحل عبر المحاكم المصرية المختصة.
''',
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'آخر تحديث: 1 يناير 2024',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
