import 'package:flutter/material.dart';
import '../../models/play_request.dart';
import '../../utils/helpers.dart';
import '../common/card.dart';
import '../common/button.dart';

class RequestCard extends StatelessWidget {
  final PlayRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onShare;
  final bool isJoined;
  final bool isCreator;
  final bool showActions;
  final bool compact;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onJoin,
    this.onLeave,
    this.onShare,
    this.isJoined = false,
    this.isCreator = false,
    this.showActions = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFull = request.isFull;
    final canJoin = !isFull && !isJoined && !isCreator && request.isOpen;
    
    return AppCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(8) : EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر مع الحالة
          _buildHeader(theme),
          
          SizedBox(height: compact ? 8 : 12),
          
          // معلومات الطلب الأساسية
          _buildBasicInfo(theme),
          
          if (!compact) SizedBox(height: 8),
          
          // تفاصيل الفريق
          if (!compact) _buildTeamDetails(theme),
          
          if (!compact) SizedBox(height: 8),
          
          // الموقمين
          if (!compact && request.joiners.isNotEmpty) _buildJoinersSection(),
          
          if (showActions && !compact) SizedBox(height: 12),
          
          // أزرار الإجراءات
          if (showActions && !compact) _buildActions(context, canJoin, isFull),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // حالة الطلب
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: request.statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: request.statusColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: request.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                request.statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: request.statusColor,
                ),
              ),
            ],
          ),
        ),
        
        // مؤشر الاكتمال
        if (request.isOpen)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${request.joinedCount}/${request.requiredPlayers}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCreator ? theme.primaryColor : Colors.grey[700],
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.people,
                size: 14,
                color: isCreator ? theme.primaryColor : Colors.grey[700],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBasicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // الملعب والتاريخ
        if (request.stadiumName != null)
          Row(
            children: [
              Icon(Icons.sports_soccer, size: 16, color: theme.primaryColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.stadiumName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        
        if (request.stadiumName != null) SizedBox(height: 4),
        
        // التاريخ والوقت
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
            SizedBox(width: 6),
            Text(
              request.date != null 
                ? Helpers.formatDate(request.date!)
                : 'تاريخ مرن',
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            SizedBox(width: 12),
            if (request.time != null) ...[
              Icon(Icons.access_time, size: 14, color: theme.hintColor),
              SizedBox(width: 6),
              Text(
                request.time!.format(context),
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTeamDetails(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الفئة العمرية والمستوى
          Row(
            children: [
              Icon(Icons.category, size: 14, color: theme.hintColor),
              SizedBox(width: 6),
              Text(
                'فئة: ${request.ageGroupText}',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
              SizedBox(width: 12),
              Icon(Icons.leaderboard, size: 14, color: theme.hintColor),
              SizedBox(width: 6),
              Text(
                'مستوى: ${request.levelText}',
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ),
          
          if (request.notes?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.notes!,
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          
          // وقت الإنشاء
          if (request.createdAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Text(
                    'أنشئ ${Helpers.getTimeAgo(request.createdAt!)}',
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJoinersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنضمون:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: request.joiners.take(5).map((joiner) {
            return Chip(
              label: Text(
                joiner.playerName,
                style: TextStyle(fontSize: 10),
              ),
              backgroundColor: Colors.blue[50],
              side: BorderSide.none,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        if (request.joiners.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ ${request.joiners.length - 5} آخرين',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool canJoin, bool isFull) {
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
        
        // زر الانضمام/المغادرة
        if (onJoin != null && canJoin)
          Expanded(
            child: AppButton(
              text: 'انضم',
              onPressed: onJoin,
              type: ButtonType.primary,
              size: ButtonSize.small,
              icon: Icons.person_add,
            ),
          ),
        
        if (onLeave != null && isJoined)
          Expanded(
            child: AppButton(
              text: 'غادر',
              onPressed: onLeave,
              type: ButtonType.danger,
              size: ButtonSize.small,
              icon: Icons.person_remove,
            ),
          ),
        
        // زر كامل
        if (isFull)
          Expanded(
            child: AppButton(
              text: 'مكتمل',
              onPressed: null,
              type: ButtonType.outline,
              size: ButtonSize.small,
              icon: Icons.group,
              isDisabled: true,
            ),
          ),
      ],
    );
  }
}
