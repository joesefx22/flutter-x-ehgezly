import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/input_field.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/widgets/staff/staff_form.dart';
import 'package:ehgezly_app/widgets/staff/staff_card.dart';
import 'package:ehgezly_app/widgets/owner/owner_stats_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:ehgezly_app/utils/validators.dart';
import 'dart:async';

class StadiumManagementScreen extends StatefulWidget {
  final String stadiumId;
  
  const StadiumManagementScreen({
    Key? key,
    required this.stadiumId,
  }) : super(key: key);

  @override
  _StadiumManagementScreenState createState() => _StadiumManagementScreenState();
}

class _StadiumManagementScreenState extends State<StadiumManagementScreen> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  Stadium? _stadium;
  List<User> _staff = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;
  bool _isEditMode = false;
  
  // Controllers للنماذج
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  
  // المميزات المتاحة
  final Map<String, bool> _features = {
    'إضاءة': false,
    'غرف خلع': false,
    'مقهى': false,
    'باركينج': false,
    'تدفئة': false,
    'تكييف': false,
    'مقاعد': false,
    'دوش': false,
    'تدليك': false,
    'حضانة': false,
    'واي فاي': false,
    'شاشات': false,
    'معدات': false,
    'حكم': false,
    'إسعافات أولية': false,
  };
  
  // أيام العمل
  final Map<String, Map<String, dynamic>> _workingDays = {
    'الأحد': {'enabled': true, 'open': '08:00', 'close': '22:00'},
    'الإثنين': {'enabled': true, 'open': '08:00', 'close': '22:00'},
    'الثلاثاء': {'enabled': true, 'open': '08:00', 'close': '22:00'},
    'الأربعاء': {'enabled': true, 'open': '08:00', 'close': '22:00'},
    'الخميس': {'enabled': true, 'open': '08:00', 'close': '22:00'},
    'الجمعة': {'enabled': false, 'open': '14:00', 'close': '23:00'},
    'السبت': {'enabled': true, 'open': '08:00', 'close': '22:00'},
  };
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
    _loadStadiumData();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تحميل البيانات إذا تغير stadiumId
    final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
    if (_stadium == null || _stadium!.id != widget.stadiumId) {
      _loadStadiumData();
    }
  }
  
  Future<void> _loadStadiumData() async {
    try {
      setState(() => _isLoading = true);
      
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // جلب بيانات الملعب
      _stadium = await stadiumProvider.getStadiumById(widget.stadiumId);
      
      if (_stadium == null) {
        throw Exception('الملعب غير موجود');
      }
      
      // التحقق من ملكية الملعب
      if (_stadium!.ownerId != authProvider.user!.id) {
        throw Exception('ليس لديك صلاحية الوصول لهذا الملعب');
      }
      
      // جلب الموظفين
      _staff = await stadiumProvider.getStadiumStaff(widget.stadiumId);
      
      // جلب إحصائيات الملعب
      final bookings = await bookingProvider.getStadiumBookings(widget.stadiumId);
      final todayBookings = bookings.where((b) => 
        DateTime.parse(b.date).day == DateTime.now().day &&
        b.status == 'confirmed'
      ).length;
      
      final monthlyRevenue = bookings.where((b) =>
        DateTime.parse(b.date).month == DateTime.now().month
      ).fold(0.0, (sum, b) => sum + b.amount);
      
      _stats = {
        'todayBookings': todayBookings,
        'todayRevenue': todayBookings * _stadium!.pricePerHour,
        'monthlyRevenue': monthlyRevenue,
        'occupancyRate': _stadium!.occupancyRate ?? 0.0,
        'totalBookings': bookings.length,
        'averageRating': _stadium!.averageRating ?? 0.0,
      };
      
      // تعبئة البيانات في الـ controllers
      _nameController.text = _stadium!.name;
      _descriptionController.text = _stadium!.description ?? '';
      _addressController.text = _stadium!.address;
      _priceController.text = _stadium!.pricePerHour.toString();
      _depositController.text = _stadium!.depositPercentage.toString();
      
      // تعبئة المميزات
      if (_stadium!.features.isNotEmpty) {
        for (var feature in _stadium!.features) {
          if (_features.containsKey(feature)) {
            _features[feature] = true;
          }
        }
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading stadium data: $e');
      setState(() => _isLoading = false);
      Helpers.showErrorSnackbar(context, 'فشل في تحميل بيانات الملعب');
      Navigator.pop(context); // العودة للشاشة السابقة
    }
  }
  
  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }
  
  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغييرات غير محفوظة'),
        content: const Text('لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تجاهل'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    ) ?? false;
  }
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      setState(() => _isLoading = true);
      
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      
      // تجميع المميزات المختارة
      final selectedFeatures = _features.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
      
      // إنشاء كائن الملعب المحدث
      final updatedStadium = _stadium!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
        address: _addressController.text,
        pricePerHour: double.parse(_priceController.text),
        depositPercentage: double.parse(_depositController.text),
        features: selectedFeatures,
      );
      
      // حفظ التغييرات
      await stadiumProvider.updateStadium(updatedStadium);
      
      setState(() {
        _stadium = updatedStadium;
        _hasUnsavedChanges = false;
        _isEditMode = false;
        _isLoading = false;
      });
      
      Helpers.showSuccessSnackbar(context, 'تم حفظ التغييرات بنجاح');
    } catch (e) {
      setState(() => _isLoading = false);
      Helpers.showErrorSnackbar(context, 'فشل في حفظ التغييرات');
    }
  }
  
  Widget _buildBasicInfoTab() {
    if (_isEditMode) {
      return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InputField(
              label: 'اسم الملعب',
              controller: _nameController,
              validator: Validators.required,
              onChanged: (_) => _markAsChanged(),
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'وصف الملعب (اختياري)',
              controller: _descriptionController,
              maxLines: 3,
              onChanged: (_) => _markAsChanged(),
            ),
            const SizedBox(height: 16),
            InputField(
              label: 'العنوان',
              controller: _addressController,
              validator: Validators.required,
              onChanged: (_) => _markAsChanged(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'سعر الساعة (ج.م)',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    validator: Validators.positiveNumber,
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    label: 'نسبة العربون (%)',
                    controller: _depositController,
                    keyboardType: TextInputType.number,
                    validator: Validators.percentage,
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'إلغاء',
                    onPressed: () {
                      setState(() {
                        _isEditMode = false;
                        _hasUnsavedChanges = false;
                        _resetForm();
                      });
                    },
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'حفظ',
                    onPressed: _saveChanges,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _stadium?.name ?? '',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        _stadium?.type == 'football' ? 'كرة قدم' : 'بادل',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _stadium?.type == 'football' 
                          ? Colors.blue 
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_stadium?.description?.isNotEmpty ?? false) ...[
                  Text(
                    _stadium!.description!,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _stadium?.address ?? '',
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${Helpers.formatCurrency(_stadium?.pricePerHour ?? 0)} / ساعة',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Icon(Icons.percent, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'عربون ${_stadium?.depositPercentage?.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المميزات',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () {
                        _showFeaturesDialog();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getSelectedFeatures().map((feature) {
                    return Chip(
                      label: Text(feature),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'تعديل المعلومات',
          onPressed: () {
            setState(() => _isEditMode = true);
          },
          icon: Icons.edit,
        ),
      ],
    );
  }
  
  Widget _buildAdvancedSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'جدول العمل',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._workingDays.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Checkbox(
                          value: entry.value['enabled'],
                          onChanged: (value) {
                            setState(() {
                              _workingDays[entry.key]!['enabled'] = value!;
                              _markAsChanged();
                            });
                          },
                        ),
                        Expanded(child: Text(entry.key)),
                        if (entry.value['enabled']) ...[
                          Text(entry.value['open']),
                          const Text(' - '),
                          Text(entry.value['close']),
                        ] else ...[
                          const Text('مغلق', style: TextStyle(color: Colors.grey)),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                AppButton(
                  text: 'تعديل الجدول',
                  onPressed: _showScheduleDialog,
                  size: ButtonSize.small,
                  outlined: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إعدادات الحجز',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSettingItem(
                  'الحد الأدنى للحجز',
                  'ساعة واحدة',
                  Icons.timer,
                  () => _showBookingSettingsDialog(),
                ),
                _buildSettingItem(
                  'الحد الأقصى للاعبين',
                  '${_stadium?.maxPlayers ?? 22} لاعب',
                  Icons.people,
                  () => _showBookingSettingsDialog(),
                ),
                _buildSettingItem(
                  'فترة الإلغاء',
                  'قبل 24 ساعة',
                  Icons.cancel,
                  () => _showBookingSettingsDialog(),
                ),
                _buildSettingItem(
                  'حالة الملعب',
                  _stadium?.isActive ?? false ? 'نشط' : 'غير نشط',
                  Icons.power_settings_new,
                  () => _toggleStadiumStatus(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStaffTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'موظفين الملعب',
                style: Theme.of(context).textTheme.subtitle1?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: 'إضافة موظف',
                onPressed: _showAddStaffDialog,
                size: ButtonSize.small,
                icon: Icons.person_add,
              ),
            ],
          ),
        ),
        Expanded(
          child: _staff.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد موظفين بعد',
                        style: Theme.of(context).textTheme.bodyText1?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أضف موظفين لإدارة هذا الملعب',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _staff.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StaffCard(
                        staff: _staff[index],
                        onEdit: () => _editStaff(_staff[index]),
                        onRemove: () => _removeStaff(_staff[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            OwnerStatsCard(
              title: 'حجوزات اليوم',
              value: _stats['todayBookings'].toDouble(),
              icon: Icons.today,
              color: Colors.blue,
              compact: true,
            ),
            OwnerStatsCard(
              title: 'إيرادات اليوم',
              value: _stats['todayRevenue'].toDouble(),
              icon: Icons.attach_money,
              color: Colors.green,
              isCurrency: true,
              compact: true,
            ),
            OwnerStatsCard(
              title: 'إيرادات الشهر',
              value: _stats['monthlyRevenue'].toDouble(),
              icon: Icons.calendar_today,
              color: Colors.orange,
              isCurrency: true,
              compact: true,
            ),
            OwnerStatsCard(
              title: 'معدل الإشغال',
              value: _stats['occupancyRate'].toDouble(),
              icon: Icons.percent,
              color: Colors.purple,
              unit: '%',
              compact: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقارير سريعة',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildReportItem('تقرير اليوم', Icons.today, Colors.blue),
                _buildReportItem('تقرير الأسبوع', Icons.calendar_view_week, Colors.green),
                _buildReportItem('تقرير الشهر', Icons.calendar_view_month, Colors.orange),
                _buildReportItem('تقرير العملاء', Icons.people, Colors.purple),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'تصدير جميع التقارير',
          onPressed: _exportReports,
          icon: Icons.download,
        ),
      ],
    );
  }
  
  Widget _buildSettingItem(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(value),
      trailing: Icon(Icons.chevron_left, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
  
  Widget _buildReportItem(String title, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Icon(Icons.chevron_left, color: Colors.grey[400]),
      onTap: () => _showReportDetails(title),
    );
  }
  
  List<String> _getSelectedFeatures() {
    return _features.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  void _resetForm() {
    if (_stadium != null) {
      _nameController.text = _stadium!.name;
      _descriptionController.text = _stadium!.description ?? '';
      _addressController.text = _stadium!.address;
      _priceController.text = _stadium!.pricePerHour.toString();
      _depositController.text = _stadium!.depositPercentage.toString();
    }
  }
  
  void _showFeaturesDialog() {
    AppModal.show(
      context: context,
      title: 'تعديل المميزات',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _features.entries.map((entry) {
                  return FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (selected) {
                      setState(() => _features[entry.key] = selected);
                      _markAsChanged();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'إلغاء',
                      onPressed: () => Navigator.pop(context),
                      outlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'حفظ',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _showScheduleDialog() {
    AppModal.show(
      context: context,
      title: 'تعديل جدول العمل',
      content: const Text('هذه الميزة قيد التطوير'),
    );
  }
  
  void _showBookingSettingsDialog() {
    AppModal.show(
      context: context,
      title: 'إعدادات الحجز',
      content: const Text('هذه الميزة قيد التطوير'),
    );
  }
  
  void _toggleStadiumStatus() async {
    if (_stadium == null) return;
    
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_stadium!.isActive ? 'تعطيل الملعب' : 'تفعيل الملعب'),
        content: Text(_stadium!.isActive
            ? 'هل تريد تعطيل هذا الملعب مؤقتاً؟'
            : 'هل تريد تفعيل هذا الملعب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_stadium!.isActive ? 'تعطيل' : 'تفعيل'),
            style: TextButton.styleFrom(
              foregroundColor: _stadium!.isActive ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
        final updatedStadium = _stadium!.copyWith(
          isActive: !_stadium!.isActive,
        );
        
        await stadiumProvider.updateStadium(updatedStadium);
        
        setState(() {
          _stadium = updatedStadium;
          _isLoading = false;
        });
        
        Helpers.showSuccessSnackbar(
          context,
          _stadium!.isActive ? 'تم تفعيل الملعب' : 'تم تعطيل الملعب',
        );
      } catch (e) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في تغيير الحالة');
      }
    }
  }
  
  void _showAddStaffDialog() {
    AppModal.show(
      context: context,
      title: 'إضافة موظف',
      content: StaffForm(
        stadiumId: widget.stadiumId,
        onSuccess: (newStaff) {
          setState(() => _staff.add(newStaff));
          Navigator.pop(context);
          Helpers.showSuccessSnackbar(context, 'تم إضافة الموظف بنجاح');
        },
      ),
    );
  }
  
  void _editStaff(User staff) {
    AppModal.show(
      context: context,
      title: 'تعديل الموظف',
      content: StaffForm(
        stadiumId: widget.stadiumId,
        staff: staff,
        onSuccess: (updatedStaff) {
          setState(() {
            final index = _staff.indexWhere((s) => s.id == staff.id);
            if (index != -1) {
              _staff[index] = updatedStaff;
            }
          });
          Navigator.pop(context);
          Helpers.showSuccessSnackbar(context, 'تم تعديل الموظف بنجاح');
        },
      ),
    );
  }
  
  Future<void> _removeStaff(User staff) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إزالة الموظف'),
        content: const Text('هل أنت متأكد من إزالة هذا الموظف؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إزالة'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        
        final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
        await stadiumProvider.removeStaffFromStadium(widget.stadiumId, staff.id);
        
        setState(() {
          _staff.removeWhere((s) => s.id == staff.id);
          _isLoading = false;
        });
        
        Helpers.showSuccessSnackbar(context, 'تم إزالة الموظف بنجاح');
      } catch (e) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في إزالة الموظف');
      }
    }
  }
  
  void _showReportDetails(String reportType) {
    // TODO: Implement report details
  }
  
  void _exportReports() {
    // TODO: Implement export reports
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stadium?.name ?? 'إدارة الملعب'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'معلومات'),
            Tab(text: 'إعدادات'),
            Tab(text: 'موظفين'),
            Tab(text: 'تقارير'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildAdvancedSettingsTab(),
                _buildStaffTab(),
                _buildReportsTab(),
              ],
            ),
      floatingActionButton: _hasUnsavedChanges && _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('حفظ التغييرات'),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}
