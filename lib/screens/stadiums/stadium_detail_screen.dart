import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/providers/booking_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/stadiums/stadium_card.dart';
import 'package:ehgezly_app/widgets/stadiums/slot_picker.dart';
import 'package:ehgezly_app/widgets/stadiums/slot_availability_indicator.dart';
import 'package:ehgezly_app/widgets/bookings/booking_modal.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StadiumDetailScreen extends StatefulWidget {
  static const routeName = '/stadiums/:id';
  
  const StadiumDetailScreen({super.key});

  @override
  State<StadiumDetailScreen> createState() => _StadiumDetailScreenState();
}

class _StadiumDetailScreenState extends State<StadiumDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Stadium? _stadium;
  DateTime? _selectedDate;
  StadiumSlot? _selectedSlot;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['stadium'] != null) {
        setState(() {
          _stadium = args['stadium'] as Stadium;
        });
        
        // Load stadium slots
        final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
        stadiumProvider.loadStadiumSlots(_stadium!.id);
      }
    });
  }

  void _handleSlotSelected(DateTime? date, StadiumSlot? slot) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = slot;
    });
  }

  void _openBookingModal() {
    if (_selectedDate == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ وموعد للحجز'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BookingModal(
          stadium: _stadium!,
          slot: _selectedSlot!,
          date: _selectedDate!,
          onBookingSuccess: () {
            // Refresh slots after booking
            final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
            stadiumProvider.loadStadiumSlots(_stadium!.id);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_stadium == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الملعب')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final stadiumProvider = Provider.of<StadiumProvider>(context);

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // App Bar with Image
              SliverAppBar(
                expandedHeight: 300,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    _stadium!.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: _buildStadiumImage(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      _shareStadium();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.directions),
                    onPressed: () {
                      _openDirections();
                    },
                  ),
                ],
              ),

              // Tab Bar
              SliverPersistentHeader(
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'معلومات'),
                      Tab(text: 'مواعيد'),
                      Tab(text: 'مراجعات'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(theme),
              _buildSlotsTab(stadiumProvider, theme),
              _buildReviewsTab(theme),
            ],
          ),
        ),
      ),

      // Floating Action Button for Booking
      floatingActionButton: _selectedSlot != null
          ? FloatingActionButton.extended(
              onPressed: _openBookingModal,
              icon: const Icon(Icons.calendar_today),
              label: const Text('احجز الآن'),
            )
          : null,
    );
  }

  Widget _buildStadiumImage() {
    return Stack(
      children: [
        if (_stadium!.images.isNotEmpty)
          Image.network(
            _stadium!.images.first,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
          )
        else
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.sports_soccer,
                size: 100,
                color: Colors.grey,
              ),
            ),
          ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          Text(
            'معلومات الملعب',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                _stadium!.type == 'football' 
                    ? Icons.sports_soccer 
                    : Icons.sports_tennis,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _stadium!.type == 'football' ? 'ملعب كورة' : 'ملعب بادل',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Icon(
                Icons.location_on,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _stadium!.address.split(',').first,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Description
          if (_stadium!.description.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوصف',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stadium!.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                const Divider(),
              ],
            ),

          // Features
          Text(
            'المميزات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _stadium!.features.map((feature) {
              return Chip(
                label: Text(feature),
                backgroundColor: theme.primaryColor.withOpacity(0.1),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Pricing
          Text(
            'التسعير',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سعر الساعة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      Helpers.formatCurrency(_stadium!.pricePerHour),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نسبة العربون',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${_stadium!.depositPercentage}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Location
          Text(
            'الموقع',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stadium!.address,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'افتح في خرائط جوجل',
                  type: ButtonType.outline,
                  icon: Icons.map,
                  onPressed: _openDirections,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSlotsTab(StadiumProvider provider, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر موعد الحجز',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر اليوم والموعد المناسب لك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 20),

          // Slot Availability Indicator
          if (_selectedDate != null)
            SlotAvailabilityIndicator(
              stadium: _stadium!,
              date: _selectedDate!,
              size: 150,
            ),

          const SizedBox(height: 20),

          // Slot Picker
          SlotPicker(
            stadium: _stadium!,
            initialDate: _selectedDate,
            initialSlot: _selectedSlot,
            onSlotSelected: _handleSlotSelected,
          ),

          // Selected Slot Info
          if (_selectedDate != null && _selectedSlot != null) ...[
            const SizedBox(height: 30),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الموعد المختار',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Helpers.formatDate(_selectedDate!),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        Helpers.formatCurrency(_selectedSlot!.price),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'عربون: ${Helpers.formatCurrency(_selectedSlot!.price * (_stadium!.depositPercentage / 100))}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'تابع للحجز',
                    type: ButtonType.primary,
                    onPressed: _openBookingModal,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ThemeData theme) {
    // TODO: Implement reviews from API
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_outline,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مراجعات بعد',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'كن أول من يقيّم هذا الملعب',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'أضف مراجعة',
              type: ButtonType.outline,
              onPressed: () {
                // TODO: Implement add review
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareStadium() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة مشاركة الملعب قريباً'),
      ),
    );
  }

  void _openDirections() {
    if (_stadium!.latitude != null && _stadium!.longitude != null) {
      Helpers.launchMaps(
        _stadium!.latitude!,
        _stadium!.longitude!,
        _stadium!.name,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يتوفر موقع جغرافي لهذا الملعب'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Custom delegate for tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
