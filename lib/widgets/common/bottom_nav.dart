import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';

class BottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showElevation;
  final double height;
  final double iconSize;
  final double selectedIconSize;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool showSelectedLabels;
  final bool showUnselectedLabels;
  final Curve animationCurve;
  final Duration animationDuration;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const BottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showElevation = true,
    this.height = 56,
    this.iconSize = 24,
    this.selectedIconSize = 26,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = false,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late List<GlobalKey> _itemKeys;
  late List<double> _itemWidths;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _itemWidths = List.filled(widget.items.length, 0.0);
    WidgetsBinding.instance.addPostFrameCallback(_calculateItemWidths);
  }

  void _calculateItemWidths(_) {
    for (int i = 0; i < widget.items.length; i++) {
      final key = _itemKeys[i];
      if (key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          setState(() {
            _itemWidths[i] = box.size.width;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBackgroundColor = widget.backgroundColor ??
        (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);
    final effectiveSelectedColor = widget.selectedColor ?? AppThemes.primaryColor;
    final effectiveUnselectedColor = widget.unselectedColor ??
        (isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary);

    final selectedLabelStyle = widget.selectedLabelStyle ??
        theme.textTheme.labelSmall?.copyWith(
          color: effectiveSelectedColor,
          fontWeight: FontWeight.w600,
        );
    
    final unselectedLabelStyle = widget.unselectedLabelStyle ??
        theme.textTheme.labelSmall?.copyWith(
          color: effectiveUnselectedColor,
          fontWeight: FontWeight.w500,
        );

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: widget.showElevation
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
        border: Border(
          top: BorderSide(
            color: AppThemes.lightDivider,
            width: 1,
          ),
        ),
        borderRadius: widget.borderRadius,
      ),
      height: widget.height + MediaQuery.of(context).padding.bottom,
      child: Column(
        children: [
          SizedBox(
            height: widget.height,
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(widget.items.length, (index) {
                  final item = widget.items[index];
                  final isSelected = index == widget.currentIndex;
                  
                  return Expanded(
                    child: GestureDetector(
                      key: _itemKeys[index],
                      onTap: () => widget.onTap(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Icon
                            AnimatedContainer(
                              duration: widget.animationDuration,
                              curve: widget.animationCurve,
                              transform: Matrix4.identity()
                                ..scale(isSelected ? 1.1 : 1.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Background circle for selected item
                                  if (isSelected)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: effectiveSelectedColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  
                                  // Icon
                                  Icon(
                                    isSelected && item.activeIcon != null
                                        ? item.activeIcon!.icon
                                        : item.icon,
                                    size: isSelected
                                        ? widget.selectedIconSize
                                        : widget.iconSize,
                                    color: isSelected
                                        ? effectiveSelectedColor
                                        : effectiveUnselectedColor,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Label
                            if ((isSelected && widget.showSelectedLabels) ||
                                (!isSelected && widget.showUnselectedLabels))
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: AnimatedDefaultTextStyle(
                                  duration: widget.animationDuration,
                                  style: isSelected
                                      ? selectedLabelStyle!
                                      : unselectedLabelStyle!,
                                  child: Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          
          // Safe area spacer
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class FloatingBottomNavBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double elevation;
  final double height;
  final double iconSize;
  final BorderRadiusGeometry? borderRadius;

  const FloatingBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.selectedColor = AppThemes.primaryColor,
    this.unselectedColor = AppThemes.lightTextSecondary,
    this.elevation = 4,
    this.height = 56,
    this.iconSize = 24,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(AppThemes.borderRadiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(AppThemes.borderRadiusXLarge),
        child: BottomNavBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: backgroundColor,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          showElevation: false,
          height: height,
          iconSize: iconSize,
          showSelectedLabels: true,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final IconData? activeIcon;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });
}

// Bottom Navigation Items for different user roles
class BottomNavItems {
  // Player Bottom Nav Items
  static List<BottomNavItem> get playerItems => [
    const BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_filled,
      label: 'الرئيسية',
    ),
    const BottomNavItem(
      icon: Icons.stadium_outlined,
      activeIcon: Icons.stadium,
      label: 'الملاعب',
    ),
    const BottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'حجوزاتي',
    ),
    const BottomNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'لاعبون',
    ),
    const BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'حسابي',
    ),
  ];

  // Staff Bottom Nav Items
  static List<BottomNavItem> get staffItems => [
    const BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'لوحة التحكم',
    ),
    const BottomNavItem(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'الحجوزات',
    ),
    const BottomNavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'طلبات اللاعبين',
    ),
    const BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'الموظفين',
    ),
    const BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'حسابي',
    ),
  ];

  // Owner Bottom Nav Items
  static List<BottomNavItem> get ownerItems => [
    const BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'الإحصائيات',
    ),
    const BottomNavItem(
      icon: Icons.stadium_outlined,
      activeIcon: Icons.stadium,
      label: 'ملاعبى',
    ),
    const BottomNavItem(
      icon: Icons.attach_money_outlined,
      activeIcon: Icons.attach_money,
      label: 'المبيعات',
    ),
    const BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'الفريق',
    ),
    const BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'حسابي',
    ),
  ];

  // Admin Bottom Nav Items
  static List<BottomNavItem> get adminItems => [
    const BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'لوحة التحكم',
    ),
    const BottomNavItem(
      icon: Icons.people_outlined,
      activeIcon: Icons.people,
      label: 'المستخدمين',
    ),
    const BottomNavItem(
      icon: Icons.stadium_outlined,
      activeIcon: Icons.stadium,
      label: 'الملاعب',
    ),
    const BottomNavItem(
      icon: Icons.receipt_outlined,
      activeIcon: Icons.receipt,
      label: 'التقارير',
    ),
    const BottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'الإعدادات',
    ),
  ];
}
