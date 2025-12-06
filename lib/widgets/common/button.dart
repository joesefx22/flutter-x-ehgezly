import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
  xlarge,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final Widget? icon;
  final IconData? iconData;
  final Color? customColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
    this.icon,
    this.iconData,
    this.customColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  Color _getBackgroundColor(BuildContext context) {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case ButtonType.primary:
        return AppThemes.primaryColor;
      case ButtonType.secondary:
        return AppThemes.secondaryColor;
      case ButtonType.danger:
        return AppThemes.errorColor;
      case ButtonType.success:
        return AppThemes.successColor;
      case ButtonType.outline:
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outline:
        return AppThemes.primaryColor;
      case ButtonType.text:
        final theme = Theme.of(context);
        return theme.brightness == Brightness.dark
            ? AppThemes.darkTextPrimary
            : AppThemes.lightTextPrimary;
    }
  }

  Color _getBorderColor(BuildContext context) {
    if (type == ButtonType.outline) {
      return AppThemes.primaryColor;
    }
    return Colors.transparent;
  }

  Color _getDisabledColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppThemes.darkDivider
        : AppThemes.lightDivider;
  }

  Color _getDisabledTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppThemes.darkTextSecondary
        : AppThemes.lightTextSecondary;
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
      case ButtonSize.xlarge:
        return 64;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final baseStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;
    
    switch (size) {
      case ButtonSize.small:
        return baseStyle?.copyWith(fontSize: 14) ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case ButtonSize.medium:
        return baseStyle?.copyWith(fontSize: 16) ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case ButtonSize.large:
        return baseStyle?.copyWith(fontSize: 18) ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
      case ButtonSize.xlarge:
        return baseStyle?.copyWith(fontSize: 20) ??
            const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
    }
  }

  EdgeInsets _getPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 0);
      case ButtonSize.xlarge:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 0);
    }
  }

  double _getBorderRadius() {
    return borderRadius ?? AppThemes.borderRadiusMedium;
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? AppThemes.primaryColor
                : Colors.white,
          ),
        ),
      );
    }

    final children = <Widget>[];
    
    if (icon != null) {
      children.add(icon!);
      children.add(const SizedBox(width: 8));
    } else if (iconData != null) {
      children.add(Icon(iconData, size: 20));
      children.add(const SizedBox(width: 8));
    }
    
    children.add(
      Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDisabled
        ? _getDisabledColor(context)
        : _getBackgroundColor(context);
    
    final textColor = isDisabled
        ? _getDisabledTextColor(context)
        : _getTextColor(context);
    
    final borderColor = isDisabled
        ? _getDisabledColor(context)
        : _getBorderColor(context);
    
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: ElevatedButton(
        onPressed: isDisabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: _getDisabledColor(context),
          disabledForegroundColor: _getDisabledTextColor(context),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            side: BorderSide(
              color: borderColor,
              width: type == ButtonType.outline ? 1.5 : 0,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: _getTextStyle(context),
        ),
        child: _buildContent(),
      ),
    );
  }
}

class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool isLoading;
  final bool isDisabled;
  final double? iconSize;

  const IconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.color,
    this.backgroundColor,
    this.isLoading = false,
    this.isDisabled = false,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final iconColor = color ?? (isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary);
    final bgColor = backgroundColor ?? (isDark ? AppThemes.darkSurface : AppThemes.lightSurface);

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
        child: InkWell(
          onTap: isDisabled || isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    icon,
                    size: iconSize ?? size * 0.5,
                    color: isDisabled ? AppThemes.lightTextSecondary : iconColor,
                  ),
                ),
        ),
      ),
    );
  }
}

class FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool isLoading;

  const FloatingActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor ?? AppThemes.primaryColor,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        foregroundColor ?? Colors.white,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Icon(
                    icon,
                    size: size * 0.4,
                    color: foregroundColor ?? Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
