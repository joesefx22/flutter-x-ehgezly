import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/play_request.dart';
import '../../providers/play_request_provider.dart';
import '../../services/play_request_service.dart';
import '../../utils/helpers.dart';
import '../common/modal.dart';
import '../common/button.dart';

class JoinModal extends StatefulWidget {
  final PlayRequest request;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const JoinModal({
    super.key,
    required this.request,
    this.onSuccess,
    this.onCancel,
  });

  @override
  State<JoinModal> createState() => _JoinModalState();
}

class _JoinModalState extends State<JoinModal> {
  // حالة التحميل والأخطاء
  bool _isLoading = false;
  String? _errorMessage;
  
  // ملاحظات الانضمام
  String _joinNotes = '';
  
  // عدد اللاعبين (إذا كان المستخدم يريد إضافة أكثر من لاعب)
  int _additionalPlayers = 1;
  final int _maxAdditionalPlayers = 5;

  Future<void> _joinRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestService = PlayRequestService();
      final requestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      
      // الانضمام للطلب
      await requestService.joinPlayRequest(
        requestId: widget.request.id,
        notes: _joinNotes.isNotEmpty ? _joinNotes : null,
        additionalPlayers: _additionalPlayers > 1 ? _additionalPlayers : null,
      );
      
      // تحديث الـ provider
      requestProvider.refreshRequests();
      
      // إغلاق المودال وإظهار رسالة نجاح
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _additionalPlayers > 1
                ? 'تم انضمامك مع ${_additionalPlayers} لاعبين!'
                : 'تم انضمامك للطلب بنجاح!'
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        widget.onSuccess?.call();
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء الانضمام: $error';
        _isLoading = false;
      });
    }
  }

  bool get _isFull => widget.request.isFull;
  bool get _canJoin => !_isFull && widget.request.isOpen;
  int get _remainingSpots => widget.request.remainingSpots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppModal(
      title: 'الانضمام للطلب',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطلب
            _buildRequestInfo(theme),
            
            SizedBox(height: 16),
            
            // حالة التوفر
            _buildAvailabilitySection(),
            
            SizedBox(height: 16),
            
            // عدد اللاعبين الإضافيين
            if (_remainingSpots > 1) _buildAdditionalPlayersSection(),
            
            SizedBox(height: 16),
            
            // ملاحظات الانضمام
            _buildNotesSection(),
            
            SizedBox(height: 16),
            
            // رسائل التنبيه
            _buildAlertMessages(),
            
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: _buildActions(),
      isLoading: _isLoading,
    );
  }

  Widget _buildRequestInfo(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.request.stadiumName != null)
            Text(
              widget.request.stadiumName!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          
          if (widget.request.stadiumName != null) SizedBox(height: 8),
          
          if (widget.request.date != null)
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: theme.hintColor),
                SizedBox(width: 6),
                Text(
                  Helpers.formatDate(widget.request.date!),
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          
          if (widget.request.time != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.hintColor),
                  SizedBox(width: 6),
                  Text(
                    widget.request.time!.format(context),
                    style: TextStyle(fontSize: 12, color: theme.hintColor),
                  ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.category, size: 14, color: theme.hintColor),
                SizedBox(width: 6),
                Text(
                  'فئة: ${widget.request.ageGroupText}',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
                SizedBox(width: 12),
                Icon(Icons.leaderboard, size: 14, color: theme.hintColor),
                SizedBox(width: 6),
                Text(
                  'مستوى: ${widget.request.levelText}',
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    final theme = Theme.of(context);
    final isFull = _isFull;
    final remaining = _remainingSpots;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFull ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFull ? Colors.red[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.group_off : Icons.group,
            color: isFull ? Colors.red : Colors.green,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFull ? 'الطلب مكتمل' : 'متاح للانضمام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.red : Colors.green,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  isFull
                    ? 'وصل عدد اللاعبين للحد الأقصى'
                    : 'متبقي $remaining مكان${remaining > 1 ? 'ات' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              '${widget.request.joinedCount}/${widget.request.requiredPlayers}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: isFull ? Colors.red : Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalPlayersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عدد اللاعبين الإضافيين',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'يمكنك إضافة لاعبين آخرين معك',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: _additionalPlayers > 1
                  ? () => setState(() => _additionalPlayers--)
                  : null,
                color: _additionalPlayers > 1 
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              ),
              Text(
                '$_additionalPlayers لاعب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _additionalPlayers < _maxAdditionalPlayers && 
                          _additionalPlayers < _remainingSpots
                  ? () => setState(() => _additionalPlayers++)
                  : null,
                color: _additionalPlayers < _maxAdditionalPlayers &&
                       _additionalPlayers < _remainingSpots
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Text(
          'الحد الأقصى $_maxAdditionalPlayers لاعبين أو $_remainingSpots متبقي',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات الانضمام (اختياري)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (value) => _joinNotes = value,
            decoration: InputDecoration(
              hintText: 'أدخل أي ملاحظات للمنظم (مستوى اللعب، الخ)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 3,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertMessages() {
    return Column(
      children: [
        // رسالة تأكيد
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue[800]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سيتم إعلام المنظم بانضمامك',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 8),
        
        // رسالة الإلغاء
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber[800]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'يمكنك مغادرة الطلب في أي وقت قبل موعده',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      AppButton(
        text: 'إلغاء',
        onPressed: widget.onCancel,
        type: ButtonType.outline,
      ),
      SizedBox(width: 8),
      AppButton(
        text: _isFull ? 'مكتمل' : 'انضم الآن',
        onPressed: _canJoin ? _joinRequest : null,
        type: _isFull ? ButtonType.outline : ButtonType.primary,
        isDisabled: _isFull,
        isLoading: _isLoading,
      ),
    ];
  }
}
