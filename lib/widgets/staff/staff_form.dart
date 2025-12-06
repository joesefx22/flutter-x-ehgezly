import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';

class StaffForm extends StatefulWidget {
  final User? staff;
  final List<String> availableStadiums;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool isEditMode;

  const StaffForm({
    super.key,
    this.staff,
    this.availableStadiums = const [],
    this.onSuccess,
    this.onCancel,
    this.isEditMode = false,
  });

  @override
  State<StaffForm> createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  final _formKey = GlobalKey<FormState>();
  
  // بيانات النموذج
  String _name = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  List<String> _selectedStadiums = [];
  bool _isActive = true;
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // البحث في الملاعب
  String _searchQuery = '';
  List<String> get _filteredStadiums {
    if (_searchQuery.isEmpty) return widget.availableStadiums;
    return widget.availableStadiums.where((stadium) {
      return stadium.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    
    // تعبئة البيانات إذا كان في وضع التعديل
    if (widget.isEditMode && widget.staff != null) {
      _name = widget.staff!.name;
      _phone = widget.staff!.phone ?? '';
      _email = widget.staff!.email ?? '';
      _isActive = widget.staff!.isActive;
      _selectedStadiums = List.from(widget.staff!.stadiums ?? []);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!widget.isEditMode && _password != _confirmPassword) {
      setState(() {
        _errorMessage = 'كلمات المرور غير متطابقة';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: استدعاء خدمة إضافة/تعديل الموظف
      await Future.delayed(Duration(seconds: 1)); // محاكاة للـ API
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                ? 'تم تعديل بيانات الموظف بنجاح!'
                : 'تم إضافة الموظف بنجاح!'
            ),
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

  void _toggleStadiumSelection(String stadiumId) {
    setState(() {
      if (_selectedStadiums.contains(stadiumId)) {
        _selectedStadiums.remove(stadiumId);
      } else {
        _selectedStadiums.add(stadiumId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: widget.isEditMode ? 'تعديل موظف' : 'إضافة موظف جديد',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditMode
                  ? 'قم بتعديل بيانات الموظف'
                  : 'أدخل بيانات الموظف الجديد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              
              // المعلومات الأساسية
              InputField(
                label: 'الاسم الكامل',
                hintText: 'أدخل الاسم الكامل',
                type: InputFieldType.text,
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              
              SizedBox(height: 12),
              
              InputField(
                label: 'رقم الهاتف',
                hintText: '01XXXXXXXXX',
                type: InputFieldType.phone,
                initialValue: _phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  if (!Helpers.isValidPhone(value)) {
                    return 'رقم هاتف غير صالح';
                  }
                  return null;
                },
                onChanged: (value) => _phone = value,
              ),
              
              SizedBox(height: 12),
              
              InputField(
                label: 'البريد الإلكتروني (اختياري)',
                hintText: 'example@email.com',
                type: InputFieldType.email,
                initialValue: _email,
                onChanged: (value) => _email = value,
              ),
              
              // كلمة المرور (فقط عند الإضافة)
              if (!widget.isEditMode) ...[
                SizedBox(height: 12),
                
                InputField(
                  label: 'كلمة المرور',
                  hintText: 'أدخل كلمة المرور',
                  type: InputFieldType.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                  onChanged: (value) => _password = value,
                ),
                
                SizedBox(height: 12),
                
                InputField(
                  label: 'تأكيد كلمة المرور',
                  hintText: 'أعد إدخال كلمة المرور',
                  type: InputFieldType.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى تأكيد كلمة المرور';
                    }
                    return null;
                  },
                  onChanged: (value) => _confirmPassword = value,
                ),
              ],
              
              SizedBox(height: 16),
              
              // اختيار الملاعب
              _buildStadiumsSection(),
              
              SizedBox(height: 16),
              
              // حالة النشاط
              _buildStatusSection(),
              
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
          text: widget.isEditMode ? 'حفظ التعديلات' : 'إضافة الموظف',
          onPressed: _submitForm,
          type: ButtonType.primary,
          isLoading: _isLoading,
        ),
      ],
      isLoading: _isLoading,
    );
  }

  Widget _buildStadiumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملاعب المسؤول عنها',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        // شريط البحث
        if (widget.availableStadiums.length > 5)
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: InputField(
              hintText: 'ابحث عن ملاعب...',
              type: InputFieldType.text,
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        
        // قائمة الملاعب
        if (widget.availableStadiums.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredStadiums.length,
                itemBuilder: (context, index) {
                  final stadiumId = _filteredStadiums[index];
                  final isSelected = _selectedStadiums.contains(stadiumId);
                  
                  return CheckboxListTile(
                    title: Text(stadiumId),
                    value: isSelected,
                    onChanged: (value) => _toggleStadiumSelection(stadiumId),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    secondary: Icon(
                      Icons.sports_soccer,
                      color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'لا توجد ملاعب متاحة للتخصيص',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        
        SizedBox(height: 8),
        Text(
          'يمكن للموظف إدارة الحجوزات في الملاعب المحددة فقط',
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
              'حالة الحساب',
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
                  'معلومات مهمة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.isEditMode
                    ? 'سيتم إرسال إشعار للموظف بالتعديلات'
                    : 'سيتم إرسال كلمة المرور للموظف عبر الرسائل',
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
