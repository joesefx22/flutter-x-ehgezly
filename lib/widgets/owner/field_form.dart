import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/stadium.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';

class FieldForm extends StatefulWidget {
  final Stadium? stadium;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;
  final bool isEditMode;

  const FieldForm({
    super.key,
    this.stadium,
    this.onSuccess,
    this.onCancel,
    this.isEditMode = false,
  });

  @override
  State<FieldForm> createState() => _FieldFormState();
}

class _FieldFormState extends State<FieldForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  // بيانات النموذج
  String _name = '';
  String _type = 'football';
  String _description = '';
  String _address = '';
  double _latitude = 0;
  double _longitude = 0;
  double _pricePerHour = 0;
  double _depositPercentage = 20;
  int _maxPlayers = 10;
  List<String> _features = [];
  List<String> _images = [];
  bool _isActive = true;
  
  // المميزات المتاحة
  final List<String> _availableFeatures = [
    'إضاءة',
    'خلع',
    'مقهى',
    'تأمين',
    'مواقف',
    'تدفئة',
    'تكييف',
    'متجر',
    'ملاعب متعددة',
    'تدريب',
  ];
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // البحث في المميزات
  String _featureSearchQuery = '';

  @override
  void initState() {
    super.initState();
    
    // تعبئة البيانات إذا كان في وضع التعديل
    if (widget.isEditMode && widget.stadium != null) {
      final stadium = widget.stadium!;
      _name = stadium.name;
      _type = stadium.type;
      _description = stadium.description ?? '';
      _address = stadium.address ?? '';
      _latitude = stadium.location?['lat'] ?? 0;
      _longitude = stadium.location?['lng'] ?? 0;
      _pricePerHour = stadium.pricePerHour;
      _depositPercentage = stadium.depositPercentage;
      _maxPlayers = stadium.maxPlayers;
      _features = List.from(stadium.features);
      _images = List.from(stadium.images);
      _isActive = stadium.isActive;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: استدعاء خدمة إضافة/تعديل الملعب
      await Future.delayed(Duration(seconds: 2)); // محاكاة للـ API
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                ? 'تم تعديل بيانات الملعب بنجاح!'
                : 'تم إضافة الملعب بنجاح!'
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في اختيار الصورة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _toggleFeature(String feature) {
    setState(() {
      if (_features.contains(feature)) {
        _features.remove(feature);
      } else {
        _features.add(feature);
      }
    });
  }

  List<String> get _filteredFeatures {
    if (_featureSearchQuery.isEmpty) return _availableFeatures;
    return _availableFeatures.where((feature) {
      return feature.toLowerCase().contains(_featureSearchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: widget.isEditMode ? 'تعديل ملعب' : 'إضافة ملعب جديد',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditMode
                  ? 'قم بتعديل بيانات الملعب'
                  : 'أدخل بيانات الملعب الجديد',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              
              // المعلومات الأساسية
              InputField(
                label: 'اسم الملعب',
                hintText: 'أدخل اسم الملعب',
                type: InputFieldType.text,
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الملعب';
                  }
                  return null;
                },
                onChanged: (value) => _name = value,
              ),
              
              SizedBox(height: 12),
              
              // نوع الملعب
              _buildTypeSection(),
              
              SizedBox(height: 12),
              
              // الوصف
              InputField(
                label: 'وصف الملعب (اختياري)',
                hintText: 'أدخل وصفاً للملعب',
                type: InputFieldType.multiline,
                initialValue: _description,
                maxLines: 3,
                onChanged: (value) => _description = value,
              ),
              
              SizedBox(height: 12),
              
              // العنوان
              InputField(
                label: 'عنوان الملعب',
                hintText: 'أدخل العنوان الكامل',
                type: InputFieldType.text,
                initialValue: _address,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال عنوان الملعب';
                  }
                  return null;
                },
                onChanged: (value) => _address = value,
              ),
              
              SizedBox(height: 16),
              
              // الموقع الجغرافي
              _buildLocationSection(),
              
              SizedBox(height: 16),
              
              // الأسعار والإعدادات
              _buildPricingSection(),
              
              SizedBox(height: 16),
              
              // المميزات
              _buildFeaturesSection(),
              
              SizedBox(height: 16),
              
              // الصور
              _buildImagesSection(),
              
              SizedBox(height: 16),
              
              // حالة الملعب
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
          text: widget.isEditMode ? 'حفظ التعديلات' : 'إضافة الملعب',
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
          'نوع الرياضة',
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
              child: ChoiceChip(
                label: Text('كرة قدم'),
                selected: _type == 'football',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _type = 'football');
                    // تحديث الحد الأقصى للاعبين افتراضياً
                    if (_maxPlayers > 22) _maxPlayers = 22;
                  }
                },
                selectedColor: Colors.green,
                labelStyle: TextStyle(
                  color: _type == 'football' ? Colors.white : Colors.black,
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: Text('بادل'),
                selected: _type == 'paddle',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _type = 'paddle');
                    // تحديث الحد الأقصى للاعبين افتراضياً
                    if (_maxPlayers > 4) _maxPlayers = 4;
                  }
                },
                selectedColor: Colors.blue,
                labelStyle: TextStyle(
                  color: _type == 'paddle' ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع الجغرافي',
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
                label: 'خط العرض',
                hintText: '0.0',
                type: InputFieldType.number,
                initialValue: _latitude.toString(),
                validator: (value) {
                  final lat = double.tryParse(value ?? '0') ?? 0;
                  if (lat < -90 || lat > 90) {
                    return 'خط العرض يجب أن يكون بين -90 و 90';
                  }
                  return null;
                },
                onChanged: (value) {
                  final lat = double.tryParse(value ?? '0') ?? 0;
                  setState(() => _latitude = lat);
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: InputField(
                label: 'خط الطول',
                hintText: '0.0',
                type: InputFieldType.number,
                initialValue: _longitude.toString(),
                validator: (value) {
                  final lng = double.tryParse(value ?? '0') ?? 0;
                  if (lng < -180 || lng > 180) {
                    return 'خط الطول يجب أن يكون بين -180 و 180';
                  }
                  return null;
                },
                onChanged: (value) {
                  final lng = double.tryParse(value ?? '0') ?? 0;
                  setState(() => _longitude = lng);
                },
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8),
        
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]),
          ),
          child: Row(
            children: [
              Icon(Icons.map, color: Colors.blue[800]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يمكنك استخدام خرائط Google للحصول على الإحداثيات الدقيقة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التسعير والإعدادات',
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
                label: 'سعر الساعة',
                hintText: '100',
                type: InputFieldType.number,
                initialValue: _pricePerHour.toString(),
                validator: (value) {
                  final price = double.tryParse(value ?? '0') ?? 0;
                  if (price <= 0) {
                    return 'يرجى إدخال سعر صحيح';
                  }
                  return null;
                },
                onChanged: (value) {
                  final price = double.tryParse(value ?? '0') ?? 0;
                  setState(() => _pricePerHour = price);
                },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: InputField(
                label: 'نسبة العربون %',
                hintText: '20',
                type: InputFieldType.number,
                initialValue: _depositPercentage.toString(),
                validator: (value) {
                  final percentage = double.tryParse(value ?? '0') ?? 0;
                  if (percentage < 0 || percentage > 100) {
                    return 'النسبة يجب أن تكون بين 0 و 100';
                  }
                  return null;
                },
                onChanged: (value) {
                  final percentage = double.tryParse(value ?? '0') ?? 0;
                  setState(() => _depositPercentage = percentage);
                },
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8),
        
        InputField(
          label: 'الحد الأقصى للاعبين',
          hintText: _type == 'football' ? '22' : '4',
          type: InputFieldType.number,
          initialValue: _maxPlayers.toString(),
          validator: (value) {
            final players = int.tryParse(value ?? '0') ?? 0;
            final maxForType = _type == 'football' ? 22 : 4;
            if (players < 1) {
              return 'يرجى إدخال عدد صحيح';
            }
            if (players > maxForType) {
              return 'الحد الأقصى لـ ${_type == 'football' ? 'كرة القدم' : 'البادل'} هو $maxForType';
            }
            return null;
          },
          onChanged: (value) {
            final players = int.tryParse(value ?? '0') ?? 0;
            setState(() => _maxPlayers = players);
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مميزات الملعب',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        // شريط البحث
        InputField(
          hintText: 'ابحث عن مميزات...',
          type: InputFieldType.text,
          prefixIcon: Icons.search,
          onChanged: (value) => setState(() => _featureSearchQuery = value),
        ),
        
        SizedBox(height: 8),
        
        // قائمة المميزات
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filteredFeatures.map((feature) {
            final isSelected = _features.contains(feature);
            return FilterChip(
              label: Text(feature),
              selected: isSelected,
              onSelected: (selected) => _toggleFeature(feature),
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
        
        SizedBox(height: 8),
        Text(
          'اختر المميزات المتاحة في ملعبك',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صور الملعب',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        // معرض الصور
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.grey[600]),
                          SizedBox(height: 4),
                          Text(
                            'إضافة صورة',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              
              final imageIndex = index - 1;
              final imagePath = _images[imageIndex];
              
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(imageIndex),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        
        SizedBox(height: 8),
        Text(
          'أضف صوراً واضحة للملعب (يُفضّل 3-5 صور)',
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
              'حالة الملعب',
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
                  'ملاحظات هامة:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• الصورة الرئيسية هي أول صورة في القائمة',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• يمكن تعديل المميزات في أي وقت',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber[800],
                  ),
                ),
                Text(
                  '• الملعب غير النشط لن يظهر في نتائج البحث',
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
