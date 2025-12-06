import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/auth_provider.dart';
import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/widgets/bookings/booking_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';
import 'package:ehgezly_app/services/booking_service.dart';

class PlayerBookingsScreen extends StatefulWidget {
  static const routeName = '/player/bookings';
  
  const PlayerBookingsScreen({super.key});

  @override
  State<PlayerBookingsScreen> createState() => _PlayerBookingsScreenState();
}

class _PlayerBookingsScreenState extends State<PlayerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['القادمة', 'السابقة', 'الملغاة'];
  final List<BookingStatus> _tabStatuses = [
    BookingStatus.confirmed,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];
  
  String _selectedFilter = 'all'; // all, football, paddle
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBookings() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.loadUserBookings();
    });
  }

  List<Booking> _getFilteredBookings(BookingProvider provider) {
    final status = _tabStatuses[_tabController.index];
    var bookings = provider.bookings
        .where((booking) => booking.status == status)
        .toList();

    // Filter by sport type
    if (_selectedFilter != 'all') {
      // TODO: Filter by stadium type when stadium data is available
    }

    // Filter by date
    if (_selectedDate != null) {
      bookings = bookings
          .where((booking) => 
              Helpers.isSameDay(booking.date, _selectedDate!))
          .toList();
    }

    // Sort by date (newest first for upcoming, oldest first for past)
    bookings.sort((a, b) {
      if (status == BookingStatus.confirmed) {
        return a.date.compareTo(b.date); // Ascending for upcoming
      } else {
        return b.date.compareTo(a.date); // Descending for past
      }
    });

    return bookings;
  }

  Future<void> _cancelBooking(Booking booking) async {
    final result = await showModal(
      context: context,
      title: 'تأكيد الإلغاء',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'هل أنت متأكد من إلغاء هذا الحجز؟',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          if (booking.canCancel)
            Text(
              'يمكنك الإلغاء مجاناً قبل ساعتين من الموعد.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.green,
              ),
            )
          else
            Text(
              'لن يتم استرداد العربون بعد هذا الوقت.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
              ),
            ),
        ],
      ),
      actions: [
        AppButton(
          text: 'إلغاء',
          type: ButtonType.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        AppButton(
          text: 'نعم، ألغِ الحجز',
          type: ButtonType.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (result == true) {
      try {
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        await bookingProvider.cancelBooking(booking.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إلغاء الحجز: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFiltersModal() {
    showModal(
      context: context,
      title: 'تصفية الحجوزات',
      content: _buildFiltersContent(),
      actions: [
        AppButton(
          text: 'إعادة تعيين',
          type: ButtonType.outline,
          onPressed: () {
            setState(() {
              _selectedFilter = 'all';
              _selectedDate = null;
            });
            Navigator.pop(context);
          },
        ),
        AppButton(
          text: 'تطبيق',
          type: ButtonType.primary,
          onPressed: () {
            Navigator.pop(context);
            _loadBookings();
          },
        ),
      ],
    );
  }

  Widget _buildFiltersContent() {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('نوع الرياضة', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('الكل', 'all'),
              _buildFilterChip('كرة قدم', 'football'),
              _buildFilterChip('بادل', 'paddle'),
            ],
          ),
          
          const SizedBox(height: 20),
          Text('التاريخ', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          
          Wrap(
            spacing: 8,
            children: [
              _buildDateChip('اليوم', DateTime(now.year, now.month, now.day)),
              _buildDateChip('غداً', DateTime(now.year, now.month, now.day + 1)),
              _buildDateChip('هذا الأسبوع', null), // TODO: Calculate week range
              _buildDateChip('هذا الشهر', null), // TODO: Calculate month range
            ],
          ),
          
          const SizedBox(height: 12),
          AppButton(
            text: 'اختر تاريخ محدد',
            type: ButtonType.outline,
            icon: Icons.calendar_today,
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(2023),
                lastDate: DateTime(2025),
              );
              if (selected != null) {
                setState(() {
                  _selectedDate = selected;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildDateChip(String label, DateTime? date) {
    final isSelected = _selectedDate != null && 
        date != null && 
        Helpers.isSameDay(_selectedDate!, date);
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDate = selected ? date : null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    final filteredBookings = _getFilteredBookings(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabTitles.map((title) {
          return _buildTabContent(
            bookings: filteredBookings,
            provider: bookingProvider,
            theme: theme,
            title: title,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/stadiums');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTabContent({
    required List<Booking> bookings,
    required BookingProvider provider,
    required ThemeData theme,
    required String title,
  }) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTabIcon(title),
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(title),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(title),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (title == 'القادمة')
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AppButton(
                  text: 'احجز الآن',
                  type: ButtonType.primary,
                  onPressed: () {
                    Navigator.pushNamed(context, '/stadiums');
                  },
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadUserBookings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BookingCard(
              booking: booking,
              onTap: () {
                // TODO: Navigate to booking details
              },
              onCancel: booking.status == BookingStatus.confirmed 
                  ? () => _cancelBooking(booking) 
                  : null,
              onPay: booking.status == BookingStatus.confirmed && 
                     booking.paymentStatus != PaymentStatus.paid
                  ? () {
                      // TODO: Navigate to payment
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getTabIcon(String title) {
    switch (title) {
      case 'القادمة':
        return Icons.calendar_today;
      case 'السابقة':
        return Icons.history;
      case 'الملغاة':
        return Icons.cancel;
      default:
        return Icons.list;
    }
  }

  String _getEmptyMessage(String title) {
    switch (title) {
      case 'القادمة':
        return 'لا توجد حجوزات قادمة';
      case 'السابقة':
        return 'لا توجد حجوزات سابقة';
      case 'الملغاة':
        return 'لا توجد حجوزات ملغاة';
      default:
        return 'لا توجد حجوزات';
    }
  }

  String _getEmptySubtitle(String title) {
    switch (title) {
      case 'القادمة':
        return 'ابدأ بحجز ملعب جديد من الزر "+" أسفل الشاشة';
      case 'السابقة':
        return 'جميع حجوزاتك السابقة ستظهر هنا';
      case 'الملغاة':
        return 'الحجوزات الملغاة ستظهر هنا';
      default:
        return '';
    }
  }
}
