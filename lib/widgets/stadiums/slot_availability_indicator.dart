import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../models/stadium.dart';
import '../../utils/helpers.dart';

class SlotAvailabilityIndicator extends StatelessWidget {
  final Stadium stadium;
  final DateTime date;
  final double size;
  final bool showLabel;
  final bool compact;

  const SlotAvailabilityIndicator({
    super.key,
    required this.stadium,
    required this.date,
    this.size = 100,
    this.showLabel = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final slots = _getSlotsForDate();
    if (slots.isEmpty) return _buildEmptyState(context);

    final availableCount = slots.where((s) => s.isAvailable).length;
    final totalCount = slots.length;
    final percentage = totalCount > 0 ? (availableCount / totalCount) * 100 : 0;
    final status = _getStatus(percentage);

    if (compact) {
      return _buildCompactIndicator(context, status, percentage);
    }

    return _buildFullIndicator(context, status, percentage, availableCount, totalCount);
  }

  List<StadiumSlot> _getSlotsForDate() {
    return stadium.slots.where((slot) {
      return slot.date.year == date.year &&
             slot.date.month == date.month &&
             slot.date.day == date.day;
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, color: Colors.grey[400], size: 24),
          SizedBox(height: 4),
          Text(
            'لا توجد مواعيد',
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactIndicator(BuildContext context, _AvailabilityStatus status, double percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          '${percentage.round()}%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: status.color,
          ),
        ),
      ],
    );
  }

  Widget _buildFullIndicator(
    BuildContext context, 
    _AvailabilityStatus status, 
    double percentage, 
    int available, 
    int total
  ) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        children: [
          // المقياس الدائري
          SfRadialGauge(
            axes: [
              RadialAxis(
                minimum: 0,
                maximum: 100,
                showLabels: false,
                showTicks: false,
                axisLineStyle: AxisLineStyle(
                  thickness: 0.1,
                  color: Colors.grey[200],
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: [
                  RangePointer(
                    value: percentage,
                    width: 0.1,
                    sizeUnit: GaugeSizeUnit.factor,
                    color: status.color,
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                ],
                annotations: [
                  GaugeAnnotation(
                    positionFactor: 0.1,
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${percentage.round()}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: status.color,
                          ),
                        ),
                        if (showLabel)
                          Text(
                            status.label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // المعلومات الإضافية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '$available / $total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'موعد متاح',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _AvailabilityStatus _getStatus(double percentage) {
    if (percentage >= 70) {
      return _AvailabilityStatus('متاح بكثرة', Colors.green);
    } else if (percentage >= 30) {
      return _AvailabilityStatus('متاح محدود', Colors.amber);
    } else if (percentage > 0) {
      return _AvailabilityStatus('نادر', Colors.orange);
    } else {
      return _AvailabilityStatus('ممتلئ', Colors.red);
    }
  }
}

class _AvailabilityStatus {
  final String label;
  final Color color;

  _AvailabilityStatus(this.label, this.color);
}
