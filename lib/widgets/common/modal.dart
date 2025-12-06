import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'button.dart';

class AppModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    double maxHeight = 0.8,
    bool showCloseButton = true,
    bool isLoading = false,
    Color? backgroundColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: backgroundColor ?? theme.colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * maxHeight,
      ),
      builder: (context) {
        return _ModalContent(
          title: title,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          isLoading: isLoading,
        );
      },
    );
  }
  
  static Future<T?> showMaterial<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool showCloseButton = true,
    bool isLoading = false,
  }) {
    return showMaterialModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ModalContent(
          title: title,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          isLoading: isLoading,
        );
      },
    );
  }
  
  static Future<T?> showCupertino<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool showCloseButton = true,
    bool isLoading = false,
  }) {
    return showCupertinoModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ModalContent(
          title: title,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          isLoading: isLoading,
          isCupertino: true,
        );
      },
    );
  }
}

class _ModalContent extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool showCloseButton;
  final bool isLoading;
  final bool isCupertino;

  const _ModalContent({
    required this.title,
    required this.content,
    this.actions,
    this.showCloseButton = true,
    this.isLoading = false,
    this.isCupertino = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle للـ drag
              if (!isCupertino)
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              
              // الهيدر
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isCupertino ? 12 : 8,
                ),
                child: Row(
                  children: [
                    if (showCloseButton)
                      IconButton(
                        icon: Icon(isCupertino ? Icons.clear : Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        iconSize: 24,
                      ),
                    
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: showCloseButton ? TextAlign.start : TextAlign.center,
                      ),
                    ),
                    
                    if (showCloseButton && !isCupertino)
                      SizedBox(width: 48), // مساحة للتوازن
                  ],
                ),
              ),
              
              Divider(height: 1, thickness: 1),
              
              // المحتوى
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: content,
                ),
              ),
              
              // الأزرار (إذا وجدت)
              if (actions != null && actions!.isNotEmpty) ...[
                Divider(height: 1, thickness: 1),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          children: actions!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Loading overlay
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
