import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ehgezly_app/providers/stadium_provider.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/widgets/stadiums/stadium_card.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/widgets/common/input_field.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StadiumsListScreen extends StatefulWidget {
  static const routeName = '/stadiums';
  
  const StadiumsListScreen({super.key});

  @override
  State<StadiumsListScreen> createState() => _StadiumsListScreenState();
}

class _StadiumsListScreenState extends State<StadiumsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showFilters = false;
  String? _selectedCity;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedType;
  List<String> _selectedFeatures = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['type'] != null) {
        _selectedType = args['type'];
      }
      
      final provider = Provider.of<StadiumProvider>(context, listen: false);
      provider.loadStadiums(
        type: _selectedType,
        city: _selectedCity,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        features: _selectedFeatures,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final provider = Provider.of<StadiumProvider>(context, listen: false);
      if (provider.hasMore && !provider.isLoading) {
        provider.loadMoreStadiums();
      }
    }
  }

  void _applyFilters() {
    final provider = Provider.of<StadiumProvider>(context, listen: false);
    provider.loadStadiums(
      type: _selectedType,
      city: _selectedCity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      features: _selectedFeatures,
      query: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
    );
    setState(() {
      _showFilters = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCity = null;
      _selectedType = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedFeatures.clear();
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final stadiumProvider = Provider.of<StadiumProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملاعب'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: InputField(
              controller: _searchController,
              hintText: 'ابحث عن ملاعب...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                if (value.isEmpty) {
                  _applyFilters();
                }
              },
              onSubmitted: (value) {
                _applyFilters();
              },
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
            ),
          ),

          // Filters Panel
          if (_showFilters) _buildFiltersPanel(theme),

          // Results Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stadiumProvider.stadiums.length} ملعب',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_hasActiveFilters)
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      'إعادة تعيين',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stadiums Grid
          Expanded(
            child: _buildStadiumsList(stadiumProvider, theme),
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedCity != null ||
        _selectedType != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _selectedFeatures.isNotEmpty ||
        _searchController.text.isNotEmpty;
  }

  Widget _buildFiltersPanel(ThemeData theme) {
    final cities = ['القاهرة', 'الجيزة', 'الإسكندرية', 'المنصورة', 'طنطا'];
    final features = ['إضاءة', 'خلع', 'مقهى', 'باركينج', 'تدفئة', 'تكييف'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الفلاتر',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Type Filter
            Text('نوع الرياضة', style: theme.textTheme.bodyMedium),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('كرة قدم', 'football', theme),
                _buildFilterChip('بادل', 'paddle', theme),
                _buildFilterChip('كليهما', null, theme),
              ],
            ),
            const SizedBox(height: 16),

            // City Filter
            Text('المدينة', style: theme.textTheme.bodyMedium),
            Wrap(
              spacing: 8,
              children: cities.map((city) {
                return _buildFilterChip(city, city, theme);
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Price Range
            Text('نطاق السعر', style: theme.textTheme.bodyMedium),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    label: 'من',
                    hintText: '50',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minPrice = value.isNotEmpty ? double.tryParse(value) : null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InputField(
                    label: 'إلى',
                    hintText: '500',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxPrice = value.isNotEmpty ? double.tryParse(value) : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Features Filter
            Text('المميزات', style: theme.textTheme.bodyMedium),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) {
                return FilterChip(
                  label: Text(feature),
                  selected: _selectedFeatures.contains(feature),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFeatures.add(feature);
                      } else {
                        _selectedFeatures.remove(feature);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Apply & Reset Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'تطبيق الفلاتر',
                    type: ButtonType.primary,
                    onPressed: _applyFilters,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'إعادة تعيين',
                    type: ButtonType.outline,
                    onPressed: _resetFilters,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, ThemeData theme) {
    final isSelected = (value == null && _selectedType == null) ||
        (value == 'football' && _selectedType == 'football') ||
        (value == 'paddle' && _selectedType == 'paddle') ||
        (value == _selectedCity);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'كليهما') {
            _selectedType = null;
          } else if (['كرة قدم', 'بادل'].contains(label)) {
            _selectedType = value;
          } else {
            _selectedCity = selected ? value : null;
          }
        });
      },
    );
  }

  Widget _buildStadiumsList(StadiumProvider provider, ThemeData theme) {
    if (provider.isLoading && provider.stadiums.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.stadiums.isEmpty) {
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
              'لا توجد ملاعب',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'حاول تغيير الفلاتر أو البحث بمصطلحات أخرى',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'إعادة تعيين الفلاتر',
              type: ButtonType.outline,
              onPressed: _resetFilters,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadStadiums(
          type: _selectedType,
          city: _selectedCity,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          features: _selectedFeatures,
          query: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
        );
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: provider.stadiums.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.stadiums.length) {
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox();
          }

          final stadium = provider.stadiums[index];
          return StadiumCard(
            stadium: stadium,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/stadiums/${stadium.id}',
                arguments: {'stadium': stadium},
              );
            },
          );
        },
      ),
    );
  }
}
