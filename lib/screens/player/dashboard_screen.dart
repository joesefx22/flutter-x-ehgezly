import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/routes/app_routes.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/models/play_request.dart';
import 'package:ehgezly_app/widgets/common/card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/bookings/booking_card.dart';
import 'package:ehgezly_app/widgets/player/request_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlayerDashboardScreen extends StatefulWidget {
  static const routeName = '/player/dashboard';
  
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  bool _isLoading = true;
  List<Booking> _upcomingBookings = [];
  List<PlayRequest> _activeRequests = [];
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;
      
      if (userId == null) {
        // User not logged in, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        });
        return;
      }

      // Load bookings
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.loadUserBookings();
      
      // Filter upcoming bookings (confirmed and future dates)
      final now = DateTime.now();
      _upcomingBookings = bookingProvider.bookings
          .where((booking) => 
              booking.status == BookingStatus.confirmed &&
              booking.date.isAfter(now))
          .toList();
      
      // Sort by date (closest first)
      _upcomingBookings.sort((a, b) => a.date.compareTo(b.date));
      
      // Take only 3 for dashboard
      if (_upcomingBookings.length > 3) {
        _upcomingBookings = _upcomingBookings.sublist(0, 3);
      }

      // Load play requests
      final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      await playRequestProvider.loadUserRequests();
      
      // Filter active requests (open or partial)
      _activeRequests = playRequestProvider.playRequests
          .where((request) => 
              request.status == PlayRequestStatus.open ||
              request.status == PlayRequestStatus.partial)
          .toList();
      
      // Take only 3 for dashboard
      if (_activeRequests.length > 3) {
        _activeRequests = _activeRequests.sublist(0, 3);
      }

      // TODO: Load unread notifications count
      // For now, simulate with random number
      _unreadNotifications = 3;

    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildStatsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة سريعة',
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
                value: _upcomingBookings.length.toString(),
                label: 'حجوزات قادمة',
                color: Colors.blue,
                theme: theme,
                onTap: () {
                  Navigator.pushNamed(context, '/player/bookings');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.group,
                value: _activeRequests.length.toString(),
                label: 'طلبات نشطة',
                color: Colors.green,
                theme: theme,
                onTap: () {
                  Navigator.pushNamed(context, '/player/requests');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.notifications,
                value: _unreadNotifications.toString(),
                label: 'إشعارات',
                color: Colors.orange,
                theme: theme,
                badge: _unreadNotifications > 0,
                onTap: () {
                  Navigator.pushNamed(context, '/player/notifications');
                },
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
    bool badge = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
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
            if (badge && onTap != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBookings(ThemeData theme) {
    if (_upcomingBookings.isEmpty) {
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
              'لا توجد حجوزات قادمة',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'احجز ملعبك الأول الآن',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'احجز ملعب',
              type: ButtonType.primary,
              onPressed: () {
                Navigator.pushNamed(context, '/stadiums');
              },
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
              'حجوزاتك القادمة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/player/bookings');
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
        
        ..._upcomingBookings.map((booking) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              compact: true,
              onTap: () {
                // TODO: Navigate to booking details
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActiveRequests(ThemeData theme) {
    if (_activeRequests.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.group,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد طلبات نشطة',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث عن لاعبين أو أنشئ طلباً',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'اطلب لاعبين',
              type: ButtonType.primary,
              onPressed: () {
                Navigator.pushNamed(context, '/player/create-request');
              },
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
              'طلبات اللاعبين',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/player/requests');
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
        
        ..._activeRequests.map((request) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RequestCard(
              playRequest: request,
              compact: true,
              onTap: () {
                // TODO: Navigate to request details
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
              icon: Icons.sports_soccer,
              label: 'احجز ملعب',
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/stadiums');
              },
            ),
            _buildQuickActionCard(
              icon: Icons.group_add,
              label: 'اطلب لاعبين',
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/player/create-request');
              },
            ),
            _buildQuickActionCard(
              icon: Icons.search,
              label: 'ابحث عن فرق',
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/play-search');
              },
            ),
            _buildQuickActionCard(
              icon: Icons.history,
              label: 'طلباتي',
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/player/requests');
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
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

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
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _unreadNotifications > 9 
                            ? '9+' 
                            : _unreadNotifications.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/player/notifications');
            },
          ),
        ],
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
                    // Welcome Header
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
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
                                  'لاعب نشط',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              Navigator.pushNamed(context, '/player/profile');
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Stats
                    _buildStatsSection(theme),

                    const SizedBox(height: 24),

                    // Upcoming Bookings
                    _buildUpcomingBookings(theme),

                    const SizedBox(height: 24),

                    // Active Requests
                    _buildActiveRequests(theme),

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
          Navigator.pushNamed(context, '/player/create-request');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
