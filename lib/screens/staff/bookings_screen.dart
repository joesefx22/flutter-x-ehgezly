import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/bookings/booking_card.dart';
import 'package:ehgezly_app/widgets/bookings/booking_modal.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StaffBookingsScreen extends StatefulWidget {
  static const routeName = '/staff/stadiums/:id/bookings';
  
  const StaffBookingsScreen({super.key});

  @override
  State<StaffBookingsScreen> createState() => _StaffBookingsScreenState();
}

class _StaffBookingsScreenState extends State<StaffBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Stadium? _stadium;
  List<Stadium> _assignedStadiums = [];
  String? _selectedStadiumId;
  DateTime? _selectedDate;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      await stadiumProvider.loadStadiums();
      
      if (args != null && args['stadium'] != null) {
        setState(() {
          _stadium = args['stadium'] as Stadium;
          _selectedStadiumId = _stadium!.id;
        });
      }
      
      // Get assigned stadiums from user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null && user.stadiums.isNotEmpty) {
        _assignedStadiums = stadiumProvider.stadiums
            .where((stadium) => user.stadiums.contains(stadium.id))
            .toList();
        
        if (_selectedStadiumId == null && _assignedStadiums.isNotEmpty) {
          _selectedStadiumId = _assignedStadiums.first.id;
        }
      }
      
      if (_selectedStadiumId != null) {
        await _loadBookings();
      }
      
      setState(() => _isLoading = false);
    });
  }

  Future<void> _loadBookings() async {
    if (_selectedStadiumId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.loadStadiumBookings(_selectedStadiumId!);
    } catch (e) {
      print('Error loading bookings: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Booking> _getFilteredBookings(BookingProvider provider) {
    if (_selectedStadiumId == null) return [];
    
    var bookings = provider.bookings
        .where((booking) => booking.stadiumId == _selectedStadiumId)
        .toList();
    
    // Filter by tab
    final tabIndex = _tabController.index;
    switch (tabIndex) {
      case 0: // اليوم
        final today = DateTime.now();
        bookings = bookings
            .where((booking) => Helpers.isSameDay(booking.date, today))
            .toList();
        break;
      case 1: // القادمة
        final now = DateTime.now();
        bookings = bookings
            .where((booking) => booking.date.isAfter(now))
            .toList();
        break;
      case 2: // المكتملة
        bookings = bookings
            .where((booking) => booking.status == BookingStatus.completed)
            .toList();
        break;
      case 3: // الملغاة
        bookings = bookings
            .where((booking) => booking.status == BookingStatus.cancelled)
            .toList();
        break;
    }
    
    // Filter by date
    if (_selectedDate != null && tabIndex != 0) {
      bookings = bookings
          .where((booking) => Helpers.isSameDay(booking.date, _selectedDate!))
          .toList();
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      bookings = bookings
          .where((booking) => 
              booking.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (booking.userName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    // Sort by date
    bookings.sort((a, b) => b.date.compareTo(a.date));
    
    return bookings;
  }

  void _showCreateBookingModal() {
    if (_selectedStadiumId == null && _assignedStadiums.isEmpty) return;
    
    final stadium = _assignedStadiums.firstWhere(
      (s) => s.id == _selectedStadiumId,
      orElse: () => _assignedStadiums.first,
    );
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BookingModal(
          stadium: stadium,
          isStaffBooking: true,
          onBookingSuccess: () {
            _loadBookings();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الحجز بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    final result = await showModal(
      context: context,
      title: 'إلغاء الحجز',
      content: const Text('هل أنت متأكد من إلغاء هذا الحجز؟'),
      actions: [
        AppButton(
          text: 'إلغاء',
          type: ButtonType.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        AppButton(
          text: 'تأكيد الإلغاء',
          type: ButtonType.danger,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    
    if (result == true) {
      try {
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        await bookingProvider.cancelBooking(booking.id, isStaff: true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إلغاء الحجز بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadBookings();
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

  Future<void> _confirmBooking(Booking booking) async {
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.confirmBooking(booking.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تأكيد الحجز بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تأكيد الحجز: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStadiumSelector(ThemeData theme) {
    if (_assignedStadiums.length <= 1) return const SizedBox();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedStadiumId,
        decoration: InputDecoration(
          labelText: 'اختر الملعب',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: _assignedStadiums.map((stadium) {
          return DropdownMenuItem(
            value: stadium.id,
            child: Text(stadium.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedStadiumId = value;
          });
          _loadBookings();
        },
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث برقم الحجز أو اسم العميل',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showDateFilter();
            },
          ),
        ],
      ),
    );
  }

  void _showDateFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تصفية حسب التاريخ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              if (_selectedDate != null)
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: const Text('إزالة التصفية'),
                  onTap: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('اختر تاريخ'),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime(2025),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedDate = selected;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
              
              const SizedBox(height: 20),
              AppButton(
                text: 'تم',
                type: ButtonType.primary,
                onPressed: () => Navigator.pop(context),
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(
    BookingProvider provider,
    ThemeData theme,
    String tabTitle,
    List<Booking> bookings,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_selectedStadiumId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'اختر ملعباً',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'يجب اختيار ملعب لعرض حجوزاته',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getTabIcon(tabTitle),
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyMessage(tabTitle),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptySubtitle(tabTitle),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (tabTitle == 'اليوم' || tabTitle == 'القادمة')
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: AppButton(
                  text: 'إنشاء حجز',
                  type: ButtonType.primary,
                  onPressed: _showCreateBookingModal,
                ),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BookingCard(
              booking: booking,
              onTap: () {
                // TODO: Show booking details
              },
              onCancel: booking.status == BookingStatus.confirmed ||
                        booking.status == BookingStatus.pending
                  ? () => _cancelBooking(booking)
                  : null,
              onConfirm: booking.status == BookingStatus.pending
                  ? () => _confirmBooking(booking)
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getTabIcon(String tabTitle) {
    switch (tabTitle) {
      case 'اليوم':
        return Icons.today;
      case 'القادمة':
        return Icons.upcoming;
      case 'المكتملة':
        return Icons.check_circle;
      case 'الملغاة':
        return Icons.cancel;
      default:
        return Icons.list;
    }
  }

  String _getEmptyMessage(String tabTitle) {
    switch (tabTitle) {
      case 'اليوم':
        return 'لا توجد حجوزات لليوم';
      case 'القادمة':
        return 'لا توجد حجوزات قادمة';
      case 'المكتملة':
        return 'لا توجد حجوزات مكتملة';
      case 'الملغاة':
        return 'لا توجد حجوزات ملغاة';
      default:
        return 'لا توجد حجوزات';
    }
  }

  String _getEmptySubtitle(String tabTitle) {
    switch (tabTitle) {
      case 'اليوم':
        return 'يمكنك إنشاء حجوزات جديدة لليوم';
      case 'القادمة':
        return 'سيتم عرض الحجوزات القادمة هنا';
      case 'المكتملة':
        return 'الحجوزات المكتملة ستظهر هنا';
      case 'الملغاة':
        return 'الحجوزات الملغاة ستظهر هنا';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final theme = Theme.of(context);
    
    final tabTitles = ['اليوم', 'القادمة', 'المكتملة', 'الملغاة'];
    final filteredBookings = _getFilteredBookings(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحجوزات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Stadium Selector
          _buildStadiumSelector(theme),
          
          // Filters
          _buildFilters(theme),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabTitles.map((title) {
                return _buildTabContent(
                  provider: bookingProvider,
                  theme: theme,
                  tabTitle: title,
                  bookings: filteredBookings,
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBookingModal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Need to import AuthProvider
import 'package:ehgezly_app/providers/auth_provider.dart';
