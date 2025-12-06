import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;
  final bool isInteractive;
  final Border? border;
  final double? elevation;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.onTap,
    this.isInteractive = true,
    this.border,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardColor = backgroundColor ??
        (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);
    
    final cardShadow = shadow ?? AppThemes.cardShadow;
    final cardBorderRadius = borderRadius ??
        BorderRadius.circular(AppThemes.borderRadiusLarge);
    
    final effectiveElevation = elevation ??
        (onTap != null && isInteractive ? 2.0 : 0.0);

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: cardBorderRadius,
        border: border,
        boxShadow: cardShadow,
      ),
      child: child,
    );

    if (onTap != null && isInteractive) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: cardBorderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: cardBorderRadius,
            child: cardContent,
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: cardContent,
    );
  }
}

class IconCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double iconSize;
  final bool showArrow;

  const IconCard({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
    this.iconSize = 24,
    this.showArrow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final effectiveIconColor = iconColor ?? AppThemes.primaryColor;
    final effectiveBackgroundColor = backgroundColor ??
        (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);

    return AppCard(
      onTap: onTap,
      isInteractive: onTap != null,
      backgroundColor: effectiveBackgroundColor,
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: effectiveIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: effectiveIconColor,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          // Arrow Icon
          if (showArrow && onTap != null)
            Icon(
              Icons.chevron_left,
              size: 24,
              color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
            ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? change;
  final bool isPositiveChange;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.change,
    this.isPositiveChange = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final cardColor = color ?? AppThemes.primaryColor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title Row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: cardColor,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Value
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary,
            ),
          ),
          
          // Change (if available)
          if (change != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    isPositiveChange ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isPositiveChange ? AppThemes.successColor : AppThemes.errorColor,
                  ),
                  
                  const SizedBox(width: 4),
                  
                  Text(
                    change!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPositiveChange ? AppThemes.successColor : AppThemes.errorColor,
                      fontWeight: FontWeight.w600,
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

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final double height;
  final double borderRadius;
  final VoidCallback? onTap;
  final Widget? overlay;

  const ImageCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.height = 160,
    this.borderRadius = AppThemes.borderRadiusLarge,
    this.onTap,
    this.overlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      isInteractive: onTap != null,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(
              imageUrl,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  width: double.infinity,
                  color: AppThemes.lightDivider,
                  child: const Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppThemes.lightTextSecondary,
                  ),
                );
              },
            ),
          ),
          
          // Gradient Overlay
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Content
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          // Custom Overlay
          if (overlay != null) overlay!,
        ],
      ),
    );
  }
}
