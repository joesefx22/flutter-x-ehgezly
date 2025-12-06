import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/bookings/booking_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StaffStadiumDashboardScreen extends StatefulWidget {
  static const routeName = '/staff/stadiums/:id/dashboard';
  
  const StaffStadiumDashboardScreen({super.key});

  @override
  State<StaffStadiumDashboardScreen> createState() => _StaffStadiumDashboardScreenState();
}

class _StaffStadiumDashboardScreenState extends State<StaffStadiumDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Stadium? _stadium;
  List<Booking> _todayBookings = [];
  List<Booking> _upcomingBookings = [];
  double _todayRevenue = 0.0;
  int _totalBookings = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStadiumData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadStadiumData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['stadium'] != null) {
        setState(() {
          _stadium = args['stadium'] as Stadium;
        });
        
        await _loadBookingsData();
      }
    });
  }

  Future<void> _loadBookingsData() async {
    if (_stadium == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.loadStadiumBookings(_stadium!.id);
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Filter bookings
      final allBookings = bookingProvider.bookings
          .where((booking) => booking.stadiumId == _stadium!.id)
          .toList();
      
      _todayBookings = allBookings
          .where((booking) => 
              Helpers.isSameDay(booking.date, today) &&
              booking.status == BookingStatus.confirmed)
          .toList();
      
      _upcomingBookings = allBookings
          .where((booking) => 
              booking.date.isAfter(now) &&
              booking.status == BookingStatus.confirmed)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      
      // Calculate stats
      _todayRevenue = _todayBookings.fold(
        0.0, 
        (sum, booking) => sum + (booking.amount ?? 0)
      );
      
      _totalBookings = allBookings.length;
      
    } catch (e) {
      print('Error loading stadium bookings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatsSection(ThemeData theme) {
    final occupancyRate = _stadium != null && _stadium!.slots.isNotEmpty
        ? (_todayBookings.length / _stadium!.slots.length * 100).toStringAsFixed(1)
        : '0.0';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات الملعب',
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
            _buildStatCard(
              icon: Icons.calendar_today,
              value: _todayBookings.length.toString(),
              label: 'حجوزات اليوم',
              color: Colors.blue,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.attach_money,
              value: Helpers.formatCurrency(_todayRevenue),
              label: 'إيرادات اليوم',
              color: Colors.green,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.assessment,
              value: _totalBookings.toString(),
              label: 'إجمالي الحجوزات',
              color: Colors.orange,
              theme: theme,
            ),
            _buildStatCard(
              icon: Icons.timeline,
              value: '$occupancyRate%',
              label: 'معدل الإشغال',
              color: Colors.purple,
              theme: theme,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayBookings(ThemeData theme) {
    if (_todayBookings.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد حجوزات لليوم',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إنشاء حجز جديد من الزر "+"',
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
              'حجوزات اليوم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/staff/stadiums/${_stadium!.id}/bookings',
                  arguments: {'stadium': _stadium},
                );
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
        
        ..._todayBookings.take(3).map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              compact: true,
              onTap: () {
                _showBookingDetails(booking);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUpcomingBookings(ThemeData theme) {
    if (_upcomingBookings.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.upcoming,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد حجوزات قادمة',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم عرض الحجوزات القادمة هنا',
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
              'الحجوزات القادمة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/staff/stadiums/${_stadium!.id}/bookings',
                  arguments: {'stadium': _stadium},
                );
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
        
        ..._upcomingBookings.take(3).map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              compact: true,
              onTap: () {
                _showBookingDetails(booking);
              },
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
          'إدارة الملعب',
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
            _buildManagementCard(
              icon: Icons.calendar_today,
              label: 'إدارة الحجوزات',
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/staff/stadiums/${_stadium!.id}/bookings',
                  arguments: {'stadium': _stadium},
                );
              },
            ),
            _buildManagementCard(
              icon: Icons.group,
              label: 'طلبات اللاعبين',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/staff/stadiums/${_stadium!.id}/players-requests',
                  arguments: {'stadium': _stadium},
                );
              },
            ),
            _buildManagementCard(
              icon: Icons.settings,
              label: 'إعدادات الملعب',
              color: Colors.orange,
              onTap: () {
                // TODO: Stadium settings
              },
            ),
            _buildManagementCard(
              icon: Icons.assessment,
              label: 'تقارير مفصلة',
              color: Colors.purple,
              onTap: () {
                // TODO: Detailed reports
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagementCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تفاصيل الحجز',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Booking Details
              _buildDetailRow('رقم الحجز:', booking.id.substring(0, 8)),
              _buildDetailRow('الحالة:', _getStatusText(booking.status)),
              _buildDetailRow('التاريخ:', Helpers.formatDate(booking.date)),
              _buildDetailRow('الوقت:', '${booking.startTime} - ${booking.endTime}'),
              _buildDetailRow('المبلغ:', Helpers.formatCurrency(booking.amount ?? 0)),
              
              if (booking.playersCount != null)
                _buildDetailRow('عدد اللاعبين:', booking.playersCount.toString()),
              
              if (booking.notes != null && booking.notes!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'ملاحظات:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(booking.notes!),
                  ],
                ),
              
              const SizedBox(height: 20),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'إغلاق',
                      type: ButtonType.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'اتصال بالعميل',
                      type: ButtonType.primary,
                      icon: Icons.phone,
                      onPressed: () {
                        // TODO: Call customer
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.pending:
        return 'معلق';
      case BookingStatus.cancelled:
        return 'ملغى';
      case BookingStatus.completed:
        return 'مكتمل';
      default:
        return status.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stadium == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة الملعب')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_stadium!.name),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'نظرة عامة'),
              Tab(text: 'حجوزات اليوم'),
              Tab(text: 'القادمة'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadBookingsData,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Overview Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stadium Info
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(
                                  _stadium!.type == 'football' 
                                      ? Icons.sports_soccer 
                                      : Icons.sports_tennis,
                                  size: 40,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _stadium!.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _stadium!.address,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Stats
                          _buildStatsSection(theme),

                          const SizedBox(height: 24),

                          // Management
                          _buildQuickActions(theme),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    // Today's Bookings Tab
                    _todayBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 80,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد حجوزات لليوم',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'يمكنك إنشاء حجز جديد من الزر "+"',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AppButton(
                                  text: 'إنشاء حجز',
                                  type: ButtonType.primary,
                                  onPressed: () {
                                    // TODO: Create booking
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _todayBookings.length,
                            itemBuilder: (context, index) {
                              final booking = _todayBookings[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BookingCard(
                                  booking: booking,
                                  onTap: () => _showBookingDetails(booking),
                                ),
                              );
                            },
                          ),

                    // Upcoming Bookings Tab
                    _upcomingBookings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upcoming,
                                  size: 80,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد حجوزات قادمة',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _upcomingBookings.length,
                            itemBuilder: (context, index) {
                              final booking = _upcomingBookings[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: BookingCard(
                                  booking: booking,
                                  onTap: () => _showBookingDetails(booking),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/staff/bookings/create',
              arguments: {'stadium': _stadium},
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
