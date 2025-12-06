import 'package:flutter/foundation.dart';
import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/services/stadium_service.dart';

class StadiumProvider with ChangeNotifier {
  final StadiumService _stadiumService = StadiumService();

  List<Stadium> _stadiums = [];
  List<Stadium> _filteredStadiums = [];
  Stadium? _selectedStadium;
  List<StadiumSlot> _selectedSlots = [];
  DateTime _selectedDate = DateTime.now();
  StadiumSlot? _selectedSlot;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};
  int _currentPage = 1;
  bool _hasMore = true;
  String _searchQuery = '';

  List<Stadium> get stadiums => _stadiums;
  List<Stadium> get filteredStadiums => _filteredStadiums;
  Stadium? get selectedStadium => _selectedStadium;
  List<StadiumSlot> get selectedSlots => _selectedSlots;
  DateTime get selectedDate => _selectedDate;
  StadiumSlot? get selectedSlot => _selectedSlot;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;

  Future<void> loadStadiums({
    bool refresh = false,
    Map<String, dynamic>? newFilters,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _stadiums.clear();
        _filteredStadiums.clear();
      }

      if (!_hasMore && !refresh) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      if (newFilters != null) {
        _filters = Map<String, dynamic>.from(newFilters);
      }

      final stadiums = await _stadiumService.getStadiums(
        type: _filters['type'] as String?,
        city: _filters['city'] as String?,
        minPrice: _filters['minPrice'] as double?,
        maxPrice: _filters['maxPrice'] as double?,
        features: _filters['features'] as List<String>?,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
        sortBy: _filters['sortBy'] as String?,
        order: _filters['order'] as String? ?? 'desc',
      );

      if (refresh) {
        _stadiums = stadiums;
        _filteredStadiums = stadiums;
      } else {
        _stadiums.addAll(stadiums);
        _filteredStadiums.addAll(stadiums);
      }

      _hasMore = stadiums.length >= 12; // Assuming 12 per page
      if (stadiums.isNotEmpty) {
        _currentPage++;
      }

      _applyFilters();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading stadiums: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshStadiums() async {
    await loadStadiums(refresh: true);
  }

  Future<Stadium> loadStadiumById(String stadiumId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stadium = await _stadiumService.getStadiumById(stadiumId);
      _selectedStadium = stadium;
      await _loadStadiumSlots(stadiumId);

      return stadium;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStadiumSlots(String stadiumId) async {
    try {
      final slots = await _stadiumService.getAvailableSlots(
        stadiumId: stadiumId,
        date: _selectedDate,
      );
      _selectedSlots = slots;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading stadium slots: $e');
      }
      _selectedSlots = [];
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    if (_selectedStadium != null) {
      _loadStadiumSlots(_selectedStadium!.id);
    }
    notifyListeners();
  }

  void setSelectedSlot(StadiumSlot? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void setFilters(Map<String, dynamic> filters) {
    _filters = Map<String, dynamic>.from(filters);
    _currentPage = 1;
    _hasMore = true;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filters.clear();
    _currentPage = 1;
    _hasMore = true;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    if (_filters.isEmpty) {
      _filteredStadiums = List<Stadium>.from(_stadiums);
      return;
    }

    _filteredStadiums = _stadiums.where((stadium) {
      // Type filter
      if (_filters.containsKey('type') &&
          _filters['type'] != null &&
          stadium.type != _filters['type']) {
        return false;
      }

      // City filter
      if (_filters.containsKey('city') &&
          _filters['city'] != null &&
          !stadium.address.contains(_filters['city'] as String)) {
        return false;
      }

      // Price filter
      if (_filters.containsKey('minPrice') &&
          _filters['minPrice'] != null &&
          stadium.pricePerHour < (_filters['minPrice'] as double)) {
        return false;
      }
      if (_filters.containsKey('maxPrice') &&
          _filters['maxPrice'] != null &&
          stadium.pricePerHour > (_filters['maxPrice'] as double)) {
        return false;
      }

      // Features filter
      if (_filters.containsKey('features') &&
          _filters['features'] != null) {
        final requiredFeatures = _filters['features'] as List<String>;
        if (requiredFeatures.isNotEmpty) {
          for (final feature in requiredFeatures) {
            if (!stadium.features.contains(feature)) {
              return false;
            }
          }
        }
      }

      return true;
    }).toList();
  }

  Future<void> searchStadiums(String query) async {
    try {
      _searchQuery = query;
      _currentPage = 1;
      _hasMore = true;
      _stadiums.clear();
      _filteredStadiums.clear();

      await loadStadiums(refresh: true);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _currentPage = 1;
    _hasMore = true;
    _stadiums.clear();
    _filteredStadiums.clear();
    _filteredStadiums = List<Stadium>.from(_stadiums);
    notifyListeners();
  }

  Future<List<Stadium>> getNearbyStadiums({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final nearbyStadiums = await _stadiumService.getNearbyStadiums(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: _filters['type'] as String?,
      );

      return nearbyStadiums;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<String>> getAvailableFeatures() async {
    try {
      return await _stadiumService.getAvailableFeatures();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<List<String>> getAvailableCities() async {
    try {
      return await _stadiumService.getAvailableCities();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStadium = null;
    _selectedSlot = null;
    _selectedSlots.clear();
    notifyListeners();
  }
}
