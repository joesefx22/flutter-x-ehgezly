import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';
import 'package:ehgezly_app/widgets/common/button.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showSearch;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final bool showNotifications;
  final int? notificationCount;
  final VoidCallback? onNotificationPressed;
  final bool showProfile;
  final String? profileImage;
  final VoidCallback? onProfilePressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showDivider;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    Key? key,
    this.title = '',
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showSearch = false,
    this.onSearchChanged,
    this.searchHint,
    this.showNotifications = false,
    this.notificationCount,
    this.onNotificationPressed,
    this.showProfile = false,
    this.profileImage,
    this.onProfilePressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showDivider = false,
    this.flexibleSpace,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        bottom != null 
            ? kToolbarHeight + bottom!.preferredSize.height
            : kToolbarHeight,
      );

  Widget _buildSearchField() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppThemes.lightSurface,
        borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHint ?? 'ابحث عن ملعب...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppThemes.lightTextSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppThemes.lightTextSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        style: const TextStyle(
          fontSize: 14,
          color: AppThemes.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onNotificationPressed,
          icon: const Icon(Icons.notifications_outlined),
          iconSize: 24,
        ),
        if (notificationCount != null && notificationCount! > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppThemes.errorColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount! > 9 ? '9+' : notificationCount!.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: onProfilePressed,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppThemes.lightDivider,
            width: 1,
          ),
        ),
        child: profileImage != null && profileImage!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  profileImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                ),
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppThemes.primaryColor.withOpacity(0.1),
      ),
      child: Icon(
        Icons.person_outline,
        size: 20,
        color: AppThemes.primaryColor,
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;
    
    if (showBackButton) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          iconSize: 24,
        ),
      );
    }
    
    return Container();
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (title.isEmpty) return Container();
    
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? (isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget> _buildActions() {
    final actionWidgets = <Widget>[];
    
    if (showNotifications) {
      actionWidgets.add(_buildNotificationButton());
    }
    
    if (showProfile) {
      actionWidgets.add(_buildProfileButton());
    }
    
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }
    
    return actionWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);
    final effectiveForegroundColor = foregroundColor ??
        (isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary);

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context),
      title: showSearch ? _buildSearchField() : _buildTitle(context),
      centerTitle: centerTitle && !showSearch,
      actions: _buildActions(),
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      shape: showDivider
          ? Border(
              bottom: BorderSide(
                color: AppThemes.lightDivider,
                width: 1,
              ),
            )
          : null,
    );
  }
}

class SliverAppBar extends StatelessWidget {
  final String title;
  final String? expandedTitle;
  final Widget? background;
  final bool pinned;
  final bool floating;
  final bool snap;
  final bool stretch;
  final double expandedHeight;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const SliverAppBar({
    Key? key,
    required this.title,
    this.expandedTitle,
    this.background,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.stretch = false,
    this.expandedHeight = 200,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),
      expandedTitle: expandedTitle != null ? Text(expandedTitle!) : null,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      elevation: 0,
      pinned: pinned,
      floating: floating,
      snap: snap,
      stretch: stretch,
      expandedHeight: expandedHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: background,
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
      leading: showBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            )
          : null,
      actions: actions,
    );
  }
}

class BottomAppBar extends StatelessWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showElevation;
  final double height;

  const BottomAppBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.showElevation = true,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);
    final effectiveSelectedColor = selectedColor ?? AppThemes.primaryColor;
    final effectiveUnselectedColor = unselectedColor ??
        (isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        boxShadow: showElevation
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
      ),
      height: height + MediaQuery.of(context).padding.bottom,
      child: Column(
        children: [
          SizedBox(height: height),
          // Safe area spacer
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final Widget? activeIcon;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });
}
