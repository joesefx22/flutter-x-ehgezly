import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/models/play_request.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/player/request_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/modal.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StaffPlayersRequestsScreen extends StatefulWidget {
  static const routeName = '/staff/players-requests';
  
  const StaffPlayersRequestsScreen({super.key});

  @override
  State<StaffPlayersRequestsScreen> createState() => _StaffPlayersRequestsScreenState();
}

class _StaffPlayersRequestsScreenState extends State<StaffPlayersRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Stadium> _assignedStadiums = [];
  String? _selectedStadiumId;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
      await stadiumProvider.loadStadiums();
      
      // Get assigned stadiums from user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null && user.stadiums.isNotEmpty) {
        _assignedStadiums = stadiumProvider.stadiums
            .where((stadium) => user.stadiums.contains(stadium.id))
            .toList();
        
        if (_assignedStadiums.isNotEmpty) {
          _selectedStadiumId = _assignedStadiums.first.id;
        }
      }
      
      if (_selectedStadiumId != null) {
        await _loadPlayRequests();
      }
      
      setState(() => _isLoading = false);
    });
  }

  Future<void> _loadPlayRequests() async {
    if (_selectedStadiumId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      await playRequestProvider.loadStadiumRequests(_selectedStadiumId!);
    } catch (e) {
      print('Error loading play requests: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<PlayRequest> _getFilteredRequests(PlayRequestProvider provider) {
    if (_selectedStadiumId == null) return [];
    
    var requests = provider.playRequests
        .where((request) => request.stadiumId == _selectedStadiumId)
        .toList();
    
    // Filter by tab
    final tabIndex = _tabController.index;
    switch (tabIndex) {
      case 0: // النشطة
        requests = requests
            .where((request) => 
                request.status == PlayRequestStatus.open ||
                request.status == PlayRequestStatus.partial)
            .toList();
        break;
      case 1: // المكتملة
        requests = requests
            .where((request) => request.status == PlayRequestStatus.closed)
            .toList();
        break;
      case 2: // الملغاة
        requests = requests
            .where((request) => request.status == PlayRequestStatus.cancelled)
            .toList();
        break;
    }
    
    // Filter by search
    if (_searchQuery.isNotEmpty) {
      requests = requests
          .where((request) => 
              request.creatorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (request.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    // Sort by date
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return requests;
  }

  Future<void> _updateRequestStatus(PlayRequest request, PlayRequestStatus newStatus) async {
    String? reason;
    
    if (newStatus == PlayRequestStatus.cancelled) {
      final result = await showModal(
        context: context,
        title: 'إلغاء الطلب',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سبب الإلغاء (اختياري):'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'مثلاً: مخالف لشروط الملعب',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                reason = value;
              },
            ),
          ],
        ),
        actions: [
          AppButton(
            text: 'إلغاء',
            type: ButtonType.outline,
            onPressed: () => Navigator.pop(context),
          ),
          AppButton(
            text: 'تأكيد الإلغاء',
            type: ButtonType.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      );
      
      if (result != true) return;
    }
    
    try {
      final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
      await playRequestProvider.updatePlayRequestStatus(
        request.id,
        newStatus,
        staffReason: reason,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getStatusUpdateMessage(newStatus)),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadPlayRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحديث حالة الطلب: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusUpdateMessage(PlayRequestStatus status) {
    switch (status) {
      case PlayRequestStatus.closed:
        return 'تم إغلاق الطلب بنجاح';
      case PlayRequestStatus.cancelled:
        return 'تم إلغاء الطلب بنجاح';
      default:
        return 'تم تحديث حالة الطلب';
    }
  }

  void _showRequestDetails(PlayRequest request) {
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
                    'تفاصيل الطلب',
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
              
              // Request Details
              _buildDetailRow('منشئ الطلب:', request.creatorName),
              _buildDetailRow('الحالة:', PlayRequest.getStatusLabel(request.status)),
              
              if (request.stadiumName != null)
                _buildDetailRow('الملعب:', request.stadiumName!),
              
              if (request.dateTime != null)
                _buildDetailRow('التاريخ:', Helpers.formatDateTime(request.dateTime!)),
              
              _buildDetailRow('عدد المطلوبين:', request.requiredPlayers.toString()),
              _buildDetailRow('المنضمين:', '${request.joiners.length}/${request.requiredPlayers}'),
              _buildDetailRow('الفئة العمرية:', PlayRequest.getAgeGroupLabel(request.ageGroup)),
              _buildDetailRow('المستوى:', PlayRequest.getLevelLabel(request.level)),
              
              if (request.notes != null && request.notes!.isNotEmpty)
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
                    Text(request.notes!),
                  ],
                ),
              
              // Joiners List
              if (request.joiners.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'المنضمين:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...request.joiners.map((joiner) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('• ${joiner.userName}'),
                      );
                    }),
                  ],
                ),
              
              const SizedBox(height: 20),
              
              // Actions
              if (request.status == PlayRequestStatus.open || 
                  request.status == PlayRequestStatus.partial)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'إغلاق الطلب',
                        type: ButtonType.primary,
                        icon: Icons.check,
                        onPressed: () {
                          Navigator.pop(context);
                          _updateRequestStatus(request, PlayRequestStatus.closed);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'إلغاء الطلب',
                        type: ButtonType.danger,
                        icon: Icons.cancel,
                        onPressed: () {
                          Navigator.pop(context);
                          _updateRequestStatus(request, PlayRequestStatus.cancelled);
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
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
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
          _loadPlayRequests();
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'ابحث باسم المنشئ أو الملاحظات',
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
    );
  }

  Widget _buildTabContent(
    PlayRequestProvider provider,
    ThemeData theme,
    String tabTitle,
    List<PlayRequest> requests,
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
              Icons.group,
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
              'يجب اختيار ملعب لعرض طلباته',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    if (requests.isEmpty) {
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
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadPlayRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RequestCard(
              playRequest: request,
              onTap: () => _showRequestDetails(request),
              showStaffActions: true,
              onClose: request.status == PlayRequestStatus.open ||
                      request.status == PlayRequestStatus.partial
                  ? () => _updateRequestStatus(request, PlayRequestStatus.closed)
                  : null,
              onCancel: request.status == PlayRequestStatus.open ||
                       request.status == PlayRequestStatus.partial
                  ? () => _updateRequestStatus(request, PlayRequestStatus.cancelled)
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getTabIcon(String tabTitle) {
    switch (tabTitle) {
      case 'النشطة':
        return Icons.group;
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
      case 'النشطة':
        return 'لا توجد طلبات نشطة';
      case 'المكتملة':
        return 'لا توجد طلبات مكتملة';
      case 'الملغاة':
        return 'لا توجد طلبات ملغاة';
      default:
        return 'لا توجد طلبات';
    }
  }

  String _getEmptySubtitle(String tabTitle) {
    switch (tabTitle) {
      case 'النشطة':
        return 'الطلبات النشطة ستظهر هنا';
      case 'المكتملة':
        return 'الطلبات المكتملة ستظهر هنا';
      case 'الملغاة':
        return 'الطلبات الملغاة ستظهر هنا';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context);
    final theme = Theme.of(context);
    
    final tabTitles = ['النشطة', 'المكتملة', 'الملغاة'];
    final filteredRequests = _getFilteredRequests(playRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات اللاعبين'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabTitles.map((title) => Tab(text: title)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Stadium Selector
          _buildStadiumSelector(theme),
          
          // Search Bar
          _buildSearchBar(theme),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabTitles.map((title) {
                return _buildTabContent(
                  provider: playRequestProvider,
                  theme: theme,
                  tabTitle: title,
                  requests: filteredRequests,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Need to import AuthProvider
import 'package:ehgezly_app/providers/auth_provider.dart';
