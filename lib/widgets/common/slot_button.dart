import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';
import 'package:ehgezly_app/utils/helpers.dart';

enum SlotStatus {
  available,    // متاح
  booked,       // محجوز
  selected,     // محدد
  unavailable,  // غير متاح
  peakHour,     // ساعة ذروة
  passed,       // مضت
  myBooking,    // حجز خاص بي
}

class SlotButton extends StatelessWidget {
  final String startTime;
  final String endTime;
  final double price;
  final SlotStatus status;
  final VoidCallback? onPressed;
  final bool showPrice;
  final bool showDuration;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool showPeakIcon;
  final bool showBookedIcon;
  final String? bookedBy;
  final bool isToday;
  final DateTime? date;

  const SlotButton({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.onPressed,
    this.showPrice = true,
    this.showDuration = true,
    this.width = 100,
    this.height = 70,
    this.borderRadius,
    this.padding,
    this.showPeakIcon = true,
    this.showBookedIcon = true,
    this.bookedBy,
    this.isToday = false,
    this.date,
  }) : super(key: key);

  Color _getBackgroundColor() {
    switch (status) {
      case SlotStatus.available:
        return AppThemes.successColor.withOpacity(0.1);
      case SlotStatus.selected:
        return AppThemes.primaryColor.withOpacity(0.2);
      case SlotStatus.booked:
        return AppThemes.errorColor.withOpacity(0.1);
      case SlotStatus.unavailable:
        return AppThemes.lightDivider;
      case SlotStatus.peakHour:
        return AppThemes.warningColor.withOpacity(0.1);
      case SlotStatus.passed:
        return AppThemes.lightDivider;
      case SlotStatus.myBooking:
        return AppThemes.primaryColor.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case SlotStatus.available:
        return AppThemes.successColor;
      case SlotStatus.selected:
        return AppThemes.primaryColor;
      case SlotStatus.booked:
        return AppThemes.errorColor;
      case SlotStatus.unavailable:
        return AppThemes.lightDivider;
      case SlotStatus.peakHour:
        return AppThemes.warningColor;
      case SlotStatus.passed:
        return AppThemes.lightDivider;
      case SlotStatus.myBooking:
        return AppThemes.primaryColor;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case SlotStatus.available:
        return AppThemes.successColor;
      case SlotStatus.selected:
        return AppThemes.primaryColor;
      case SlotStatus.booked:
        return AppThemes.errorColor;
      case SlotStatus.unavailable:
        return AppThemes.lightTextSecondary;
      case SlotStatus.peakHour:
        return AppThemes.warningColor;
      case SlotStatus.passed:
        return AppThemes.lightTextSecondary;
      case SlotStatus.myBooking:
        return AppThemes.primaryColor;
    }
  }

  String _getStatusText() {
    switch (status) {
      case SlotStatus.available:
        return 'متاح';
      case SlotStatus.selected:
        return 'محدد';
      case SlotStatus.booked:
        return 'محجوز';
      case SlotStatus.unavailable:
        return 'غير متاح';
      case SlotStatus.peakHour:
        return 'ذروة';
      case SlotStatus.passed:
        return 'مضت';
      case SlotStatus.myBooking:
        return 'حجزك';
    }
  }

  Widget? _getStatusIcon() {
    switch (status) {
      case SlotStatus.peakHour:
        return showPeakIcon
            ? const Icon(Icons.whatshot_outlined, size: 12)
            : null;
      case SlotStatus.booked:
        return showBookedIcon
            ? const Icon(Icons.lock_outline, size: 12)
            : null;
      case SlotStatus.myBooking:
        return const Icon(Icons.check_circle_outline, size: 12);
      default:
        return null;
    }
  }

  bool get isEnabled {
    return status == SlotStatus.available ||
           status == SlotStatus.peakHour ||
           status == SlotStatus.myBooking;
  }

  bool get isInteractive {
    return isEnabled && onPressed != null;
  }

  String _formatTime(String time) {
    // Convert 24h to 12h format
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        if (hour == 0) {
          return '12:${minute.toString().padLeft(2, '0')} ص';
        } else if (hour < 12) {
          return '$time ص';
        } else if (hour == 12) {
          return '$time م';
        } else {
          return '${(hour - 12).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} م';
        }
      }
    } catch (e) {
      // If parsing fails, return original time
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final backgroundColor = isDark
        ? Helpers.darken(_getBackgroundColor(), 0.2)
        : _getBackgroundColor();
    
    final borderColor = isDark
        ? Helpers.darken(_getBorderColor(), 0.2)
        : _getBorderColor();
    
    final textColor = isDark
        ? Helpers.darken(_getTextColor(), 0.2)
        : _getTextColor();

    return GestureDetector(
      onTap: isInteractive ? onPressed : null,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(AppThemes.borderRadiusMedium),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: status == SlotStatus.selected
              ? [
                  BoxShadow(
                    color: AppThemes.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Time Range
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(startTime),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 10,
                    color: textColor,
                  ),
                ),
                Text(
                  _formatTime(endTime),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 2),
            
            // Price
            if (showPrice && status != SlotStatus.passed)
              Text(
                Helpers.formatCurrency(price),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            
            // Duration
            if (showDuration)
              Text(
                'ساعة',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor.withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            
            // Status
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_getStatusIcon() != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: _getStatusIcon()!,
                    ),
                  Text(
                    _getStatusText(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlotGrid extends StatelessWidget {
  final List<SlotButton> slots;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry padding;

  const SlotGrid({
    Key? key,
    required this.slots,
    this.crossAxisCount = 3,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding = const EdgeInsets.all(16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: 100 / 70, // width / height
        ),
        itemCount: slots.length,
        itemBuilder: (context, index) => slots[index],
      ),
    );
  }
}

class TimeSlotPicker extends StatefulWidget {
  final List<StadiumSlot> slots;
  final StadiumSlot? selectedSlot;
  final ValueChanged<StadiumSlot> onSlotSelected;
  final bool showOnlyAvailable;
  final bool groupByDate;
  final bool showDateHeaders;
  final Color? availableColor;
  final Color? bookedColor;
  final Color? peakColor;
  final double slotWidth;
  final double slotHeight;

  const TimeSlotPicker({
    Key? key,
    required this.slots,
    this.selectedSlot,
    required this.onSlotSelected,
    this.showOnlyAvailable = false,
    this.groupByDate = true,
    this.showDateHeaders = true,
    this.availableColor,
    this.bookedColor,
    this.peakColor,
    this.slotWidth = 100,
    this.slotHeight = 70,
  }) : super(key: key);

  @override
  State<TimeSlotPicker> createState() => _TimeSlotPickerState();
}

class _TimeSlotPickerState extends State<TimeSlotPicker> {
  late Map<String, List<StadiumSlot>> _groupedSlots;

  @override
  void initState() {
    super.initState();
    _groupSlots();
  }

  @override
  void didUpdateWidget(covariant TimeSlotPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slots != widget.slots) {
      _groupSlots();
    }
  }

  void _groupSlots() {
    _groupedSlots = {};
    
    for (final slot in widget.slots) {
      if (widget.showOnlyAvailable && !slot.isAvailable) {
        continue;
      }
      
      final dateKey = widget.groupByDate
          ? Helpers.formatDate(slot.date)
          : 'all';
      
      _groupedSlots.putIfAbsent(dateKey, () => []).add(slot);
    }
    
    // Sort slots by time
    for (final key in _groupedSlots.keys) {
      _groupedSlots[key]!.sort((a, b) {
        return a.startTime.compareTo(b.startTime);
      });
    }
  }

  SlotStatus _getSlotStatus(StadiumSlot slot) {
    if (!slot.isAvailable) {
      return SlotStatus.booked;
    }
    
    if (slot.isPeakHour) {
      return SlotStatus.peakHour;
    }
    
    if (widget.selectedSlot != null &&
        widget.selectedSlot!.date == slot.date &&
        widget.selectedSlot!.startTime == slot.startTime) {
      return SlotStatus.selected;
    }
    
    // Check if slot has passed
    final now = DateTime.now();
    final slotDateTime = DateTime(
      slot.date.year,
      slot.date.month,
      slot.date.day,
      int.parse(slot.startTime.split(':')[0]),
      int.parse(slot.startTime.split(':')[1]),
    );
    
    if (slotDateTime.isBefore(now)) {
      return SlotStatus.passed;
    }
    
    return SlotStatus.available;
  }

  Widget _buildDateHeader(String dateString) {
    final date = DateTime.parse(dateString);
    final isToday = Helpers.isToday(date);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            isToday ? 'اليوم' : Helpers.formatDate(date),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'اليوم',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppThemes.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotGrid(List<StadiumSlot> slots) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final status = _getSlotStatus(slot);
        
        return SlotButton(
          startTime: slot.startTime,
          endTime: slot.endTime,
          price: slot.price,
          status: status,
          onPressed: status == SlotStatus.available ||
                    status == SlotStatus.peakHour
              ? () => widget.onSlotSelected(slot)
              : null,
          width: widget.slotWidth,
          height: widget.slotHeight,
          showPeakIcon: true,
          showBookedIcon: true,
          isToday: Helpers.isToday(slot.date),
          date: slot.date,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.groupByDate) {
      return _buildSlotGrid(widget.slots);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _groupedSlots.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showDateHeaders)
              _buildDateHeader(entry.key),
            _buildSlotGrid(entry.value),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }
}

class StadiumSlot {
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final bool isAvailable;
  final bool isPeakHour;

  const StadiumSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    this.isAvailable = true,
    this.isPeakHour = false,
  });
}
