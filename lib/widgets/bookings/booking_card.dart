import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/booking.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';
import '../common/button.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;
  final VoidCallback? onShare;
  final bool showActions;
  final bool showDetails;
  final bool compact;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.onCancel,
    this.onPay,
    this.onShare,
    this.showActions = true,
    this.showDetails = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر مع الحالة
          _buildHeader(theme),
          
          SizedBox(height: compact ? 8 : 12),
          
          // معلومات الحجز الأساسية
          _buildBasicInfo(theme),
          
          if (showDetails && !compact) SizedBox(height: 8),
          
          // التفاصيل الإضافية
          if (showDetails && !compact) _buildDetails(theme),
          
          if (showActions && !compact) SizedBox(height: 12),
          
          // أزرار الإجراءات
          if (showActions && !compact) _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // حالة الحجز
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: booking.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: booking.statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: booking.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                booking.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: booking.statusColor,
                ),
              ),
            ],
          ),
        ),
        
        // رقم الحجز
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: booking.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم نسخ رقم الحجز'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy, size: 14, color: theme.hintColor),
              SizedBox(width: 4),
              Text(
                '#${booking.id.substring(0, 8)}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.hintColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الملعب والتاريخ
        Row(
          children: [
            Icon(Icons.sports_soccer, size: 16, color: theme.primaryColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                booking.stadiumName ?? 'ملعب غير محدد',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 4),
        
        // التاريخ والوقت
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
            SizedBox(width: 6),
            Text(
              Helpers.formatDate(booking.date),
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            SizedBox(width: 12),
            Icon(Icons.access_time, size: 14, color: theme.hintColor),
            SizedBox(width: 6),
            Text(
              '${booking.slot.startTime.format(context)} - ${booking.slot.endTime.format(context)}',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        
        // السعر
        if (!compact && booking.amount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  '${Helpers.formatCurrency(booking.amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (booking.discountAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${Helpers.formatCurrency(booking.amount + booking.discountAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (booking.playersCount > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.people, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Text(
                    '${booking.playersCount} لاعبين',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          
          if (booking.notes?.isNotEmpty == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 14, color: theme.hintColor),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.notes!,
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          
          if (booking.paymentMethod != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.payment, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Text(
                    'دفع ${booking.paymentMethod == 'card' ? 'بالبطاقة' : 'نقدي'}',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          
          if (booking.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Text(
                    'تم الحجز ${Helpers.getTimeAgo(booking.createdAt!)}',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        // زر المشاركة
        if (onShare != null)
          Expanded(
            child: AppButton(
              text: 'مشاركة',
              onPressed: onShare,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.share,
            ),
          ),
        
        if (onShare != null) SizedBox(width: 8),
        
        // زر الإلغاء (إذا مسموح)
        if (onCancel != null && booking.canCancel)
          Expanded(
            child: AppButton(
              text: 'إلغاء',
              onPressed: onCancel,
              type: ButtonType.danger,
              size: ButtonSize.small,
              icon: Icons.cancel,
            ),
          ),
        
        if (onCancel != null && booking.canCancel) SizedBox(width: 8),
        
        // زر الدفع (إذا كان مطلوب)
        if (onPay != null && booking.needsPayment)
          Expanded(
            child: AppButton(
              text: 'دفع الآن',
              onPressed: onPay,
              type: ButtonType.success,
              size: ButtonSize.small,
              icon: Icons.payment,
            ),
          ),
      ],
    );
  }
}
