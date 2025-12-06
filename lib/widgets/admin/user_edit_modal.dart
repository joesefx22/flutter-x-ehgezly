import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';

class UserEditModal extends StatefulWidget {
  final User user;
  final List<String> availableRoles;
  final List<String> availableStadiums;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const UserEditModal({
    super.key,
    required this.user,
    this.availableRoles = const [],
    this.availableStadiums = const [],
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<UserEditModal> createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  final _formKey = GlobalKey<FormState>();
  
  // بيانات النموذج
  String _name = '';
  String _phone = '';
  String _email = '';
  List<String> _roles = [];
  String _primaryRole = '';
  List<String> _stadiums = [];
  bool _isActive = true;
  bool _isVerified = true;
  bool _changePassword = false;
  String _newPassword = '';
  String _confirmPassword = '';
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // البحث في الأدوار والملاعب
  String _roleSearchQuery = '';
  String _stadiumSearchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // تعبئة بيانات المستخدم
    _name = widget.user.name;
    _phone = widget.user.phone ?? '';
    _email = widget.user.email ?? '';
    _roles = List.from(widget.user.roles);
    _primaryRole = widget.user.primaryRole;
    _stadiums = List.from(widget.user.stadiums ?? []);
    _isActive = widget.user.isActive;
    _isVerified = widget.user.isVerified ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_changePassword && _newPassword != _confirmPassword) {
      setState(() {
        _errorMessage = 'كلمات المرور غير متطابقة';
      });
      return;
    }
    
    if (_changePassword && _newPassword.length < 6) {
      setState(() {
        _errorMessage = 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: استدعاء خدمة تعديل المستخدم
      await Future.delayed(Duration(seconds: 1)); // محاكاة للـ API
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعديل بيانات المستخدم بنجاح!'),
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

  void _toggleRole(String role) {
    setState(() {
      if (_roles.contains(role)) {
        _roles.remove(role);
        if (_primaryRole == role && _roles.isNotEmpty) {
          _primaryRole = _roles.first;
        }
      } else {
        _roles.add(role);
        if (_primaryRole.isEmpty) {
          _primaryRole = role;
        }
      }
    });
  }

  void _setPrimaryRole(String role) {
    if (_roles.contains(role)) {
      setState(() => _primaryRole = role);
    }
  }

  void _toggleStadium(String stadiumId) {
    setState(() {
      if (_stadiums.contains(stadiumId)) {
        _stadiums.remove(stadiumId);
      } else {
        _stadiums.add(stadiumId);
      }
    });
  }

  List<String> get _filteredRoles {
    if (_roleSearchQuery.isEmpty) return widget.availableRoles;
    return widget.availableRoles.where((role) {
      return role.toLowerCase().contains(_roleSearchQuery.toLowerCase());
    }).toList();
  }

  List<String> get _filteredStadiums {
    if (_stadiumSearchQuery.isEmpty) return widget.availableStadiums;
    return widget.availableStadiums.where((stadium) {
      return stadium.toLowerCase().contains(_stadiumSearchQuery.toLowerCase());
    }).toList();
  }

  String _getRoleLabel(String role) {
    final labels = {
      'player': 'لاعب',
      'staff': 'موظف',
      'owner': 'مالك',
      'admin': 'مدير',
    };
    return labels[role] ?? role;
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: 'تعديل مستخدم',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'قم بتعديل بيانات المستخدم وإعداداته',
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
                label: 'البريد الإلكتروني',
                hintText: 'example@email.com',
                type: InputFieldType.email,
                initialValue: _email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  return null;
                },
                onChanged: (value) => _email = value,
              ),
              
              SizedBox(height: 16),
              
              // تغيير كلمة المرور
              _buildPasswordSection(),
              
              SizedBox(height: 16),
              
              // الأدوار
              _buildRolesSection(),
              
              SizedBox(height: 16),
              
              // الملاعب (إذا كان موظفاً أو مالكاً)
              if (_roles.contains('staff') || _roles.contains('owner'))
                _buildStadiumsSection(),
              
              SizedBox(height: 16),
              
              // الحالة والتحقق
              _buildStatusSection(),
              
              SizedBox(height: 16),
              
              // معلومات إضافية
              _buildAdditionalInfo(),
              
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
          text: 'حفظ التعديلات',
          onPressed: _submitForm,
          type: ButtonType.primary,
          isLoading: _isLoading,
        ),
      ],
      isLoading: _isLoading,
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: _changePassword,
              onChanged: (value) => setState(() => _changePassword = value),
              activeColor: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 8),
            Text(
              'تغيير كلمة المرور',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        
        if (_changePassword) ...[
          SizedBox(height: 12),
          
          InputField(
            label: 'كلمة المرور الجديدة',
            hintText: 'أدخل كلمة المرور الجديدة',
            type: InputFieldType.password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال كلمة المرور';
              }
              return null;
            },
            onChanged: (value) => _newPassword = value,
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
          
          SizedBox(height: 8),
          Text(
            'سيتم إرسال كلمة المرور الجديدة للمستخدم عبر الرسائل',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRolesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأدوار',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        // شريط البحث
        if (widget.availableRoles.length > 4)
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: InputField(
              hintText: 'ابحث عن أدوار...',
              type: InputFieldType.text,
              prefixIcon: Icons.search,
              onChanged: (value) => setState(() => _roleSearchQuery = value),
            ),
          ),
        
        // قائمة الأدوار
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filteredRoles.map((role) {
            final hasRole = _roles.contains(role);
            final isPrimary = _primaryRole == role;
            
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isPrimary 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey[300]!,
                  width: isPrimary ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: hasRole 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: hasRole,
                    onChanged: (value) => _toggleRole(role),
                  ),
                  Text(_getRoleLabel(role)),
                  if (hasRole)
                    IconButton(
                      icon: Icon(
                        isPrimary ? Icons.star : Icons.star_border,
                        size: 16,
                        color: isPrimary ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () => _setPrimaryRole(role),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        
        SizedBox(height: 8),
        Text(
          'يمكن للمستخدم أن يكون له عدة أدوار، حدد الدور الأساسي بنجمة',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
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
              onChanged: (value) => setState(() => _stadiumSearchQuery = value),
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
                  final isSelected = _stadiums.contains(stadiumId);
                  
                  return CheckboxListTile(
                    title: Text(stadiumId),
                    value: isSelected,
                    onChanged: (value) => _toggleStadium(stadiumId),
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
                'لا توجد ملاعب متاحة',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        
        SizedBox(height: 8),
        Text(
          'يمكن للموظف أو المالك إدارة الحجوزات في الملاعب المحددة فقط',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
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
        SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeColor: Colors.green,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'نشط',
                        style: TextStyle(
                          color: _isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'الحساب النشط يمكنه تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _isVerified,
                        onChanged: (value) => setState(() => _isVerified = value),
                        activeColor: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'موثق',
                        style: TextStyle(
                          color: _isVerified ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'الحساب الموثق له صلاحيات كاملة',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات إضافية:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          
          if (widget.user.createdAt != null)
            _buildInfoRow('تاريخ الإنشاء', Helpers.formatDateTime(widget.user.createdAt!)),
          
          if (widget.user.lastLogin != null)
            _buildInfoRow('آخر دخول', Helpers.formatDateTime(widget.user.lastLogin!)),
          
          _buildInfoRow('عدد الأدوار', '${_roles.length}'),
          
          if (_roles.contains('staff') || _roles.contains('owner'))
            _buildInfoRow('عدد الملاعب', '${_stadiums.length}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
          Icon(Icons.warning, color: Colors.amber[800]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحذيرات هامة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• تغيير الأدوار قد يؤثر على صلاحيات المستخدم',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• تعطيل الحساب يمنع المستخدم من تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• إلغاء التوثيق يحد من صلاحيات المستخدم',
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
