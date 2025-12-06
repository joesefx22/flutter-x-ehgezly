import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';
import '../common/button.dart';

class StaffCard extends StatelessWidget {
  final User staff;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onToggleStatus;
  final bool showActions;
  final bool showStatus;
  final bool compact;

  const StaffCard({
    super.key,
    required this.staff,
    this.onTap,
    this.onEdit,
    this.onRemove,
    this.onToggleStatus,
    this.showActions = true,
    this.showStatus = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = staff.isActive;
    final stadiumsCount = staff.stadiums?.length ?? 0;
    
    return AppCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة والمعلومات الأساسية
          _buildHeader(theme, isActive),
          
          SizedBox(height: compact ? 8 : 12),
          
          // المعلومات الإضافية
          if (!compact) _buildDetails(stadiumsCount),
          
          if (showStatus && !compact) SizedBox(height: 8),
          
          // حالة النشاط
          if (showStatus && !compact) _buildStatusSection(isActive),
          
          if (showActions && !compact) SizedBox(height: 12),
          
          // أزرار الإجراءات
          if (showActions && !compact) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isActive) {
    return Row(
      children: [
        // صورة الموظف
        Container(
          width: compact ? 40 : 50,
          height: compact ? 40 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primaryColor.withOpacity(0.1),
            border: Border.all(
              color: isActive 
                ? theme.primaryColor 
                : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(staff.name),
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: isActive 
                  ? theme.primaryColor 
                  : Colors.grey[600],
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
              Text(
                staff.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 2),
              
              Text(
                staff.phone ?? 'لا يوجد هاتف',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  color: theme.hintColor,
                ),
              ),
              
              if (staff.email?.isNotEmpty == true)
                Text(
                  staff.email!,
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    color: theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        
        // مؤشر النشاط (في الوضع المضغوط)
        if (compact && showStatus)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
      ],
    );
  }

  Widget _buildDetails(int stadiumsCount) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // عدد الملاعب المسؤول عنها
          _buildDetailItem(
            icon: Icons.sports_soccer,
            label: 'ملاعب',
            value: stadiumsCount.toString(),
          ),
          
          // تاريخ الانضمام
          if (staff.createdAt != null)
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'منذ',
              value: Helpers.getTimeAgo(staff.createdAt!),
            ),
          
          // الأدوار
          _buildDetailItem(
            icon: Icons.work,
            label: 'أدوار',
            value: '${staff.roles.length}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
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

  Widget _buildStatusSection(bool isActive) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        SizedBox(width: 6),
        Text(
          isActive ? 'نشط' : 'غير نشط',
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        if (onToggleStatus != null)
          Switch(
            value: isActive,
            onChanged: (value) => onToggleStatus!(),
            activeColor: Colors.green,
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // زر التعديل
        if (onEdit != null)
          Expanded(
            child: AppButton(
              text: 'تعديل',
              onPressed: onEdit,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.edit,
            ),
          ),
        
        if (onEdit != null) SizedBox(width: 8),
        
        // زر الإزالة
        if (onRemove != null)
          Expanded(
            child: AppButton(
              text: 'إزالة',
              onPressed: onRemove,
              type: ButtonType.danger,
              size: ButtonSize.small,
              icon: Icons.delete,
            ),
          ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2 
      ? name.substring(0, 2).toUpperCase()
      : name.toUpperCase();
  }
}
