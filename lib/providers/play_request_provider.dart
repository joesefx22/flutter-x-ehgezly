import 'package:flutter/foundation.dart';
import 'package:ehgezly_app/models/play_request.dart';
import 'package:ehgezly_app/services/play_request_service.dart';

class PlayRequestProvider with ChangeNotifier {
  final PlayRequestService _playRequestService = PlayRequestService();

  List<PlayRequest> _playRequests = [];
  List<PlayRequest> _myPlayRequests = [];
  List<PlayRequest> _joinedRequests = [];
  List<PlayRequest> _availableRequests = [];
  PlayRequest? _selectedRequest;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};

  List<PlayRequest> get playRequests => _playRequests;
  List<PlayRequest> get myPlayRequests => _myPlayRequests;
  List<PlayRequest> get joinedRequests => _joinedRequests;
  List<PlayRequest> get availableRequests => _availableRequests;
  PlayRequest? get selectedRequest => _selectedRequest;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;

  Future<void> loadPlayRequests({
    bool refresh = false,
    Map<String, dynamic>? newFilters,
  }) async {
    try {
      if (refresh) {
        _playRequests.clear();
        _availableRequests.clear();
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      if (newFilters != null) {
        _filters = Map<String, dynamic>.from(newFilters);
      }

      final requests = await _playRequestService.getPlayRequests(
        stadiumId: _filters['stadiumId'] as String?,
        date: _filters['date'] as DateTime?,
        ageGroup: _filters['ageGroup'] as String?,
        level: _filters['level'] as String?,
        status: _filters['status'] as String?,
      );

      _playRequests = requests;
      _filterAvailableRequests();
      
      if (refresh) {
        await _loadMyRequests();
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading play requests: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMyRequests() async {
    try {
      final myRequests = await _playRequestService.getMyPlayRequests(
        status: _filters['status'] as String?,
      );
      _myPlayRequests = myRequests;
      _filterJoinedRequests();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading my play requests: $e');
      }
    }
  }

  void _filterAvailableRequests() {
    _availableRequests = _playRequests.where((request) {
      return request.isOpen && request.hasAvailableSpots;
    }).toList();
  }

  void _filterJoinedRequests() {
    _joinedRequests = _playRequests.where((request) {
      return request.joiners.any((joiner) => 
          joiner.userId == _getCurrentUserId()); // Assuming you have user ID
    }).toList();
  }

  String? _getCurrentUserId() {
    // You'll need to get this from AuthProvider
    return null;
  }

  Future<void> refreshPlayRequests() async {
    await loadPlayRequests(refresh: true);
  }

  Future<PlayRequest> loadPlayRequestById(String requestId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = await _playRequestService.getPlayRequestById(requestId);
      _selectedRequest = request;

      return request;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlayRequest> createPlayRequest({
    required String stadiumId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int requiredPlayers,
    required String ageGroup,
    required String level,
    String? notes,
    String? bookingId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final request = await _playRequestService.createPlayRequest(
        stadiumId: stadiumId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        requiredPlayers: requiredPlayers,
        ageGroup: ageGroup,
        level: level,
        notes: notes,
        bookingId: bookingId,
      );

      // Add to local lists
      _playRequests.insert(0, request);
      _myPlayRequests.insert(0, request);
      _filterAvailableRequests();

      return request;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlayRequest> joinPlayRequest({
    required String requestId,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedRequest = await _playRequestService.joinPlayRequest(
        requestId: requestId,
        notes: notes,
      );

      // Update in local lists
      final index = _playRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _playRequests[index] = updatedRequest;
      }
      
      if (_selectedRequest?.id == requestId) {
        _selectedRequest = updatedRequest;
      }

      _filterAvailableRequests();
      _joinedRequests.add(updatedRequest);

      return updatedRequest;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlayRequest> leavePlayRequest(String requestId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedRequest = await _playRequestService.leavePlayRequest(requestId);

      // Update in local lists
      final index = _playRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _playRequests[index] = updatedRequest;
      }
      
      if (_selectedRequest?.id == requestId) {
        _selectedRequest = updatedRequest;
      }

      _filterAvailableRequests();
      _joinedRequests.removeWhere((r) => r.id == requestId);

      return updatedRequest;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlayRequest> updatePlayRequest({
    required String requestId,
    int? requiredPlayers,
    String? ageGroup,
    String? level,
    String? status,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedRequest = await _playRequestService.updatePlayRequest(
        requestId: requestId,
        requiredPlayers: requiredPlayers,
        ageGroup: ageGroup,
        level: level,
        status: status,
        notes: notes,
      );

      // Update in local lists
      final index = _playRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _playRequests[index] = updatedRequest;
      }
      
      final myIndex = _myPlayRequests.indexWhere((r) => r.id == requestId);
      if (myIndex != -1) {
        _myPlayRequests[myIndex] = updatedRequest;
      }
      
      if (_selectedRequest?.id == requestId) {
        _selectedRequest = updatedRequest;
      }

      _filterAvailableRequests();

      return updatedRequest;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> closePlayRequest(String requestId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _playRequestService.closePlayRequest(requestId);

      // Update local request
      final index = _playRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _playRequests[index] = _playRequests[index].copyWith(status: 'closed');
      }

      _filterAvailableRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelPlayRequest({
    required String requestId,
    required String reason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _playRequestService.cancelPlayRequest(
        requestId: requestId,
        reason: reason,
      );

      // Update local request
      final index = _playRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _playRequests[index] = _playRequests[index].copyWith(status: 'cancelled');
      }

      _filterAvailableRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlayRequest>> getStadiumPlayRequests({
    required String stadiumId,
    String? status,
    DateTime? date,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final requests = await _playRequestService.getStadiumPlayRequests(
        stadiumId: stadiumId,
        status: status,
        date: date,
      );

      return requests;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getPlayRequestStats({
    String? stadiumId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stats = await _playRequestService.getPlayRequestStats(
        stadiumId: stadiumId,
        fromDate: fromDate,
        toDate: toDate,
      );

      return stats;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PlayRequest>> searchPlayRequests({
    required String query,
    String? stadiumId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final requests = await _playRequestService.searchPlayRequests(
        query: query,
        stadiumId: stadiumId,
      );

      return requests;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilters(Map<String, dynamic> filters) {
    _filters = Map<String, dynamic>.from(filters);
    notifyListeners();
  }

  void clearFilters() {
    _filters.clear();
    notifyListeners();
  }

  void setSelectedRequest(PlayRequest? request) {
    _selectedRequest = request;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRequest = null;
    notifyListeners();
  }

  bool hasUserJoined(String requestId) {
    final request = _playRequests.firstWhere(
      (r) => r.id == requestId,
      orElse: () => PlayRequest.empty,
    );
    
    if (request == PlayRequest.empty) return false;
    
    return request.joiners.any((joiner) => 
        joiner.userId == _getCurrentUserId());
  }

  List<PlayRequest> getRequestsByStatus(String status) {
    return _playRequests.where((request) => request.status == status).toList();
  }

  List<PlayRequest> getRequestsByStadium(String stadiumId) {
    return _playRequests.where((request) => request.stadiumId == stadiumId).toList();
  }

  int get totalRequestsCount => _playRequests.length;
  int get openRequestsCount => _playRequests.where((r) => r.isOpen).length;
  int get closedRequestsCount => _playRequests.where((r) => r.isClosed).length;
  int get availableRequestsCount => _availableRequests.length;
}
