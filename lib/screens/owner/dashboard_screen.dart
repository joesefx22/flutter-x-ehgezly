import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/owner/owner_stats_card.dart';
import 'package:ehgezly_app/widgets/owner/field_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:ehgezly_app/routes/app_routes.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['ملاعبي', 'الأداء', 'التقارير'];
  
  bool _isLoading = true;
  List<Stadium> _stadiums = [];
  Map<String, dynamic> _stats = {};
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDashboardData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      setState(() => _isLoading = true);
      
      // جلب ملاعب المالك
      final stadiums = await stadiumProvider.getOwnerStadiums(authProvider.user!.id);
      _stadiums = stadiums;
      
      // جلب إحصائيات المالك
      _stats = {
        'totalRevenue': 0.0,
        'monthlyRevenue': 0.0,
        'activeBookings': 0,
        'occupancyRate': 0.0,
        'newCustomers': 0,
        'totalStadiums': stadiums.length,
      };
      
      // حساب الإحصائيات
      for (var stadium in stadiums) {
        final bookings = await bookingProvider.getStadiumBookings(stadium.id);
        final activeBookings = bookings.where((b) => 
          b.status == 'confirmed' && 
          DateTime.parse(b.date).isAfter(DateTime.now())
        ).length;
        
        final monthlyRevenue = bookings.where((b) =>
          DateTime.parse(b.date).month == DateTime.now().month
        ).fold(0.0, (sum, b) => sum + b.amount);
        
        _stats['activeBookings'] += activeBookings;
        _stats['monthlyRevenue'] += monthlyRevenue;
        _stats['totalRevenue'] += stadium.totalRevenue ?? 0;
      }
      
      // حساب معدل الإشغال
      if (stadiums.isNotEmpty) {
        double totalOccupancy = 0;
        for (var stadium in stadiums) {
          totalOccupancy += stadium.occupancyRate ?? 0;
        }
        _stats['occupancyRate'] = totalOccupancy / stadiums.length;
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading owner dashboard: $e');
      setState(() => _isLoading = false);
      Helpers.showErrorSnackbar(context, 'فشل في تحميل البيانات');
    }
  }
  
  List<Stadium> _getFilteredStadiums() {
    if (_searchQuery.isEmpty) return _stadiums;
    return _stadiums.where((stadium) =>
      stadium.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      stadium.address.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }
  
  Widget _buildWelcomeCard() {
    final user = Provider.of<AuthProvider>(context).user;
    
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'م',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً, ${user?.name ?? "المالك"}!',
                      style: Theme.of(context).textTheme.headline6?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مالك ${_stats['totalStadiums'] ?? 0} ملعب',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                onPressed: () {
                  // TODO: Navigate to notifications
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuickStat(
                'الإيرادات الشهرية',
                Helpers.formatCurrency(_stats['monthlyRevenue']),
                Icons.attach_money,
                Colors.green,
              ),
              _buildQuickStat(
                'الحجوزات النشطة',
                '${_stats['activeBookings']}',
                Icons.event_available,
                Colors.blue,
              ),
              _buildQuickStat(
                'معدل الإشغال',
                '${_stats['occupancyRate']?.toStringAsFixed(1)}%',
                Icons.percent,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.subtitle1?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.caption?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'الإحصائيات العامة',
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          padding: const EdgeInsets.all(8),
          children: [
            OwnerStatsCard(
              title: 'إجمالي الإيرادات',
              value: _stats['totalRevenue'],
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              isCurrency: true,
              trendValue: 12.5, // نمو 12.5%
            ),
            OwnerStatsCard(
              title: 'الحجوزات الشهرية',
              value: _stats['activeBookings'].toDouble(),
              icon: Icons.calendar_today,
              color: Colors.blue,
              trendValue: 8.2,
            ),
            OwnerStatsCard(
              title: 'معدل الإشغال',
              value: _stats['occupancyRate'],
              icon: Icons.percent,
              color: Colors.orange,
              unit: '%',
              trendValue: 5.3,
            ),
            OwnerStatsCard(
              title: 'عملاء جدد',
              value: _stats['newCustomers'].toDouble(),
              icon: Icons.person_add,
              color: Colors.purple,
              trendValue: 15.7,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildStadiumsTab() {
    final filteredStadiums = _getFilteredStadiums();
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن ملعب...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: filteredStadiums.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stadium_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'لا توجد ملاعب'
                              : 'لا توجد ملاعب مطابقة للبحث',
                          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'أضف ملعبك الأول',
                            onPressed: () {
                              // TODO: Navigate to add stadium
                            },
                            size: ButtonSize.medium,
                          ),
                        ],
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filteredStadiums.length,
                    itemBuilder: (context, index) {
                      return FieldCard(
                        stadium: filteredStadiums[index],
                        onTap: () {
                          AppRoutes.goToStadiumManagement(
                            context,
                            filteredStadiums[index].id,
                          );
                        },
                        compact: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPerformanceTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'تحليلات الأداء',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: 8),
          Text(
            'هذا القسم قيد التطوير',
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'عرض التقارير المتقدمة',
            onPressed: () {
              AppRoutes.goToAdminReports(context);
            },
            size: ButtonSize.medium,
            outlined: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportCard(
          'تقرير اليوم',
          Icons.today,
          Colors.blue,
          'ملخص أداء اليوم',
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'تقرير الأسبوع',
          Icons.calendar_view_week,
          Colors.green,
          'تحليل أداء الأسبوع',
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'تقرير الشهر',
          Icons.calendar_view_month,
          Colors.orange,
          'تقارير أداء الشهر',
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          'تقرير العملاء',
          Icons.people,
          Colors.purple,
          'تحليل سلوك العملاء',
        ),
      ],
    );
  }
  
  Widget _buildReportCard(String title, IconData icon, Color color, String description) {
    return AppCard(
      onTap: () {
        // TODO: Open report details
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
                  Text(
                    description,
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المالك'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add stadium
        },
        icon: const Icon(Icons.add),
        label: const Text('أضف ملعب'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStadiumsTab(),
                      _buildPerformanceTab(),
                      _buildReportsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
