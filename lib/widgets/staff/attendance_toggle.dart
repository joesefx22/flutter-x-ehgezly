import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../common/button.dart';

class AttendanceToggle extends StatefulWidget {
  final String staffId;
  final String staffName;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final Function(String, bool) onAttendanceChanged;
  final bool canEdit;
  final bool showDetails;

  const AttendanceToggle({
    super.key,
    required this.staffId,
    required this.staffName,
    this.checkInTime,
    this.checkOutTime,
    required this.onAttendanceChanged,
    this.canEdit = true,
    this.showDetails = true,
  });

  @override
  State<AttendanceToggle> createState() => _AttendanceToggleState();
}

class _AttendanceToggleState extends State<AttendanceToggle> {
  bool _isPresent = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  
  // حالة التحميل
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isPresent = widget.checkInTime != null && widget.checkOutTime == null;
    _checkInTime = widget.checkInTime;
    _checkOutTime = widget.checkOutTime;
  }

  Future<void> _toggleAttendance() async {
    if (!widget.canEdit || _isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final newState = !_isPresent;
      final now = DateTime.now();
      
      if (newState) {
        // تسجيل الحضور
        _checkInTime = now;
        _checkOutTime = null;
      } else {
        // تسجيل الانصراف
        _checkOutTime = now;
      }
      
      // تحديث الحالة المحلية
      setState(() {
        _isPresent = newState;
      });
      
      // إعلام الـ parent
      widget.onAttendanceChanged(widget.staffId, newState);
      
      // إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState
              ? 'تم تسجيل حضور ${widget.staffName}'
              : 'تم تسجيل انصراف ${widget.staffName}'
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // إعادة الحالة في حالة الخطأ
      setState(() {
        _isPresent = !_isPresent;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $error'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _statusText {
    if (_checkInTime == null) return 'غائب';
    if (_checkOutTime == null) return 'حاضر';
    return 'منصرف';
  }

  Color get _statusColor {
    if (_checkInTime == null) return Colors.grey;
    if (_checkOutTime == null) return Colors.green;
    return Colors.blue;
  }

  IconData get _statusIcon {
    if (_checkInTime == null) return Icons.person_off;
    if (_checkOutTime == null) return Icons.person;
    return Icons.logout;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // معلومات الموظف والحالة
          Row(
            children: [
              // صورة/أيقونة الموظف
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor.withOpacity(0.1),
                  border: Border.all(color: _statusColor),
                ),
                child: Center(
                  child: Icon(
                    _statusIcon,
                    size: 20,
                    color: _statusColor,
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // معلومات الموظف
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.staffName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (widget.showDetails)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2),
                          Text(
                            _statusText,
                            style: TextStyle(
                              fontSize: 12,
                              color: _statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              // زر التحكم
              if (widget.canEdit)
                AppButton(
                  text: _isPresent ? 'تسجيل انصراف' : 'تسجيل حضور',
                  onPressed: _toggleAttendance,
                  type: _isPresent ? ButtonType.outline : ButtonType.primary,
                  size: ButtonSize.small,
                  icon: _isPresent ? Icons.logout : Icons.login,
                  isLoading: _isLoading,
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          
          // التفاصيل (إذا مفعلة)
          if (widget.showDetails && (_checkInTime != null || _checkOutTime != null))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // وقت الحضور
                    if (_checkInTime != null)
                      _buildTimeDetail(
                        icon: Icons.login,
                        label: 'حضر',
                        time: _checkInTime!,
                        color: Colors.green,
                      ),
                    
                    // وقت الانصراف
                    if (_checkOutTime != null)
                      _buildTimeDetail(
                        icon: Icons.logout,
                        label: 'انصرف',
                        time: _checkOutTime!,
                        color: Colors.blue,
                      ),
                    
                    // المدة
                    if (_checkInTime != null && _checkOutTime != null)
                      _buildDurationDetail(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeDetail({
    required IconData icon,
    required String label,
    required DateTime time,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          Helpers.formatTime(time),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          Helpers.formatDateShort(time),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationDetail() {
    if (_checkInTime == null || _checkOutTime == null) return SizedBox();
    
    final duration = _checkOutTime!.difference(_checkInTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer, size: 12, color: Colors.orange),
            SizedBox(width: 4),
            Text(
              'المدة',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 2),
        Text(
          '${hours}س ${minutes}د',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          'إجمالي',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
