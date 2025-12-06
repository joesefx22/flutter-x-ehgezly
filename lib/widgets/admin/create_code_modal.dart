import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';

class CreateCodeModal extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const CreateCodeModal({
    super.key,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<CreateCodeModal> createState() => _CreateCodeModalState();
}

class _CreateCodeModalState extends State<CreateCodeModal> {
  final _formKey = GlobalKey<FormState>();
  
  // بيانات النموذج
  String _code = '';
  String _type = 'percentage';
  double _value = 0;
  int _maxUses = 1;
  DateTime? _expiryDate;
  String _description = '';
  bool _isActive = true;
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // أنواع الكوبونات
  final List<String> _codeTypes = ['percentage', 'fixed', 'free'];
  final Map<String, String> _typeLabels = {
    'percentage': 'نسبة مئوية',
    'fixed': 'قيمة ثابتة',
    'free': 'مجاني',
  };
  
  final Map<String, String> _typeDescriptions = {
    'percentage': 'خصم بنسبة مئوية من المبلغ الإجمالي',
    'fixed': 'خصم بقيمة ثابتة من المبلغ الإجمالي',
    'free': 'حجز مجاني (يغطي كامل المبلغ)',
  };

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_type == 'percentage' && (_value <= 0 || _value > 100)) {
      setState(() {
        _errorMessage = 'النسبة المئوية يجب أن تكون بين 1 و 100';
      });
      return;
    }
    
    if (_type == 'fixed' && _value <= 0) {
      setState(() {
        _errorMessage = 'القيمة الثابتة يجب أن تكون أكبر من صفر';
      });
      return;
    }
    
    if (_type == 'free') {
      _value = 0;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: استدعاء خدمة إنشاء الكود
      await Future.delayed(Duration(seconds: 1)); // محاكاة للـ API
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الكود بنجاح!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        widget.onSuccess?.call();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'حدث خطأ: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = String.fromCharCodes(
      List.generate(8, (index) => chars.codeUnitAt((index * 7) % chars.length))
    );
    
    setState(() => _code = random);
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: 'إنشاء كود خصم',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أنشئ كود خصم جديد للحجوزات',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              
              // نوع الكود
              _buildTypeSection(),
              
              SizedBox(height: 16),
              
              // الكود
              _buildCodeSection(),
              
              SizedBox(height: 16),
              
              // القيمة
              if (_type != 'free') _buildValueSection(),
              
              SizedBox(height: 16),
              
              // عدد مرات الاستخدام
              InputField(
                label: 'عدد مرات الاستخدام',
                hintText: '1',
                type: InputFieldType.number,
                initialValue: _maxUses.toString(),
                validator: (value) {
                  final uses = int.tryParse(value ?? '1') ?? 1;
                  if (uses < 1) {
                    return 'يرجى إدخال عدد صحيح موجب';
                  }
                  return null;
                },
                onChanged: (value) {
                  final uses = int.tryParse(value ?? '1') ?? 1;
                  setState(() => _maxUses = uses);
                },
              ),
              
              SizedBox(height: 16),
              
              // تاريخ الانتهاء
              _buildExpirySection(context),
              
              SizedBox(height: 16),
              
              // الوصف
              InputField(
                label: 'وصف الكود (اختياري)',
                hintText: 'أدخل وصفاً للكود',
                type: InputFieldType.multiline,
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              
              SizedBox(height: 16),
              
              // حالة النشاط
              _buildStatusSection(),
              
              SizedBox(height: 16),
              
              // ملخص الكود
              _buildCodeSummary(),
              
              SizedBox(height: 16),
              
              // رسائل التنبيه
              _buildAlertMessages(),
              
              if (_errorMessage != null) ...[
                SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          text: 'إلغاء',
          onPressed: widget.onCancel,
          type: ButtonType.outline,
        ),
        SizedBox(width: 8),
        AppButton(
          text: 'إنشاء الكود',
          onPressed: _submitForm,
          type: ButtonType.primary,
          isLoading: _isLoading,
        ),
      ],
      isLoading: _isLoading,
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع الكود',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _codeTypes.map((type) {
            final isSelected = _type == type;
            return ChoiceChip(
              label: Text(_typeLabels[type] ?? type),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _type = type);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
        
        SizedBox(height: 8),
        Text(
          _typeDescriptions[_type] ?? '',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كود الخصم',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: InputField(
                hintText: 'أدخل الكود أو اتركه فارغاً للإنشاء التلقائي',
                type: InputFieldType.text,
                initialValue: _code,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 4) {
                    return 'الكود يجب أن يكون 4 أحرف على الأقل';
                  }
                  return null;
                },
                onChanged: (value) => _code = value,
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            SizedBox(width: 8),
            AppButton(
              text: 'إنشاء',
              onPressed: _generateRandomCode,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.autorenew,
            ),
          ],
        ),
        
        SizedBox(height: 8),
        Text(
          'يمكن إنشاء كود تلقائياً أو إدخال كود مخصص',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildValueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _type == 'percentage' ? 'نسبة الخصم %' : 'قيمة الخصم',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        InputField(
          hintText: _type == 'percentage' ? '10' : '50',
          type: InputFieldType.number,
          initialValue: _value.toString(),
          validator: (value) {
            final val = double.tryParse(value ?? '0') ?? 0;
            if (val <= 0) {
              return 'يرجى إدخال قيمة صحيحة';
            }
            return null;
          },
          onChanged: (value) {
            final val = double.tryParse(value ?? '0') ?? 0;
            setState(() => _value = val);
          },
          prefixIcon: _type == 'percentage' ? Icons.percent : Icons.attach_money,
        ),
        
        SizedBox(height: 8),
        Text(
          _type == 'percentage'
            ? 'سيتم تطبيق الخصم كنسبة مئوية من المبلغ الإجمالي'
            : 'سيتم خصم قيمة ثابتة من المبلغ الإجمالي',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildExpirySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تاريخ الانتهاء',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectExpiryDate(context),
                  child: Text(
                    _expiryDate != null
                      ? Helpers.formatDate(_expiryDate!)
                      : 'لم يتم تحديد تاريخ',
                    style: TextStyle(
                      color: _expiryDate != null 
                        ? Colors.black 
                        : Colors.grey[500],
                    ),
                  ),
                ),
              ),
              if (_expiryDate != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _expiryDate = null),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        Text(
          'يمكن ترك التاريخ فارغاً لجعل الكود صالحاً دائماً',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة الكود',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 2),
            Text(
              _isActive ? 'نشط' : 'غير نشط',
              style: TextStyle(
                fontSize: 12,
                color: _isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        Switch(
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildCodeSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الكود:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 8),
          
          _buildSummaryRow('الكود', _code.isEmpty ? 'سيتم إنشاؤه تلقائياً' : _code),
          _buildSummaryRow('النوع', _typeLabels[_type] ?? _type),
          
          if (_type != 'free')
            _buildSummaryRow(
              'القيمة',
              _type == 'percentage' 
                ? '$_value%'
                : '${Helpers.formatCurrency(_value)}',
            ),
          
          _buildSummaryRow('عدد المرات', '$_maxUses مرة'),
          
          _buildSummaryRow(
            'الانتهاء',
            _expiryDate != null
              ? Helpers.formatDate(_expiryDate!)
              : 'غير محدد',
          ),
          
          _buildSummaryRow('الحالة', _isActive ? 'نشط' : 'غير نشط'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMessages() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.amber[800]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معلومات هامة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• الكود يجب أن يكون فريداً ولا يتكرر',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• يمكن للمستخدم استخدام الكود مرة واحدة فقط',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• الكود غير النشط لن يكون صالحاً للاستخدام',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
