import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/user_provider.dart';
import 'package:ehgezly_app/models/user.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/admin/user_edit_modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:async';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  List<User> _recentUsers = [];
  List<Stadium> _recentStadiums = [];
  Map<String, dynamic> _systemStats = {};
  List<SystemAlert> _alerts = [];
  List<SystemEvent> _recentEvents = [];
  bool _isLoading = true;
  Timer? _autoRefreshTimer;
  bool _isLiveMode = true;
  
  // بيانات المخططات
  List<ChartData> _revenueChartData = [];
  List<ChartData> _bookingsChartData = [];
  List<ChartData> _usersChartData = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
    _startAutoRefresh();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _stopAutoRefresh();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }
  
  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isLiveMode && mounted) {
        _loadDashboardData();
      }
    });
  }
  
  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }
  
  Future<void> _loadDashboardData() async {
    try {
      if (!mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // التحقق من صلاحية المدير
      if (!authProvider.user!.roles.contains('admin')) {
        throw Exception('ليس لديك صلاحية الوصول');
      }
      
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      // جلب البيانات المتوازية
      final futures = await Future.wait([
        userProvider.getRecentUsers(limit: 10),
        stadiumProvider.getRecentStadiums(limit: 10),
        userProvider.getSystemStats(),
        userProvider.getSystemAlerts(),
        userProvider.getRecentEvents(),
        bookingProvider.getRevenueChartData(days: 30),
        bookingProvider.getBookingsChartData(days: 30),
        userProvider.getUsersChartData(days: 30),
      ]);
      
      if (mounted) {
        setState(() {
          _recentUsers = futures[0] as List<User>;
          _recentStadiums = futures[1] as List<Stadium>;
          _systemStats = futures[2] as Map<String, dynamic>;
          _alerts = futures[3] as List<SystemAlert>;
          _recentEvents = futures[4] as List<SystemEvent>;
          _revenueChartData = futures[5] as List<ChartData>;
          _bookingsChartData = futures[6] as List<ChartData>;
          _usersChartData = futures[7] as List<ChartData>;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading admin dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Helpers.showErrorSnackbar(context, 'فشل في تحميل البيانات');
      }
    }
  }
  
  Widget _buildSystemOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقات الإحصائيات الرئيسية
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'المستخدمون النشطون',
                  _systemStats['activeUsers']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                  'اليوم',
                ),
                _buildStatCard(
                  'الحجوزات الناجحة',
                  _systemStats['successfulBookings']?.toString() ?? '0',
                  Icons.event_available,
                  Colors.green,
                  'هذا الشهر',
                ),
                _buildStatCard(
                  'الإيرادات الإجمالية',
                  Helpers.formatCurrency(_systemStats['totalRevenue'] ?? 0),
                  Icons.attach_money,
                  Colors.orange,
                  'هذا الشهر',
                ),
                _buildStatCard(
                  'معدل النمو',
                  '${_systemStats['growthRate']?.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                  'مقارنة بالشهر الماضي',
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // المخططات البيانية
            _buildChartsSection(),
            
            const SizedBox(height: 24),
            
            // التنبيهات المهمة
            if (_alerts.isNotEmpty) ...[
              _buildAlertsSection(),
              const SizedBox(height: 24),
            ],
            
            // المستخدمون الجدد
            _buildRecentUsersSection(),
            
            const SizedBox(height: 24),
            
            // الملاعب الجديدة
            _buildRecentStadiumsSection(),
            
            const SizedBox(height: 80), // مساحة للـ FAB
          ],
        ),
      ),
    );
  }
  
  Widget _buildSystemMonitoringTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // لوحة مراقبة النظام
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
                      'مراقبة النظام في الوقت الحقيقي',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isLiveMode,
                      onChanged: (value) {
                        setState(() => _isLiveMode = value);
                        if (value) {
                          _startAutoRefresh();
                        } else {
                          _stopAutoRefresh();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricItem('طلبات API الحية', '142', Colors.green),
                _buildMetricItem('استخدام الذاكرة', '68%', Colors.blue),
                _buildMetricItem('وقت الاستجابة', '124ms', Colors.orange),
                _buildMetricItem('حالة قواعد البيانات', 'نشطة', Colors.green),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // سجل الأحداث
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل الأحداث الحية',
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._recentEvents.take(5).map((event) {
                  return _buildEventItem(event);
                }).toList(),
                if (_recentEvents.length > 5) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: AppButton(
                      text: 'عرض الكل',
                      onPressed: () {
                        // TODO: Navigate to full events log
                      },
                      size: ButtonSize.small,
                      outlined: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // الإحصائيات الفورية
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildLiveStatCard('المستخدمون المتصلون', '24', Icons.person),
            _buildLiveStatCard('الحجوزات النشطة', '89', Icons.event),
            _buildLiveStatCard('عمليات الدفع', '12', Icons.payment),
            _buildLiveStatCard('أخطاء النظام', '3', Icons.warning),
          ],
        ),
      ],
    );
  }
  
  Widget _buildContentManagementTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // إدارة الملاعب
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
                      'إدارة الملاعب',
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppButton(
                      text: 'إضافة ملعب',
                      onPressed: () {
                        // TODO: Add stadium
                      },
                      size: ButtonSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDataGrid(_recentStadiums),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // إدارة المحتوى
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildManagementCard(
              'المقالات والإعلانات',
              Icons.article,
              Colors.blue,
              () {/* TODO */},
            ),
            _buildManagementCard(
              'الصفحات الثابتة',
              Icons.description,
              Colors.green,
              () {/* TODO */},
            ),
            _buildManagementCard(
              'البانرات والعروض',
              Icons.campaign,
              Colors.orange,
              () {/* TODO */},
            ),
            _buildManagementCard(
              'نسخ احتياطي',
              Icons.backup,
              Colors.purple,
              () {/* TODO */},
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تحليلات الأداء',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      labelRotation: -45,
                      labelStyle: const TextStyle(fontSize: 10),
                    ),
                    series: <LineSeries<ChartData, String>>[
                      LineSeries<ChartData, String>(
                        dataSource: _revenueChartData,
                        xValueMapper: (ChartData data, _) => data.label,
                        yValueMapper: (ChartData data, _) => data.value,
                        name: 'الإيرادات',
                        color: Colors.green,
                        markerSettings: const MarkerSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildChartTypeButton('الإيرادات', Colors.green),
                    _buildChartTypeButton('الحجوزات', Colors.blue),
                    _buildChartTypeButton('المستخدمون', Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التنبيهات المهمة',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              label: Text('${_alerts.length}'),
              backgroundColor: Colors.red,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._alerts.take(3).map((alert) {
          return _buildAlertItem(alert);
        }).toList(),
        if (_alerts.length > 3) ...[
          const SizedBox(height: 12),
          Center(
            child: AppButton(
              text: 'عرض جميع التنبيهات',
              onPressed: () {
                // TODO: Show all alerts
              },
              size: ButtonSize.small,
              outlined: true,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildRecentUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المستخدمون الجدد',
              style: Theme.of(context).textTheme.subtitle1?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppButton(
              text: 'عرض الكل',
              onPressed: () {
                AppRoutes.goToUsersManagement(context);
              },
              size: ButtonSize.small,
              outlined: true,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentUsers.take(5).map((user) {
          return _buildUserItem(user);
        }).toList(),
      ],
    );
  }
  
  Widget _buildRecentStadiumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الملاعب المضافة حديثاً',
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentStadiums.take(3).map((stadium) {
          return _buildStadiumItem(stadium);
        }).toList(),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
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
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.caption?.copyWith(
                    color: Colors.grey[600],
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
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyText1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventItem(SystemEvent event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event.type),
            size: 16,
            color: _getEventColor(event.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                Text(
                  Helpers.formatTimeAgo(event.timestamp),
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLiveStatCard(String title, String value, IconData icon) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
  
  Widget _buildManagementCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return AppCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle2?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChartTypeButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  Widget _buildAlertItem(SystemAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAlertColor(alert.level).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getAlertIcon(alert.level),
            color: _getAlertColor(alert.level),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          Text(
            Helpers.formatTimeAgo(alert.timestamp),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserItem(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.phone,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              user.primaryRole,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            backgroundColor: _getRoleColor(user.primaryRole),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStadiumItem(Stadium stadium) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (stadium.type == 'football' ? Colors.blue : Colors.green)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              stadium.type == 'football' ? Icons.sports_soccer : Icons.sports_tennis,
              color: stadium.type == 'football' ? Colors.blue : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stadium.name,
                  style: Theme.of(context).textTheme.bodyText2?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  stadium.address,
                  style: Theme.of(context).textTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            Helpers.formatCurrency(stadium.pricePerHour),
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataGrid(List<Stadium> stadiums) {
    return SizedBox(
      height: 300,
      child: SfDataGrid(
        source: StadiumDataSource(stadiums),
        columns: [
          GridColumn(
            columnName: 'name',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: const Text('الاسم'),
            ),
          ),
          GridColumn(
            columnName: 'type',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: const Text('النوع'),
            ),
          ),
          GridColumn(
            columnName: 'price',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: const Text('السعر'),
            ),
          ),
          GridColumn(
            columnName: 'status',
            label: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerRight,
              child: const Text('الحالة'),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAlertColor(String level) {
    switch (level) {
      case 'critical': return Colors.red;
      case 'warning': return Colors.orange;
      case 'info': return Colors.blue;
      default: return Colors.grey;
    }
  }
  
  IconData _getAlertIcon(String level) {
    switch (level) {
      case 'critical': return Icons.error;
      case 'warning': return Icons.warning;
      case 'info': return Icons.info;
      default: return Icons.notifications;
    }
  }
  
  IconData _getEventIcon(String type) {
    switch (type) {
      case 'login': return Icons.login;
      case 'payment': return Icons.payment;
      case 'booking': return Icons.event;
      case 'user': return Icons.person;
      default: return Icons.notifications;
    }
  }
  
  Color _getEventColor(String type) {
    switch (type) {
      case 'login': return Colors.blue;
      case 'payment': return Colors.green;
      case 'booking': return Colors.orange;
      case 'user': return Colors.purple;
      default: return Colors.grey;
    }
  }
  
  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'owner': return Colors.orange;
      case 'staff': return Colors.blue;
      case 'player': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // التحقق من صلاحية المدير
    if (!authProvider.user!.roles.contains('admin')) {
      return const Scaffold(
        body: Center(
          child: Text('ليس لديك صلاحية الوصول'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Open admin settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'مراقبة النظام'),
            Tab(text: 'إدارة المحتوى'),
          ],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppRoutes.goToUsersManagement(context);
        },
        icon: const Icon(Icons.people),
        label: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSystemOverviewTab(),
                _buildSystemMonitoringTab(),
                _buildContentManagementTab(),
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

class SystemAlert {
  final String id;
  final String title;
  final String message;
  final String level; // critical, warning, info
  final DateTime timestamp;
  
  SystemAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.timestamp,
  });
}

class SystemEvent {
  final String id;
  final String type; // login, payment, booking, user
  final String description;
  final DateTime timestamp;
  
  SystemEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });
}

// Data Source for Grid
class StadiumDataSource extends DataGridSource {
  StadiumDataSource(List<Stadium> stadiums) {
    _stadiumData = stadiums
        .map<DataGridRow>((stadium) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: stadium.name),
              DataGridCell<String>(
                columnName: 'type',
                value: stadium.type == 'football' ? 'كرة قدم' : 'بادل',
              ),
              DataGridCell<String>(
                columnName: 'price',
                value: '${stadium.pricePerHour} ج.م/ساعة',
              ),
              DataGridCell<String>(
                columnName: 'status',
                value: stadium.isActive ? 'نشط' : 'غير نشط',
              ),
            ]))
        .toList();
  }

  List<DataGridRow> _stadiumData = [];

  @override
  List<DataGridRow> get rows => _stadiumData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.centerRight,
        child: Text(
          dataGridCell.value.toString(),
          style: const TextStyle(fontSize: 12),
        ),
      );
    }).toList());
  }
}
