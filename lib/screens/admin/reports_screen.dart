import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/user_provider.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:typed_data';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isGeneratingReport = false;
  
  // فترة التقرير
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportPeriod = 'آخر 30 يوم';
  
  // نوع التقرير
  String _selectedReportType = 'إيرادات';
  final List<String> _reportTypes = [
    'إيرادات',
    'حجوزات',
    'مستخدمين',
    'ملاعب',
    'دفع',
    'طلبات لاعبين',
  ];
  
  // مستوى التفاصيل
  String _detailLevel = 'متوسط';
  final List<String> _detailLevels = ['مبسط', 'متوسط', 'مفصل'];
  
  // بيانات التقارير
  Map<String, dynamic> _revenueData = {};
  Map<String, dynamic> _bookingsData = {};
  Map<String, dynamic> _usersData = {};
  Map<String, dynamic> _stadiumsData = {};
  Map<String, dynamic> _paymentsData = {};
  Map<String, dynamic> _playRequestsData = {};
  
  // بيانات المخططات
  List<ChartData> _revenueChartData = [];
  List<ChartData> _bookingsChartData = [];
  List<ChartData> _usersChartData = [];
  List<ChartData> _stadiumsChartData = [];
  List<PieData> _paymentsPieData = [];
  List<PieData> _playRequestsPieData = [];
  
  // التقارير المحفوظة
  List<SavedReport> _savedReports = [];
  
  // للتحديث التلقائي
  Timer? _autoRefreshTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReportsData();
    _loadSavedReports();
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _stopAutoRefresh();
    super.dispose();
  }
  
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _loadReportsData(showLoading: false);
      }
    });
  }
  
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  Future<void> _loadReportsData({bool showLoading = true}) async {
    try {
      if (showLoading) {
        setState(() => _isLoading = true);
      }
      
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // تحميل البيانات المتوازية
      final futures = await Future.wait([
        bookingProvider.getRevenueReport(_startDate, _endDate),
        bookingProvider.getBookingsReport(_startDate, _endDate),
        userProvider.getUsersReport(_startDate, _endDate),
        stadiumProvider.getStadiumsReport(_startDate, _endDate),
        bookingProvider.getPaymentsReport(_startDate, _endDate),
        bookingProvider.getPlayRequestsReport(_startDate, _endDate),
        
        // بيانات المخططات
        bookingProvider.getRevenueChartData(startDate: _startDate, endDate: _endDate),
        bookingProvider.getBookingsChartData(startDate: _startDate, endDate: _endDate),
        userProvider.getUsersChartData(startDate: _startDate, endDate: _endDate),
        stadiumProvider.getStadiumsChartData(startDate: _startDate, endDate: _endDate),
        bookingProvider.getPaymentsPieData(startDate: _startDate, endDate: _endDate),
        bookingProvider.getPlayRequestsPieData(startDate: _startDate, endDate: _endDate),
      ]);
      
      if (mounted) {
        setState(() {
          _revenueData = futures[0] as Map<String, dynamic>;
          _bookingsData = futures[1] as Map<String, dynamic>;
          _usersData = futures[2] as Map<String, dynamic>;
          _stadiumsData = futures[3] as Map<String, dynamic>;
          _paymentsData = futures[4] as Map<String, dynamic>;
          _playRequestsData = futures[5] as Map<String, dynamic>;
          
          _revenueChartData = futures[6] as List<ChartData>;
          _bookingsChartData = futures[7] as List<ChartData>;
          _usersChartData = futures[8] as List<ChartData>;
          _stadiumsChartData = futures[9] as List<ChartData>;
          _paymentsPieData = futures[10] as List<PieData>;
          _playRequestsPieData = futures[11] as List<PieData>;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في تحميل التقارير');
      }
    }
  }
  
  Future<void> _loadSavedReports() async {
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _savedReports = await bookingProvider.getSavedReports();
    } catch (e) {
      print('Error loading saved reports: $e');
    }
  }
  
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اختيار فترة ونوع التقرير
            _buildReportControls(),
            const SizedBox(height: 24),
            
            // بطاقات إحصائيات سريعة
            _buildQuickStats(),
            const SizedBox(height: 24),
            
            // المخططات الرئيسية
            _buildMainCharts(),
            const SizedBox(height: 24),
            
            // التقارير المحفوظة
            _buildSavedReports(),
            
            const SizedBox(height: 80), // مساحة للـ FAB
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailedReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // تقرير الإيرادات
        _buildReportCard(
          'تقرير الإيرادات',
          Icons.attach_money,
          Colors.green,
          _revenueData,
          _buildRevenueReport,
        ),
        const SizedBox(height: 16),
        
        // تقرير الحجوزات
        _buildReportCard(
          'تقرير الحجوزات',
          Icons.event,
          Colors.blue,
          _bookingsData,
          _buildBookingsReport,
        ),
        const SizedBox(height: 16),
        
        // تقرير المستخدمين
        _buildReportCard(
          'تقرير المستخدمين',
          Icons.people,
          Colors.purple,
          _usersData,
          _buildUsersReport,
        ),
        const SizedBox(height: 16),
        
        // تقرير الملاعب
        _buildReportCard(
          'تقرير الملاعب',
          Icons.stadium,
          Colors.orange,
          _stadiumsData,
          _buildStadiumsReport,
        ),
        const SizedBox(height: 16),
        
        // تقرير المدفوعات
        _buildReportCard(
          'تقرير المدفوعات',
          Icons.payment,
          Colors.red,
          _paymentsData,
          _buildPaymentsReport,
        ),
        const SizedBox(height: 16),
        
        // تقرير طلبات اللاعبين
        _buildReportCard(
          'تقرير طلبات اللاعبين',
          Icons.group,
          Colors.teal,
          _playRequestsData,
          _buildPlayRequestsReport,
        ),
      ],
    );
  }
  
  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // تحليل الإيرادات
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تحليل الإيرادات',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text('${_calculateGrowth(_revenueData['totalRevenue'], _revenueData['previousRevenue'])}%'),
                      backgroundColor: _getGrowthColor(_revenueData['totalRevenue'], _revenueData['previousRevenue']),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelRotation: -45,
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                    primaryYAxis: NumericAxis(
                      numberFormat: NumberFormat.compactCurrency(locale: 'ar'),
                    ),
                    series: <ChartSeries<ChartData, String>>[
                      LineSeries<ChartData, String>(
                        dataSource: _revenueChartData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        name: 'الإيرادات',
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // تحليل الحجوزات
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحليل الحجوزات',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                    series: <ChartSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                        dataSource: _bookingsChartData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        name: 'الحجوزات',
                        color: Colors.blue,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // تحليل المدفوعات
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحليل المدفوعات',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SfCircularChart(
                    series: <CircularSeries>[
                      PieSeries<PieData, String>(
                        dataSource: _paymentsPieData,
                        xValueMapper: (PieData data, _) => data.label,
                        yValueMapper: (PieData data, _) => data.value,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                        explode: true,
                        explodeIndex: 0,
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // مؤشرات الأداء
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildKpiCard(
              'معدل الإشغال',
              '${_stadiumsData['occupancyRate']?.toStringAsFixed(1) ?? '0'}%',
              Icons.percent,
              Colors.orange,
            ),
            _buildKpiCard(
              'متوسط قيمة الحجز',
              Helpers.formatCurrency(_bookingsData['averageBookingValue'] ?? 0),
              Icons.attach_money,
              Colors.green,
            ),
            _buildKpiCard(
              'معدل النمو',
              '${_calculateGrowth(_revenueData['totalRevenue'], _revenueData['previousRevenue'])}%',
              Icons.trending_up,
              Colors.blue,
            ),
            _buildKpiCard(
              'معدل الإلغاء',
              '${_bookingsData['cancellationRate']?.toStringAsFixed(1) ?? '0'}%',
              Icons.cancel,
              Colors.red,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildReportControls() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات التقرير',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // فترة التقرير
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الفترة', style: Theme.of(context).textTheme.caption),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _reportPeriod,
                        items: [
                          'اليوم',
                          'أمس',
                          'آخر 7 أيام',
                          'آخر 30 يوم',
                          'هذا الشهر',
                          'الشهر الماضي',
                          'مخصص',
                        ].map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _reportPeriod = value!);
                          _updateDateRange(value!);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نوع التقرير', style: Theme.of(context).textTheme.caption),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _selectedReportType,
                        items: _reportTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedReportType = value!);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // تواريخ مخصصة
            if (_reportPeriod == 'مخصص') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('من', style: Theme.of(context).textTheme.caption),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(_startDate),
                          ),
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () => _showDatePicker(true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إلى', style: Theme.of(context).textTheme.caption),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(_endDate),
                          ),
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () => _showDatePicker(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            
            // مستوى التفاصيل
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مستوى التفاصيل', style: Theme.of(context).textTheme.caption),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: _detailLevels.map((level) {
                    return ChoiceChip(
                      label: Text(level),
                      selected: _detailLevel == level,
                      onSelected: (selected) {
                        setState(() => _detailLevel = level);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'تحديث التقرير',
                    onPressed: _loadReportsData,
                    icon: Icons.refresh,
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'تصدير التقرير',
                    onPressed: _exportReport,
                    icon: Icons.download,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'الإيرادات',
          Helpers.formatCurrency(_revenueData['totalRevenue'] ?? 0),
          Icons.attach_money,
          Colors.green,
          _revenueData['growth'] != null ? '${_revenueData['growth']}%' : null,
        ),
        _buildStatCard(
          'الحجوزات',
          '${_bookingsData['totalBookings'] ?? 0}',
          Icons.event,
          Colors.blue,
          _bookingsData['growth'] != null ? '${_bookingsData['growth']}%' : null,
        ),
        _buildStatCard(
          'مستخدمين جدد',
          '${_usersData['newUsers'] ?? 0}',
          Icons.person_add,
          Colors.purple,
          _usersData['growth'] != null ? '${_usersData['growth']}%' : null,
        ),
        _buildStatCard(
          'ملاعب نشطة',
          '${_stadiumsData['activeStadiums'] ?? 0}',
          Icons.stadium,
          Colors.orange,
          null,
        ),
      ],
    );
  }
  
  Widget _buildMainCharts() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحليل الأداء',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                legend: Legend(isVisible: true, position: LegendPosition.bottom),
                series: <CartesianSeries>[
                  LineSeries<ChartData, String>(
                    dataSource: _revenueChartData,
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    name: 'الإيرادات',
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<ChartData, String>(
                    dataSource: _bookingsChartData,
                    xValueMapper: (ChartData data, _) => data.label,
                    yValueMapper: (ChartData data, _) => data.value,
                    name: 'الحجوزات',
                    color: Colors.blue,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSavedReports() {
    if (_savedReports.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التقارير المحفوظة',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _loadSavedReports,
              child: const Text('تحديث'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._savedReports.take(3).map((report) {
          return _buildSavedReportItem(report);
        }).toList(),
        if (_savedReports.length > 3) ...[
          const SizedBox(height: 12),
          Center(
            child: AppButton(
              text: 'عرض جميع التقارير',
              onPressed: () {
                // TODO: Show all saved reports
              },
              size: ButtonSize.small,
              outlined: true,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildReportCard(
    String title,
    IconData icon,
    Color color,
    Map<String, dynamic> data,
    Widget Function() reportBuilder,
  ) {
    return AppCard(
      onTap: () {
        AppModal.show(
          context: context,
          title: title,
          content: reportBuilder(),
          maxHeight: 0.8,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subtitle1?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (data['summary'] != null)
                    Text(
                      data['summary'],
                      style: Theme.of(context).textTheme.caption,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRevenueReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('الإيرادات الإجمالية', [
            _buildReportItem('الإيرادات', Helpers.formatCurrency(_revenueData['totalRevenue'] ?? 0)),
            _buildReportItem('الإيرادات السابقة', Helpers.formatCurrency(_revenueData['previousRevenue'] ?? 0)),
            _buildReportItem('نسبة النمو', '${_calculateGrowth(_revenueData['totalRevenue'], _revenueData['previousRevenue'])}%'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('الإيرادات حسب النوع', [
            _buildReportItem('حجوزات', Helpers.formatCurrency(_revenueData['bookingsRevenue'] ?? 0)),
            _buildReportItem('عروض', Helpers.formatCurrency(_revenueData['offersRevenue'] ?? 0)),
            _buildReportItem('أخرى', Helpers.formatCurrency(_revenueData['otherRevenue'] ?? 0)),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('الإيرادات حسب اليوم', _revenueChartData
              .map((data) => _buildReportItem(data.label, Helpers.formatCurrency(data.value)))
              .toList()),
        ],
      ),
    );
  }
  
  Widget _buildBookingsReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('الحجوزات الإجمالية', [
            _buildReportItem('إجمالي الحجوزات', '${_bookingsData['totalBookings'] ?? 0}'),
            _buildReportItem('حجوزات مؤكدة', '${_bookingsData['confirmedBookings'] ?? 0}'),
            _buildReportItem('حجوزات ملغاة', '${_bookingsData['cancelledBookings'] ?? 0}'),
            _buildReportItem('معدل الإلغاء', '${_bookingsData['cancellationRate']?.toStringAsFixed(1) ?? '0'}%'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('متوسطات', [
            _buildReportItem('متوسط قيمة الحجز', Helpers.formatCurrency(_bookingsData['averageBookingValue'] ?? 0)),
            _buildReportItem('متوسط مدة الحجز', '${_bookingsData['averageBookingDuration'] ?? 0} ساعة'),
            _buildReportItem('متوسط لاعبين لكل حجز', '${_bookingsData['averagePlayersPerBooking']?.toStringAsFixed(1) ?? '0'}'),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildUsersReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('المستخدمون', [
            _buildReportItem('مستخدمون جدد', '${_usersData['newUsers'] ?? 0}'),
            _buildReportItem('مستخدمون نشطون', '${_usersData['activeUsers'] ?? 0}'),
            _buildReportItem('إجمالي المستخدمين', '${_usersData['totalUsers'] ?? 0}'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('التوزيع حسب الدور', [
            _buildReportItem('لاعبون', '${_usersData['players'] ?? 0}'),
            _buildReportItem('موظفون', '${_usersData['staff'] ?? 0}'),
            _buildReportItem('ملاك', '${_usersData['owners'] ?? 0}'),
            _buildReportItem('مدراء', '${_usersData['admins'] ?? 0}'),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildStadiumsReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('الملاعب', [
            _buildReportItem('ملاعب نشطة', '${_stadiumsData['activeStadiums'] ?? 0}'),
            _buildReportItem('ملاعب غير نشطة', '${_stadiumsData['inactiveStadiums'] ?? 0}'),
            _buildReportItem('معدل الإشغال', '${_stadiumsData['occupancyRate']?.toStringAsFixed(1) ?? '0'}%'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('التوزيع حسب النوع', [
            _buildReportItem('كرة قدم', '${_stadiumsData['footballStadiums'] ?? 0}'),
            _buildReportItem('بادل', '${_stadiumsData['paddleStadiums'] ?? 0}'),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildPaymentsReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('المدفوعات', [
            _buildReportItem('مدفوعات ناجحة', '${_paymentsData['successfulPayments'] ?? 0}'),
            _buildReportItem('مدفوعات فاشلة', '${_paymentsData['failedPayments'] ?? 0}'),
            _buildReportItem('مدفوعات معلقة', '${_paymentsData['pendingPayments'] ?? 0}'),
            _buildReportItem('معدل النجاح', '${_paymentsData['successRate']?.toStringAsFixed(1) ?? '0'}%'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('طرق الدفع', [
            _buildReportItem('بطاقة ائتمان', '${_paymentsData['creditCard'] ?? 0}'),
            _buildReportItem('محفظة إلكترونية', '${_paymentsData['ewallet'] ?? 0}'),
            _buildReportItem('كاش', '${_paymentsData['cash'] ?? 0}'),
            _buildReportItem('أخرى', '${_paymentsData['other'] ?? 0}'),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildPlayRequestsReport() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportSection('طلبات اللاعبين', [
            _buildReportItem('طلبات مفتوحة', '${_playRequestsData['openRequests'] ?? 0}'),
            _buildReportItem('طلبات مكتملة', '${_playRequestsData['completedRequests'] ?? 0}'),
            _buildReportItem('طلبات ملغاة', '${_playRequestsData['cancelledRequests'] ?? 0}'),
          ]),
          const SizedBox(height: 16),
          _buildReportSection('المشاركات', [
            _buildReportItem('إجمالي المشاركات', '${_playRequestsData['totalJoiners'] ?? 0}'),
            _buildReportItem('متوسط مشاركين لكل طلب', '${_playRequestsData['averageJoinersPerRequest']?.toStringAsFixed(1) ?? '0'}'),
          ]),
        ],
      ),
    );
  }
  
  Widget _buildReportSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }
  
  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyText2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSavedReportItem(SavedReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getReportIcon(report.type),
            color: _getReportColor(report.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.name,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${report.type} • ${DateFormat('yyyy-MM-dd').format(report.createdAt)}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 20),
            onPressed: () => _downloadReport(report),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color, String? growth) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (growth != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getGrowthColorFromString(growth),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      growth,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateDateRange(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'اليوم':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'أمس':
        final yesterday = now.subtract(const Duration(days: 1));
        _startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        _endDate = _startDate.add(const Duration(days: 1));
        break;
      case 'آخر 7 أيام':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'آخر 30 يوم':
        _startDate = now.subtract(const Duration(days: 30));
        _endDate = now;
        break;
      case 'هذا الشهر':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'الشهر الماضي':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        _startDate = lastMonth;
        _endDate = DateTime(now.year, now.month, 0);
        break;
    }
    
    _loadReportsData();
  }
  
  void _showDatePicker(bool isStartDate) {
    AppModal.show(
      context: context,
      title: isStartDate ? 'اختر تاريخ البداية' : 'اختر تاريخ النهاية',
      content: SizedBox(
        height: 400,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          initialSelectedDate: isStartDate ? _startDate : _endDate,
          minDate: DateTime(2020, 1, 1),
          maxDate: DateTime.now(),
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is DateTime) {
              setState(() {
                if (isStartDate) {
                  _startDate = args.value as DateTime;
                } else {
                  _endDate = args.value as DateTime;
                }
              });
            }
          },
        ),
      ),
    );
  }
  
  Future<void> _exportReport() async {
    if (_isGeneratingReport) return;
    
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير التقرير'),
        content: const Text('اختر صيغة التقرير:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'pdf'),
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'excel'),
            child: const Text('Excel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'csv'),
            child: const Text('CSV'),
          ),
        ],
      ),
    );
    
    if (format != null) {
      try {
        setState(() => _isGeneratingReport = true);
        
        // إنشاء التقرير
        final report = await _generateReport(format);
        
        // حفظ التقرير
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        await bookingProvider.saveReport(
          name: 'تقرير ${_selectedReportType} - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
          type: _selectedReportType,
          data: report,
          format: format,
        );
        
        // إعادة تحميل التقارير المحفوظة
        await _loadSavedReports();
        
        setState(() => _isGeneratingReport = false);
        Helpers.showSuccessSnackbar(context, 'تم إنشاء التقرير بنجاح');
      } catch (e) {
        setState(() => _isGeneratingReport = false);
        Helpers.showErrorSnackbar(context, 'فشل في إنشاء التقرير');
      }
    }
  }
  
  Future<Map<String, dynamic>> _generateReport(String format) async {
    final report = {
      'title': 'تقرير ${_selectedReportType}',
      'period': 'من ${DateFormat('yyyy-MM-dd').format(_startDate)} إلى ${DateFormat('yyyy-MM-dd').format(_endDate)}',
      'generatedAt': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      'detailLevel': _detailLevel,
      'data': {},
    };
    
    // إضافة البيانات حسب نوع التقرير
    switch (_selectedReportType) {
      case 'إيرادات':
        report['data'] = _revenueData;
        break;
      case 'حجوزات':
        report['data'] = _bookingsData;
        break;
      case 'مستخدمين':
        report['data'] = _usersData;
        break;
      case 'ملاعب':
        report['data'] = _stadiumsData;
        break;
      case 'دفع':
        report['data'] = _paymentsData;
        break;
      case 'طلبات لاعبين':
        report['data'] = _playRequestsData;
        break;
    }
    
    // إذا كان PDF، ننشئ ملف PDF
    if (format == 'pdf') {
      await _generatePdfReport(report);
    }
    
    return report;
  }
  
  Future<void> _generatePdfReport(Map<String, dynamic> report) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(report['title'], style: pw.TextStyle(fontSize: 24)),
              ),
              pw.Text('الفترة: ${report['period']}'),
              pw.Text('تاريخ الإنشاء: ${report['generatedAt']}'),
              pw.SizedBox(height: 20),
              
              // إضافة البيانات حسب النوع
              _buildPdfTable(report),
              
              pw.SizedBox(height: 20),
              pw.Footer(
                child: pw.Text('احجزلي - نظام إدارة الملاعب الرياضية'),
              ),
            ],
          );
        },
      ),
    );
    
    // يمكن حفظ أو مشاركة PDF هنا
    // await Printing.sharePdf(bytes: await pdf.save(), filename: 'report.pdf');
  }
  
  pw.Widget _buildPdfTable(Map<String, dynamic> report) {
    final data = report['data'] as Map<String, dynamic>;
    
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('المؤشر', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('القيمة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        ...data.entries.map((entry) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(entry.key),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(entry.value.toString()),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }
  
  Future<void> _downloadReport(SavedReport report) async {
    // TODO: Implement download report
  }
  
  double _calculateGrowth(double? current, double? previous) {
    if (current == null || previous == null || previous == 0) return 0;
    return ((current - previous) / previous * 100);
  }
  
  Color _getGrowthColor(double? current, double? previous) {
    final growth = _calculateGrowth(current, previous);
    if (growth > 0) return Colors.green;
    if (growth < 0) return Colors.red;
    return Colors.grey;
  }
  
  Color _getGrowthColorFromString(String growth) {
    if (growth.startsWith('-')) return Colors.red;
    if (growth.contains('+') || double.tryParse(growth.replaceAll('%', ''))! > 0) {
      return Colors.green;
    }
    return Colors.grey;
  }
  
  IconData _getReportIcon(String type) {
    switch (type) {
      case 'إيرادات': return Icons.attach_money;
      case 'حجوزات': return Icons.event;
      case 'مستخدمين': return Icons.people;
      case 'ملاعب': return Icons.stadium;
      case 'دفع': return Icons.payment;
      case 'طلبات لاعبين': return Icons.group;
      default: return Icons.description;
    }
  }
  
  Color _getReportColor(String type) {
    switch (type) {
      case 'إيرادات': return Colors.green;
      case 'حجوزات': return Colors.blue;
      case 'مستخدمين': return Colors.purple;
      case 'ملاعب': return Colors.orange;
      case 'دفع': return Colors.red;
      case 'طلبات لاعبين': return Colors.teal;
      default: return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير والإحصائيات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReportsData,
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Open report history
            },
            tooltip: 'السجل',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'تقارير مفصلة'),
            Tab(text: 'تحليلات متقدمة'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportReport,
        icon: _isGeneratingReport
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white),
              )
            : const Icon(Icons.picture_as_pdf),
        label: const Text('تصدير تقرير'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDetailedReportsTab(),
                _buildAnalyticsTab(),
              ],
            ),
    );
  }
}

// Data Models
class ChartData {
  final String label;
  final double value;
  
  ChartData(this.label, this.value);
}

class PieData {
  final String label;
  final double value;
  final Color color;
  
  PieData(this.label, this.value, this.color);
}

class SavedReport {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final String format;
  
  SavedReport({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.format,
  });
}
