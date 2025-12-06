import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';

class OwnerStatsCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? unit;
  final bool isCurrency;
  final bool showTrend;
  final double? trendValue;
  final VoidCallback? onTap;
  final bool compact;

  const OwnerStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.blue,
    this.subtitle,
    this.unit,
    this.isCurrency = false,
    this.showTrend = false,
    this.trendValue,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والأيقونة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Container(
                width: compact ? 30 : 40,
                height: compact ? 30 : 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: compact ? 16 : 20,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: compact ? 8 : 12),
          
          // القيمة
          _buildValueSection(context),
          
          // الترجمة والاتجاه (إذا موجود)
          if (subtitle != null || showTrend) ...[
            SizedBox(height: compact ? 4 : 8),
            _buildFooterSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildValueSection(BuildContext context) {
    final theme = Theme.of(context);
    String formattedValue = _formatValue(value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedValue,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: compact ? 18 : 24,
          ),
        ),
        
        if (unit != null)
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              unit!,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // الترجمة
        if (subtitle != null)
          Expanded(
            child: Text(
              subtitle!,
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        // مؤشر الاتجاه
        if (showTrend && trendValue != null)
          _buildTrendIndicator(trendValue!),
      ],
    );
  }

  Widget _buildTrendIndicator(double trendValue) {
    final isPositive = trendValue >= 0;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    final color = isPositive ? Colors.green : Colors.red;
    final formattedValue = '${isPositive ? '+' : ''}${trendValue.toStringAsFixed(1)}%';
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 2),
          Text(
            formattedValue,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is num) {
      if (isCurrency) {
        return Helpers.formatCurrency(value.toDouble());
      } else if (value >= 1000) {
        final thousands = value / 1000;
        return '${thousands.toStringAsFixed(thousands.truncateToDouble() == thousands ? 0 : 1)}K';
      }
      return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    }
    return value.toString();
  }
}

// مجموعة إحصائيات جاهزة
class OwnerStatsGrid extends StatelessWidget {
  final List<OwnerStatsCard> cards;
  final int crossAxisCount;

  const OwnerStatsGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

// إحصائيات جاهزة للمالك
class OwnerDefaultStats {
  static List<OwnerStatsCard> getDailyStats({
    required double revenue,
    required int bookings,
    required double occupancy,
    required int newCustomers,
    double? revenueTrend,
    double? bookingsTrend,
    double? occupancyTrend,
    double? customersTrend,
  }) {
    return [
      OwnerStatsCard(
        title: 'الإيرادات اليومية',
        value: revenue,
        icon: Icons.attach_money,
        color: Colors.green,
        subtitle: 'إجمالي الإيرادات',
        isCurrency: true,
        showTrend: revenueTrend != null,
        trendValue: revenueTrend,
      ),
      OwnerStatsCard(
        title: 'عدد الحجوزات',
        value: bookings,
        icon: Icons.event_available,
        color: Colors.blue,
        subtitle: 'حجوزات اليوم',
        showTrend: bookingsTrend != null,
        trendValue: bookingsTrend,
      ),
      OwnerStatsCard(
        title: 'معدل الإشغال',
        value: occupancy,
        icon: Icons.pie_chart,
        color: Colors.orange,
        subtitle: 'نسبة الإشغال',
        unit: '%',
        showTrend: occupancyTrend != null,
        trendValue: occupancyTrend,
      ),
      OwnerStatsCard(
        title: 'عملاء جدد',
        value: newCustomers,
        icon: Icons.person_add,
        color: Colors.purple,
        subtitle: 'عملاء مسجلين اليوم',
        showTrend: customersTrend != null,
        trendValue: customersTrend,
      ),
    ];
  }

  static List<OwnerStatsCard> getMonthlyStats({
    required double revenue,
    required int bookings,
    required double avgRating,
    required int cancelledBookings,
    double? revenueTrend,
    double? bookingsTrend,
    double? ratingTrend,
    double? cancelledTrend,
  }) {
    return [
      OwnerStatsCard(
        title: 'الإيرادات الشهرية',
        value: revenue,
        icon: Icons.bar_chart,
        color: Colors.teal,
        subtitle: 'إجمالي الشهر',
        isCurrency: true,
        showTrend: revenueTrend != null,
        trendValue: revenueTrend,
      ),
      OwnerStatsCard(
        title: 'حجوزات الشهر',
        value: bookings,
        icon: Icons.calendar_month,
        color: Colors.indigo,
        subtitle: 'إجمالي الحجوزات',
        showTrend: bookingsTrend != null,
        trendValue: bookingsTrend,
      ),
      OwnerStatsCard(
        title: 'التقييم المتوسط',
        value: avgRating,
        icon: Icons.star,
        color: Colors.amber,
        subtitle: 'من 5 نجوم',
        showTrend: ratingTrend != null,
        trendValue: ratingTrend,
      ),
      OwnerStatsCard(
        title: 'حجوزات ملغاة',
        value: cancelledBookings,
        icon: Icons.cancel,
        color: Colors.red,
        subtitle: 'الشهر الحالي',
        showTrend: cancelledTrend != null,
        trendValue: cancelledTrend,
      ),
    ];
  }
}
