import 'package:flutter/material.dart';
import 'package:ehgezly_app/utils/app_themes.dart';

enum InputFieldType {
  text,
  email,
  phone,
  password,
  number,
  date,
  time,
  multiline,
}

class InputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final InputFieldType type;
  final bool isRequired;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final String? initialValue;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const InputField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.type = InputFieldType.text,
    this.isRequired = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _obscureText = true;
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _internalController.text = widget.initialValue!;
    }
    
    // Set default obscure text for password fields
    if (widget.type == InputFieldType.password) {
      _obscureText = true;
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case InputFieldType.email:
        return TextInputType.emailAddress;
      case InputFieldType.phone:
        return TextInputType.phone;
      case InputFieldType.number:
        return TextInputType.number;
      case InputFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];
    
    if (widget.maxLength != null) {
      formatters.add(LengthLimitingTextInputFormatter(widget.maxLength));
    }
    
    switch (widget.type) {
      case InputFieldType.phone:
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case InputFieldType.number:
        formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[0-9]')));
        break;
      default:
        break;
    }
    
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
    }
    
    return formatters;
  }

  String? _defaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'هذا الحقل مطلوب';
    }
    
    switch (widget.type) {
      case InputFieldType.email:
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return 'البريد الإلكتروني غير صحيح';
          }
        }
        break;
      case InputFieldType.phone:
        if (value != null && value.isNotEmpty) {
          final phoneRegex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');
          if (!phoneRegex.hasMatch(value)) {
            return 'رقم الهاتف غير صحيح';
          }
        }
        break;
      case InputFieldType.password:
        if (value != null && value.isNotEmpty && value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        break;
      default:
        break;
    }
    
    return null;
  }

  Widget? _getPrefixIcon() {
    if (widget.prefixIcon != null) return widget.prefixIcon;
    
    switch (widget.type) {
      case InputFieldType.email:
        return const Icon(Icons.email_outlined, size: 20);
      case InputFieldType.phone:
        return const Icon(Icons.phone_outlined, size: 20);
      case InputFieldType.password:
        return const Icon(Icons.lock_outline, size: 20);
      default:
        return null;
    }
  }

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    
    if (widget.type == InputFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return Icon(
        Icons.error_outline,
        color: AppThemes.errorColor,
        size: 20,
      );
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: RichText(
              text: TextSpan(
                text: widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary,
                ),
                children: [
                  if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppThemes.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        
        // Text Field
        TextFormField(
          controller: _internalController,
          keyboardType: _getKeyboardType(),
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: widget.type == InputFieldType.password ? _obscureText : false,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: _getInputFormatters(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: _getPrefixIcon(),
            suffixIcon: _getSuffixIcon(),
            filled: true,
            fillColor: isDark 
                ? AppThemes.darkSurface.withOpacity(0.5)
                : AppThemes.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              borderSide: BorderSide(
                color: AppThemes.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              borderSide: BorderSide(
                color: AppThemes.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppThemes.borderRadiusMedium),
              borderSide: BorderSide(
                color: AppThemes.errorColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorMaxLines: 2,
            errorStyle: const TextStyle(height: 1.2),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppThemes.darkTextPrimary : AppThemes.lightTextPrimary,
          ),
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          validator: widget.validator ?? _defaultValidator,
        ),
        
        // Helper text spacing
        if (widget.helperText != null && widget.errorText == null)
          const SizedBox(height: 4),
      ],
    );
  }
}
