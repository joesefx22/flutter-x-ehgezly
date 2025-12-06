import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/stadium.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/input_field.dart';
import '../common/button.dart';
import '../stadiums/slot_picker.dart';

class BookingModal extends StatefulWidget {
  final Stadium stadium;
  final StadiumSlot? initialSlot;
  final DateTime? initialDate;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const BookingModal({
    super.key,
    required this.stadium,
    this.initialSlot,
    this.initialDate,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<BookingModal> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  
  // بيانات النموذج
  DateTime? _selectedDate;
  StadiumSlot? _selectedSlot;
  String _playerName = '';
  String _playerPhone = '';
  String _playerEmail = '';
  int _playersCount = 1;
  String _notes = '';
  
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // حسابات السعر
  double get _totalPrice {
    if (_selectedSlot == null) return 0;
    return _selectedSlot!.price * _playersCount;
  }
  
  double get _depositAmount {
    return _totalPrice * (widget.stadium.depositPercentage / 100);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDate = widget.initialDate;
    _selectedSlot = widget.initialSlot;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bookingService = BookingService();
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      final booking = Booking(
        stadiumId: widget.stadium.id,
        stadiumName: widget.stadium.name,
        date: _selectedDate!,
        slot: _selectedSlot!,
        playersCount: _playersCount,
        amount: _totalPrice,
        depositAmount: _depositAmount,
        playerName: _playerName,
        playerPhone: _playerPhone,
        playerEmail: _playerEmail.isNotEmpty ? _playerEmail : null,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      final createdBooking = await bookingService.createBooking(booking);
      
      // تحديث الـ provider
      bookingProvider.addBooking(createdBooking);
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء الحجز بنجاح!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        widget.onSuccess?.call();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء إنشاء الحجز: $error';
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _previousStep() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppModal(
      title: 'حجز ملعب',
      content: Column(
        children: [
          // خطوات الحجز
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'الموعد'),
              Tab(text: 'البيانات'),
              Tab(text: 'التأكيد'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          
          SizedBox(height: 16),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // الخطوة 1: اختيار الموعد
                _buildStep1(),
                
                // الخطوة 2: بيانات الحاجز
                _buildStep2(),
                
                // الخطوة 3: تأكيد الحجز
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
      actions: _buildActions(),
      isLoading: _isLoading,
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر تاريخ ووقت الحجز',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يرجى اختيار التاريخ والوقت المناسبين للحجز',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          
          SlotPicker(
            stadium: widget.stadium,
            onSlotSelected: (date, slot) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = slot;
              });
            },
            initialDate: _selectedDate,
            showHeader: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحاجز',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'يرجى تعبئة معلوماتك الشخصية',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            
            InputField(
              label: 'الاسم الكامل',
              hintText: 'أدخل اسمك الكامل',
              type: InputFieldType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال الاسم';
                }
                return null;
              },
              onChanged: (value) => _playerName = value,
            ),
            
            SizedBox(height: 12),
            
            InputField(
              label: 'رقم الهاتف',
              hintText: '01XXXXXXXXX',
              type: InputFieldType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                if (!Helpers.isValidPhone(value)) {
                  return 'رقم هاتف غير صالح';
                }
                return null;
              },
              onChanged: (value) => _playerPhone = value,
            ),
            
            SizedBox(height: 12),
            
            InputField(
              label: 'البريد الإلكتروني (اختياري)',
              hintText: 'example@email.com',
              type: InputFieldType.email,
              onChanged: (value) => _playerEmail = value,
            ),
            
            SizedBox(height: 12),
            
            InputField(
              label: 'عدد اللاعبين',
              hintText: '1',
              type: InputFieldType.number,
              initialValue: '1',
              validator: (value) {
                final count = int.tryParse(value ?? '1') ?? 1;
                if (count < 1) {
                  return 'عدد اللاعبين يجب أن يكون 1 على الأقل';
                }
                if (count > widget.stadium.maxPlayers) {
                  return 'الحد الأقصى ${widget.stadium.maxPlayers} لاعبين';
                }
                return null;
              },
              onChanged: (value) {
                final count = int.tryParse(value ?? '1') ?? 1;
                setState(() => _playersCount = count);
              },
            ),
            
            SizedBox(height: 12),
            
            InputField(
              label: 'ملاحظات إضافية (اختياري)',
              hintText: 'أي ملاحظات أو طلبات خاصة',
              type: InputFieldType.multiline,
              maxLines: 3,
              onChanged: (value) => _notes = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تأكيد الحجز',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يرجى مراجعة معلومات الحجز قبل التأكيد',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          
          // ملخص المعلومات
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildSummaryRow('الملعب', widget.stadium.name),
                _buildSummaryRow('التاريخ', Helpers.formatDate(_selectedDate!)),
                _buildSummaryRow('الوقت', 
                  '${_selectedSlot!.startTime.format(context)} - ${_selectedSlot!.endTime.format(context)}'),
                _buildSummaryRow('عدد اللاعبين', '$_playersCount'),
                _buildSummaryRow('اسم الحاجز', _playerName),
                _buildSummaryRow('هاتف الحاجز', _playerPhone),
                if (_playerEmail.isNotEmpty)
                  _buildSummaryRow('البريد الإلكتروني', _playerEmail),
                if (_notes.isNotEmpty)
                  _buildSummaryRow('ملاحظات', _notes),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // التفاصيل المالية
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildPriceRow('سعر الساعة', Helpers.formatCurrency(_selectedSlot!.price)),
                _buildPriceRow('عدد اللاعبين', 'x$_playersCount'),
                Divider(),
                _buildPriceRow('الإجمالي', Helpers.formatCurrency(_totalPrice), isBold: true),
                _buildPriceRow('العربون (${widget.stadium.depositPercentage}%)', 
                  Helpers.formatCurrency(_depositAmount)),
                Divider(),
                _buildPriceRow('المبلغ المستحق', 
                  Helpers.formatCurrency(_depositAmount), 
                  isBold: true, 
                  isPrimary: true),
              ],
            ),
          ),
          
          SizedBox(height: 8),
          
          // رسالة تأكيد
          Container(
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
                  child: Text(
                    'بعد تأكيد الحجز، ستحتاج لدفع العربون لتثبيت الموعد.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isPrimary = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isPrimary ? Theme.of(context).primaryColor : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      // زر الرجوع
      if (_tabController.index > 0)
        AppButton(
          text: 'رجوع',
          onPressed: _previousStep,
          type: ButtonType.outline,
        ),
      
      SizedBox(width: 8),
      
      // زر التالي/التأكيد
      AppButton(
        text: _tabController.index == 2 ? 'تأكيد الحجز' : 'التالي',
        onPressed: () {
          if (_tabController.index == 2) {
            _submitBooking();
          } else if (_tabController.index == 0 && (_selectedDate == null || _selectedSlot == null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('يرجى اختيار تاريخ ووقت للحجز')),
            );
          } else if (_tabController.index == 1 && !_formKey.currentState!.validate()) {
            // التحقق من صحة النموذج
          } else {
            _nextStep();
          }
        },
        type: _tabController.index == 2 ? ButtonType.success : ButtonType.primary,
        isLoading: _isLoading && _tabController.index == 2,
      ),
    ];
  }
}
