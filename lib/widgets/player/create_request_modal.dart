import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/play_request.dart';
import '../../models/stadium.dart';
import '../../providers/play_request_provider.dart';
import '../../services/play_request_service.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';
import '../stadiums/slot_picker.dart';

class CreateRequestModal extends StatefulWidget {
  final Stadium? stadium;
  final DateTime? initialDate;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const CreateRequestModal({
    super.key,
    this.stadium,
    this.initialDate,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<CreateRequestModal> createState() => _CreateRequestModalState();
}

class _CreateRequestModalState extends State<CreateRequestModal> {
  final _formKey = GlobalKey<FormState>();
  
  // بيانات النموذج
  Stadium? _selectedStadium;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _requiredPlayers = 2;
  String _ageGroup = '18-25';
  String _level = 'intermediate';
  String _notes = '';
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // قوائم الاختيار
  final List<String> _ageGroups = [
    'under_18',
    '18-25',
    '26-35',
    'over_35'
  ];
  
  final List<String> _levels = [
    'beginner',
    'intermediate',
    'advanced'
  ];
  
  final Map<String, String> _ageGroupLabels = {
    'under_18': 'تحت 18 سنة',
    '18-25': '18 - 25 سنة',
    '26-35': '26 - 35 سنة',
    'over_35': 'فوق 35 سنة',
  };
  
  final Map<String, String> _levelLabels = {
    'beginner': 'مبتدئ',
    'intermediate': 'متوسط',
    'advanced': 'محترف',
  };

  @override
  void initState() {
    super.initState();
    _selectedStadium = widget.stadium;
    _selectedDate = widget.initialDate;
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = PlayRequestService();
      final requestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      
      final request = PlayRequest(
        stadiumId: _selectedStadium?.id,
        stadiumName: _selectedStadium?.name,
        date: _selectedDate,
        time: _selectedTime,
        requiredPlayers: _requiredPlayers,
        ageGroup: _ageGroup,
        level: _level,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      final createdRequest = await requestService.createPlayRequest(request);
      
      // تحديث الـ provider
      requestProvider.addRequest(createdRequest);
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء طلب اللاعبين بنجاح!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        widget.onSuccess?.call();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء إنشاء الطلب: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final initialTime = _selectedTime ?? TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: 'طلب لاعبين',
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أنشئ طلباً للعب مع لاعبين آخرين',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 16),
              
              // اختيار الملعب (اختياري)
              _buildStadiumSection(),
              
              SizedBox(height: 16),
              
              // اختيار التاريخ والوقت
              _buildDateTimeSection(context),
              
              SizedBox(height: 16),
              
              // عدد اللاعبين المطلوبين
              InputField(
                label: 'عدد اللاعبين المطلوبين',
                hintText: '2',
                type: InputFieldType.number,
                initialValue: '2',
                validator: (value) {
                  final count = int.tryParse(value ?? '2') ?? 2;
                  if (count < 2) {
                    return 'الحد الأدنى 2 لاعبين';
                  }
                  if (count > 20) {
                    return 'الحد الأقصى 20 لاعب';
                  }
                  return null;
                },
                onChanged: (value) {
                  final count = int.tryParse(value ?? '2') ?? 2;
                  setState(() => _requiredPlayers = count);
                },
              ),
              
              SizedBox(height: 16),
              
              // الفئة العمرية
              _buildAgeGroupSection(),
              
              SizedBox(height: 16),
              
              // المستوى
              _buildLevelSection(),
              
              SizedBox(height: 16),
              
              // ملاحظات إضافية
              InputField(
                label: 'ملاحظات إضافية (اختياري)',
                hintText: 'أي ملاحظات أو متطلبات خاصة',
                type: InputFieldType.multiline,
                maxLines: 3,
                onChanged: (value) => _notes = value,
              ),
              
              SizedBox(height: 16),
              
              // رسالة تأكيد
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[800]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيظهر طلبك للاعبين الآخرين وسيمكنهم الانضمام إليه.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
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
          text: 'إنشاء الطلب',
          onPressed: _submitRequest,
          type: ButtonType.primary,
          isLoading: _isLoading,
        ),
      ],
      isLoading: _isLoading,
    );
  }

  Widget _buildStadiumSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملعب (اختياري)',
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
              Icon(
                Icons.sports_soccer,
                color: _selectedStadium != null 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[500],
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedStadium?.name ?? 'لم يتم تحديد ملعب',
                  style: TextStyle(
                    color: _selectedStadium != null 
                      ? Colors.black
                      : Colors.grey[500],
                  ),
                ),
              ),
              if (_selectedStadium != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedStadium = null),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'تحديد الملعب يساعد اللاعبين على معرفة مكان اللعب',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ والوقت',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        
        // اختيار التاريخ
        Container(
          padding: EdgeInsets.all(12),
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
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
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
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Text(
                    _selectedDate != null
                      ? Helpers.formatDate(_selectedDate!)
                      : 'لم يتم تحديد تاريخ',
                    style: TextStyle(
                      color: _selectedDate != null 
                        ? Colors.black 
                        : Colors.grey[500],
                    ),
                  ),
                ),
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedDate = null),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        // اختيار الوقت
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey[600]),
              SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Text(
                    _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'لم يتم تحديد وقت',
                    style: TextStyle(
                      color: _selectedTime != null 
                        ? Colors.black 
                        : Colors.grey[500],
                    ),
                  ),
                ),
              ),
              if (_selectedTime != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedTime = null),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        Text(
          'يمكنك ترك التاريخ والوقت فارغين إذا كنت مرناً',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildAgeGroupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفئة العمرية',
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
          children: _ageGroups.map((group) {
            final isSelected = _ageGroup == group;
            return ChoiceChip(
              label: Text(_ageGroupLabels[group] ?? group),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _ageGroup = group);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى اللعب',
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
          children: _levels.map((level) {
            final isSelected = _level == level;
            return ChoiceChip(
              label: Text(_levelLabels[level] ?? level),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _level = level);
                }
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
