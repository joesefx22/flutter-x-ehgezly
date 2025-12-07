import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/play_request_provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/widgets/player/request_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/app_card.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class PlaySearchScreen extends StatefulWidget {
  static const routeName = '/play-search';
  
  const PlaySearchScreen({super.key});
  
  @override
  State<PlaySearchScreen> createState() => _PlaySearchScreenState();
}

class _PlaySearchScreenState extends State<PlaySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _selectedAgeGroup = 'الكل';
  String _selectedLevel = 'الكل';
  String _selectedStadium = 'الكل';
  String _selectedStatus = 'open';
  Timer? _searchDebounceTimer;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  
  Future<void> _loadInitialData() async {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
    final stadiumProvider = Provider.of<StadiumProvider>(context, listen: false);
    
    await Future.wait([
      playRequestProvider.loadPlayRequests(),
      stadiumProvider.loadStadiums(),
    ]);
  }
  
  void _onSearchChanged(String value) {
    if (_searchDebounceTimer?.isActive ?? false) {
      _searchDebounceTimer?.cancel();
    }
    
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }
  
  void _applyFilters() {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context, listen: false);
    
    final filters = {
      'search': _searchController.text.trim(),
      'ageGroup': _selectedAgeGroup != 'الكل' ? _selectedAgeGroup : null,
      'level': _selectedLevel != 'الكل' ? _selectedLevel : null,
      'stadiumId': _selectedStadium != 'الكل' ? _selectedStadium : null,
      'status': _selectedStatus,
    };
    
    playRequestProvider.filterPlayRequests(filters);
  }
  
  void _clearFilters() {
    _searchController.clear();
    _selectedAgeGroup = 'الكل';
    _selectedLevel = 'الكل';
    _selectedStadium = 'الكل';
    _selectedStatus = 'open';
    
    setState(() {
      _showFilters = false;
    });
    
    _applyFilters();
  }
  
  Widget _buildSearchBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث عن طلبات لاعبين...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildFiltersSection() {
    if (!_showFilters) return Container();
    
    final stadiumProvider = Provider.of<StadiumProvider>(context);
    
    return AppCard(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التصفية', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          
          // Age Group Filter
          _buildFilterSection(
            title: 'الفئة العمرية',
            options: ['الكل', 'تحت 18', '18-25', '26-35', 'فوق 35'],
            selected: _selectedAgeGroup,
            onChanged: (value) {
              setState(() => _selectedAgeGroup = value);
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 12),
          
          // Level Filter
          _buildFilterSection(
            title: 'مستوى اللعب',
            options: ['الكل', 'مبتدئ', 'متوسط', 'محترف'],
            selected: _selectedLevel,
            onChanged: (value) {
              setState(() => _selectedLevel = value);
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 12),
          
          // Stadium Filter
          _buildFilterSection(
            title: 'الملعب',
            options: [
              'الكل',
              ...stadiumProvider.stadiums.map((s) => s.name).toList(),
            ],
            selected: _selectedStadium,
            onChanged: (value) {
              setState(() => _selectedStadium = value);
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 12),
          
          // Status Filter
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('نشطة'),
                selected: _selectedStatus == 'open',
                onSelected: (selected) {
                  setState(() => _selectedStatus = selected ? 'open' : '');
                  _applyFilters();
                },
              ),
              FilterChip(
                label: const Text('مكتملة'),
                selected: _selectedStatus == 'closed',
                onSelected: (selected) {
                  setState(() => _selectedStatus = selected ? 'closed' : '');
                  _applyFilters();
                },
              ),
              FilterChip(
                label: const Text('الكل'),
                selected: _selectedStatus == '',
                onSelected: (selected) {
                  setState(() => _selectedStatus = selected ? '' : 'open');
                  _applyFilters();
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: _clearFilters,
                  text: 'إعادة التعيين',
                  type: ButtonType.outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: () {
                    setState(() => _showFilters = false);
                  },
                  text: 'تطبيق',
                  type: ButtonType.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final isSelected = option == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => onChanged(option),
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildResultsCount() {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context);
    final count = playRequestProvider.filteredPlayRequests.length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$count طلب',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          if (_hasActiveFilters())
            TextButton(
              onPressed: _clearFilters,
              child: const Text('إزالة الفلاتر'),
            ),
        ],
      ),
    );
  }
  
  bool _hasActiveFilters() {
    return _searchController.text.isNotEmpty ||
        _selectedAgeGroup != 'الكل' ||
        _selectedLevel != 'الكل' ||
        _selectedStadium != 'الكل' ||
        _selectedStatus != 'open';
  }
  
  Widget _buildRequestsList() {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context);
    final requests = playRequestProvider.filteredPlayRequests;
    
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters()
                  ? 'لا توجد نتائج للبحث'
                  : 'لا توجد طلبات لاعبين متاحة',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_hasActiveFilters())
              AppButton(
                onPressed: _clearFilters,
                text: 'إعادة تعيين البحث',
                type: ButtonType.outline,
              ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = requests[index];
        return RequestCard(
          playRequest: request,
          onTap: () {
            playRequestProvider.selectPlayRequest(request.id);
            Navigator.pushNamed(
              context,
              PlayDetailScreen.routeName,
              arguments: {'playRequestId': request.id},
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final playRequestProvider = Provider.of<PlayRequestProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('لاعبوني معاكم'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await playRequestProvider.loadPlayRequests();
          _applyFilters();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              _buildFiltersSection(),
              _buildResultsCount(),
              _buildRequestsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/player/create-request');
        },
        icon: const Icon(Icons.add),
        label: const Text('طلب جديد'),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}
