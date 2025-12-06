import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/staff/staff_card.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StaffDashboardScreen extends StatefulWidget {
  static const routeName = '/staff/dashboard';
  
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  List<Stadium> _assignedStadiums = [];
  Map<String, int> _todayBookingsCount = {};
  Map<String, double> _todayRevenue = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      final user = authProvider.user;
      if (user == null || user.stadiums.isEmpty) return;
      
      // Load assigned stadiums
      await stadiumProvider.loadStadiums();
      _assignedStadiums = stadiumProvider.stadiums
          .where((stadium) => user.stadiums.contains(stadium.id))
          .toList();
      
      // Load today's bookings for each stadium
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      for (final stadium in _assignedStadiums) {
        await bookingProvider.loadStadiumBookings(stadium.id);
        
        final todayBookings = bookingProvider.bookings
            .where((booking) => 
                booking.stadiumId == stadium.id &&
                Helpers.isSameDay(booking.date, today) &&
                booking.status == 'confirmed')
            .toList();
        
        _todayBookingsCount[stadium.id] = todayBookings.length;
        _todayRevenue[stadium.id] = todayBookings.fold(
          0.0, 
          (sum, booking) => sum + (booking.amount ?? 0)
        );
      }
      
    } catch (e) {
      print('Error loading staff dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader(AuthProvider authProvider, ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.work,
              size: 32,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، ${authProvider.user!.name} 👋',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'موظف - ${_assignedStadiums.length} ملعب',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(ThemeData theme) {
    final totalBookings = _todayBookingsCount.values.fold(0, (sum, count) => sum + count);
    final totalRevenue = _todayRevenue.values.fold(0.0, (sum, revenue) => sum + revenue);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة عامة على اليوم',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                value: totalBookings.toString(),
                label: 'حجوزات اليوم',
                color: Colors.blue,
                theme: theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.attach_money,
                value: Helpers.formatCurrency(totalRevenue),
                label: 'إيرادات اليوم',
                color: Colors.green,
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedStadiums(ThemeData theme) {
    if (_assignedStadiums.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.sports_soccer,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد ملاعب مسندة',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة الملاعب من قبل المالك',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الملاعب المسندة لك',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all stadiums
              },
              child: Text(
                'عرض الكل',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ..._assignedStadiums.map((stadium) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/staff/stadiums/${stadium.id}/dashboard',
                  arguments: {'stadium': stadium},
                );
              },
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Stadium Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        stadium.type == 'football' 
                            ? Icons.sports_soccer 
                            : Icons.sports_tennis,
                        color: theme.primaryColor,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Stadium Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stadium.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stadium.address.split(',').first,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Today's Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_todayBookingsCount[stadium.id] ?? 0} حجز',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          Helpers.formatCurrency(_todayRevenue[stadium.id] ?? 0),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_left),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: Icons.add_circle,
              label: 'حجز جديد',
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/staff/bookings/create');
              },
            ),
            _buildQuickActionCard(
              icon: Icons.group,
              label: 'طلبات لاعبين',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/staff/players-requests');
              },
            ),
            _buildQuickActionCard(
              icon: Icons.assessment,
              label: 'التقارير',
              color: Colors.orange,
              onTap: () {
                // TODO: Navigate to reports
              },
            ),
            _buildQuickActionCard(
              icon: Icons.schedule,
              label: 'حضوري',
              color: Colors.purple,
              onTap: () {
                // TODO: Navigate to attendance
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    if (authProvider.user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'يتم تحميل بيانات المستخدم...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الموظف'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(authProvider, theme),

                    const SizedBox(height: 24),

                    // Stats Overview
                    _buildStatsOverview(theme),

                    const SizedBox(height: 24),

                    // Assigned Stadiums
                    _buildAssignedStadiums(theme),

                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(theme),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/staff/bookings/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
