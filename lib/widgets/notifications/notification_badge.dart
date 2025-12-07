import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/notification_provider.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final bool showCount;
  final double? size;
  
  const NotificationBadge({
    super.key,
    required this.child,
    this.showCount = true,
    this.size,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, childWidget) {
        final count = provider.unreadCount;
        
        if (count == 0) {
          return childWidget!;
        }
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            childWidget!,
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                constraints: BoxConstraints(
                  minWidth: size ?? 16,
                  minHeight: size ?? 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: showCount
                    ? Text(
                        count > 9 ? '9+' : count.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}
