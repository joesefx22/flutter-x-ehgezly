import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/stadium.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';
import '../common/button.dart';

class FieldCard extends StatelessWidget {
  final Stadium stadium;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onManageStaff;
  final VoidCallback? onViewStats;
  final bool showActions;
  final bool showStats;
  final bool compact;

  const FieldCard({
    super.key,
    required this.stadium,
    this.onTap,
    this.onEdit,
    this.onManageStaff,
    this.onViewStats,
    this.showActions = true,
    this.showStats = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayStats = stadium.getTodayStats();
    final monthlyStats = stadium.getMonthlyStats();
    
    return AppCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة والمعلومات الأساسية
          _buildHeader(theme),
          
          SizedBox(height: compact ? 8 : 12),
          
          // الإحصائيات (إذا مفعلة)
          if (showStats && !compact) _buildStatsSection(todayStats),
          
          if (showActions && !compact) SizedBox(height: 12),
          
          // أزرار الإجراءات
          if (showActions && !compact) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // صورة الملعب
        Container(
          width: compact ? 60 : 80,
          height: compact ? 60 : 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: stadium.mainImage ?? stadium.images.firstOrNull ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Center(
                child: Icon(
                  stadium.type == 'football' 
                    ? Icons.sports_soccer 
                    : Icons.sports_tennis,
                  size: 30,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: compact ? 8 : 12),
        
        // المعلومات الأساسية
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الاسم والنوع
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stadium.type == 'football' 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: stadium.type == 'football' 
                          ? Colors.green.withOpacity(0.3)
                          : Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      stadium.type == 'football' ? 'كرة قدم' : 'بادل',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: stadium.type == 'football' 
                          ? Colors.green 
                          : Colors.blue,
                      ),
                    ),
                  ),
                  
                  if (stadium.isActive)
                    Container(
                      margin: EdgeInsets.only(left: 6),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'نشط',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: EdgeInsets.only(left: 6),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        'غير نشط',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: 4),
              
              // اسم الملعب
              Text(
                stadium.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 2),
              
              // العنوان
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: theme.hintColor),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      stadium.address ?? 'لا يوجد عنوان',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // السعر
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${Helpers.formatCurrency(stadium.pricePerHour)} / ساعة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              
              // المميزات (في الوضع المضغوط)
              if (compact)
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: stadium.features.take(3).map((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(fontSize: 8, color: Colors.grey[600]),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> todayStats) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // الحجوزات اليوم
          _buildStatItem(
            icon: Icons.event_available,
            label: 'حجوزات اليوم',
            value: todayStats['todayBookings']?.toString() ?? '0',
            color: Colors.blue,
          ),
          
          // الإيرادات اليومية
          _buildStatItem(
            icon: Icons.attach_money,
            label: 'الإيرادات',
            value: Helpers.formatCurrency(todayStats['todayRevenue'] ?? 0),
            color: Colors.green,
          ),
          
          // معدل الإشغال
          _buildStatItem(
            icon: Icons.pie_chart,
            label: 'الإشغال',
            value: '${todayStats['occupancyRate']?.toStringAsFixed(0) ?? '0'}%',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // زر الإحصائيات
        if (onViewStats != null)
          Expanded(
            child: AppButton(
              text: 'الإحصائيات',
              onPressed: onViewStats,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.bar_chart,
            ),
          ),
        
        if (onViewStats != null) SizedBox(width: 8),
        
        // زر إدارة الموظفين
        if (onManageStaff != null)
          Expanded(
            child: AppButton(
              text: 'الموظفين',
              onPressed: onManageStaff,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.people,
            ),
          ),
        
        if (onManageStaff != null) SizedBox(width: 8),
        
        // زر التعديل
        if (onEdit != null)
          Expanded(
            child: AppButton(
              text: 'تعديل',
              onPressed: onEdit,
              type: ButtonType.primary,
              size: ButtonSize.small,
              icon: Icons.edit,
            ),
          ),
      ],
    );
  }
}
