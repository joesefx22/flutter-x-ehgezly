import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class DayChips extends StatefulWidget {
  final List<DateTime> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final double chipHeight;
  final double chipWidth;
  final EdgeInsetsGeometry chipPadding;
  final BorderRadiusGeometry? chipBorderRadius;
  final bool showMonth;
  final bool showDayName;
  final bool showDayNumber;
  final bool showFullDate;
  final bool enablePastDays;
  final bool enableFutureDays;
  final int maxFutureDays;
  final List<DateTime> disabledDates;
  final Map<DateTime, String>? dateBadges;
  final ScrollController? scrollController;

  const DayChips({
    Key? key,
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.chipHeight = 72,
    this.chipWidth = 56,
    this.chipPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    this.chipBorderRadius,
    this.showMonth = false,
    this.showDayName = true,
    this.showDayNumber = true,
    this.showFullDate = false,
    this.enablePastDays = false,
    this.enableFutureDays = true,
    this.maxFutureDays = 30,
    this.disabledDates = const [],
    this.dateBadges,
    this.scrollController,
  }) : super(key: key);

  @override
  State<DayChips> createState() => _DayChipsState();
}

class _DayChipsState extends State<DayChips> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void didUpdateWidget(covariant DayChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    }
  }

  void _scrollToSelectedDate() {
    final selectedIndex = widget.days.indexWhere(
      (date) => Helpers.isSameDay(date, widget.selectedDate),
    );
    
    if (selectedIndex != -1 && _scrollController.hasClients) {
      final itemWidth = widget.chipWidth + 8; // width + margin
      final scrollOffset = selectedIndex * itemWidth - 
          (MediaQuery.of(context).size.width - itemWidth) / 2;
      
      _scrollController.animateTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _isDateDisabled(DateTime date) {
    if (!widget.enablePastDays && date.isBefore(DateTime.now())) {
      return true;
    }
    
    if (!widget.enableFutureDays && date.isAfter(DateTime.now())) {
      return true;
    }
    
    if (widget.maxFutureDays > 0) {
      final maxDate = DateTime.now().add(Duration(days: widget.maxFutureDays));
      if (date.isAfter(maxDate)) {
        return true;
      }
    }
    
    return widget.disabledDates.any((disabledDate) => 
        Helpers.isSameDay(disabledDate, date));
  }

  String _getDayName(DateTime date) {
    if (widget.showFullDate) {
      return Helpers.formatDate(date, format: 'EEE d MMM');
    }
    
    final arabicDays = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
    return arabicDays[date.weekday % 7];
  }

  String _getMonthName(DateTime date) {
    final arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return arabicMonths[date.month - 1];
  }

  Widget _buildDateChip(DateTime date, int index) {
    final isSelected = Helpers.isSameDay(date, widget.selectedDate);
    final isToday = Helpers.isToday(date);
    final isDisabled = _isDateDisabled(date);
    final hasBadge = widget.dateBadges?.containsKey(date) ?? false;
    final badgeText = widget.dateBadges?[date];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedColor = widget.selectedColor ?? AppThemes.primaryColor;
    final unselectedColor = widget.unselectedColor ??
        (isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary);
    
    final backgroundColor = isSelected
        ? selectedColor.withOpacity(0.1)
        : Colors.transparent;
    
    final borderColor = isSelected
        ? selectedColor
        : (isToday ? selectedColor : AppThemes.lightDivider);
    
    final textColor = isSelected
        ? selectedColor
        : (isToday ? selectedColor : unselectedColor);

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () => widget.onDateSelected(date),
      child: Container(
        width: widget.chipWidth,
        height: widget.chipHeight,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: widget.chipBorderRadius ?? 
              BorderRadius.circular(AppThemes.borderRadiusMedium),
          border: Border.all(
            color: isDisabled ? AppThemes.lightDivider : borderColor,
            width: isSelected || isToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day Name
            if (widget.showDayName)
              Text(
                _getDayName(date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDisabled ? AppThemes.lightTextSecondary : textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            
            // Day Number
            if (widget.showDayNumber)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  date.day.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDisabled ? AppThemes.lightTextSecondary : textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            
            // Month Name
            if (widget.showMonth)
              Text(
                _getMonthName(date),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDisabled ? AppThemes.lightTextSecondary : textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            
            // Today Indicator
            if (isToday && !isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
            
            // Badge Indicator
            if (hasBadge && badgeText != null)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.chipHeight + 20, // Extra for badges
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.days.length,
        itemBuilder: (context, index) {
          final date = widget.days[index];
          return _buildDateChip(date, index);
        },
      ),
    );
  }
}

class WeekDayChips extends StatelessWidget {
  final List<String> days;
  final String selectedDay;
  final ValueChanged<String> onDaySelected;
  final Color? selectedColor;
  final Color? unselectedColor;

  const WeekDayChips({
    Key? key,
    required this.days,
    required this.selectedDay,
    required this.onDaySelected,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedColor = this.selectedColor ?? AppThemes.primaryColor;
    final unselectedColor = this.unselectedColor ??
        (isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        final isSelected = day == selectedDay;
        
        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              border: Border.all(
                color: isSelected ? selectedColor : AppThemes.lightDivider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              day,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? selectedColor : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DateRangeChips extends StatefulWidget {
  final List<DateRangeOption> options;
  final DateRangeOption? selectedOption;
  final ValueChanged<DateRangeOption> onOptionSelected;
  final Color? selectedColor;
  final Color? unselectedColor;

  const DateRangeChips({
    Key? key,
    required this.options,
    this.selectedOption,
    required this.onOptionSelected,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  State<DateRangeChips> createState() => _DateRangeChipsState();
}

class _DateRangeChipsState extends State<DateRangeChips> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final selectedColor = widget.selectedColor ?? AppThemes.primaryColor;
    final unselectedColor = widget.unselectedColor ??
        (isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((option) {
        final isSelected = option == widget.selectedOption;
        
        return GestureDetector(
          onTap: () => widget.onOptionSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              border: Border.all(
                color: isSelected ? selectedColor : AppThemes.lightDivider,
                width: 1,
              ),
            ),
            child: Text(
              option.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? Colors.white : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DateRangeOption {
  final String label;
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeOption({
    required this.label,
    required this.startDate,
    required this.endDate,
  });

  // Common date range options
  static DateRangeOption get today => DateRangeOption(
    label: 'اليوم',
    startDate: DateTime.now(),
    endDate: DateTime.now(),
  );

  static DateRangeOption get yesterday => DateRangeOption(
    label: 'أمس',
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    endDate: DateTime.now().subtract(const Duration(days: 1)),
  );

  static DateRangeOption get thisWeek => DateRangeOption(
    label: 'هذا الأسبوع',
    startDate: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
    endDate: DateTime.now().add(Duration(days: 7 - DateTime.now().weekday)),
  );

  static DateRangeOption get thisMonth => DateRangeOption(
    label: 'هذا الشهر',
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  static DateRangeOption get lastMonth => DateRangeOption(
    label: 'الشهر الماضي',
    startDate: DateTime(DateTime.now().year, DateTime.now().month - 1, 1),
    endDate: DateTime(DateTime.now().year, DateTime.now().month, 0),
  );

  static DateRangeOption get thisYear => DateRangeOption(
    label: 'هذا العام',
    startDate: DateTime(DateTime.now().year, 1, 1),
    endDate: DateTime(DateTime.now().year, 12, 31),
  );

  static List<DateRangeOption> get allOptions => [
    today,
    yesterday,
    thisWeek,
    thisMonth,
    lastMonth,
    thisYear,
  ];
}
