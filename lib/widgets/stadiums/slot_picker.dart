import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/stadium.dart';
import '../../providers/stadium_provider.dart';
import '../../utils/helpers.dart';
import '../common/day_chips.dart';
import '../common/slot_button.dart';
import 'package:flutter/material.dart';

class SlotPicker extends StatefulWidget {
  final Stadium stadium;
  final Function(DateTime?, StadiumSlot?) onSlotSelected;
  final DateTime? initialDate;
  final bool showDateOnly;
  final bool showHeader;

  const SlotPicker({
    super.key,
    required this.stadium,
    required this.onSlotSelected,
    this.initialDate,
    this.showDateOnly = false,
    this.showHeader = true,
  });

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  DateTime? _selectedDate;
  StadiumSlot? _selectedSlot;
  List<DateTime> _availableDates = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _loadAvailableDates();
  }

  void _loadAvailableDates() {
    final now = DateTime.now();
    _availableDates = [];
    
    // إنشاء قائمة 7 أيام قادمة
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      
      // التحقق إذا كان اليوم به مواعيد متاحة
      final hasSlots = widget.stadium.slots.any((slot) {
        return slot.date.year == date.year &&
               slot.date.month == date.month &&
               slot.date.day == date.day &&
               slot.isAvailable;
      });
      
      if (hasSlots) {
        _availableDates.add(date);
      }
    }
    
    // تحديد أول تاريخ متاح إذا لم يكن هناك تاريخ محدد
    if (_selectedDate == null && _availableDates.isNotEmpty) {
      _selectedDate = _availableDates.first;
    }
    
    setState(() {});
  }

  List<StadiumSlot> _getSlotsForSelectedDate() {
    if (_selectedDate == null) return [];
    
    return widget.stadium.slots.where((slot) {
      return slot.date.year == _selectedDate!.year &&
             slot.date.month == _selectedDate!.month &&
             slot.date.day == _selectedDate!.day;
    }).toList();
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = null;
    });
    
    if (widget.showDateOnly) {
      widget.onSlotSelected(_selectedDate, null);
    }
  }

  void _handleSlotSelected(StadiumSlot slot) {
    setState(() {
      _selectedSlot = slot;
    });
    
    widget.onSlotSelected(_selectedDate, slot);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slots = _getSlotsForSelectedDate();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          _buildHeader(theme),
          SizedBox(height: 16),
        ],
        
        // اختيار التاريخ
        DayChips(
          dates: _availableDates,
          selectedDate: _selectedDate,
          onDateSelected: _handleDateSelected,
          showTodayBadge: true,
          compactMode: false,
        ),
        
        SizedBox(height: 16),
        
        // اختيار الموعد
        if (!widget.showDateOnly && _selectedDate != null) ...[
          _buildSlotsSection(theme, slots),
        ],
        
        if (!widget.showDateOnly && _selectedDate != null && _selectedSlot != null) 
          _buildSelectedSlotInfo(theme),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر موعد الحجز',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'حدد التاريخ والوقت المناسبين',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsSection(ThemeData theme, List<StadiumSlot> slots) {
    if (slots.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: theme.hintColor,
            ),
            SizedBox(height: 12),
            Text(
              'لا توجد مواعيد متاحة في هذا اليوم',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'يرجى اختيار يوم آخر',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المواعيد المتاحة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return SlotButton(
              slot: slot,
              isSelected: _selectedSlot?.id == slot.id,
              onSelected: () => _handleSlotSelected(slot),
              showPrice: true,
              compactMode: false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedSlotInfo(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الموعد المحدد',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${Helpers.formatDate(_selectedDate!)} - ${_selectedSlot!.startTime.format(context)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedSlot!.price > 0)
                  Text(
                    'السعر: ${Helpers.formatCurrency(_selectedSlot!.price)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedSlot = null;
              });
              widget.onSlotSelected(_selectedDate, null);
            },
            tooltip: 'إلغاء الاختيار',
          ),
        ],
      ),
    );
  }
}
