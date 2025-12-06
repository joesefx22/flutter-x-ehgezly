import 'package:flutter/foundation.dart';
import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<Booking> _bookings = [];
  List<Booking> _todayBookings = [];
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];
  List<Booking> _cancelledBookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _filters = {};

  List<Booking> get bookings => _bookings;
  List<Booking> get todayBookings => _todayBookings;
  List<Booking> get upcomingBookings => _upcomingBookings;
  List<Booking> get pastBookings => _pastBookings;
  List<Booking> get cancelledBookings => _cancelledBookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get filters => _filters;

  Future<void> loadUserBookings({
    bool refresh = false,
    Map<String, dynamic>? newFilters,
  }) async {
    try {
      if (refresh) {
        _bookings.clear();
        _todayBookings.clear();
        _upcomingBookings.clear();
        _pastBookings.clear();
        _cancelledBookings.clear();
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      if (newFilters != null) {
        _filters = Map<String, dynamic>.from(newFilters);
      }

      final bookings = await _bookingService.getUserBookings(
        status: _filters['status'] as String?,
        fromDate: _filters['fromDate'] as DateTime?,
        toDate: _filters['toDate'] as DateTime?,
      );

      _bookings = bookings;
      _categorizeBookings();

      if (refresh) {
        await _loadAdditionalData();
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading bookings: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAdditionalData() async {
    try {
      // Load today's bookings
      final today = await _bookingService.getTodayBookings();
      _todayBookings = today;

      // Load upcoming bookings
      final upcoming = await _bookingService.getUpcomingBookings();
      _upcomingBookings = upcoming;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading additional booking data: $e');
      }
    }
  }

  void _categorizeBookings() {
    final now = DateTime.now();
    
    _todayBookings = _bookings.where((booking) {
      return Helpers.isSameDay(booking.date, now) && booking.isConfirmed;
    }).toList();

    _upcomingBookings = _bookings.where((booking) {
      return booking.date.isAfter(now) && booking.isConfirmed;
    }).toList();

    _pastBookings = _bookings.where((booking) {
      return booking.date.isBefore(now) && 
             (booking.isConfirmed || booking.isCompleted);
    }).toList();

    _cancelledBookings = _bookings.where((booking) {
      return booking.isCancelled;
    }).toList();
  }

  Future<void> refreshBookings() async {
    await loadUserBookings(refresh: true);
  }

  Future<Booking> loadBookingById(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final booking = await _bookingService.getBookingById(bookingId);
      _selectedBooking = booking;

      return booking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> createBooking({
    required String stadiumId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int playersCount,
    String? notes,
    String? voucherCode,
    bool payDeposit = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check slot availability first
      final isAvailable = await _bookingService.checkSlotAvailability(
        stadiumId: stadiumId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      if (!isAvailable) {
        throw Exception('هذا الموعد لم يعد متاحاً');
      }

      final booking = await _bookingService.createBooking(
        stadiumId: stadiumId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        playersCount: playersCount,
        notes: notes,
        voucherCode: voucherCode,
        payDeposit: payDeposit,
      );

      // Add to local list and refresh
      _bookings.insert(0, booking);
      _categorizeBookings();

      return booking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> updateBooking({
    required String bookingId,
    String? notes,
    int? playersCount,
    String? status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedBooking = await _bookingService.updateBooking(
        bookingId: bookingId,
        notes: notes,
        playersCount: playersCount,
        status: status,
      );

      // Update in local list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updatedBooking;
      }
      
      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = updatedBooking;
      }

      _categorizeBookings();

      return updatedBooking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final cancelledBooking = await _bookingService.cancelBooking(
        bookingId: bookingId,
        reason: reason,
      );

      // Update in local list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = cancelledBooking;
      }
      
      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = cancelledBooking;
      }

      _categorizeBookings();

      return cancelledBooking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> confirmBooking(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final confirmedBooking = await _bookingService.confirmBooking(bookingId);

      // Update in local list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = confirmedBooking;
      }
      
      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = confirmedBooking;
      }

      _categorizeBookings();

      return confirmedBooking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking> completeBooking(String bookingId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final completedBooking = await _bookingService.completeBooking(bookingId);

      // Update in local list
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = completedBooking;
      }
      
      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = completedBooking;
      }

      _categorizeBookings();

      return completedBooking;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Booking>> getStadiumBookings({
    required String stadiumId,
    String? status,
    DateTime? date,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final bookings = await _bookingService.getStadiumBookings(
        stadiumId: stadiumId,
        status: status,
        date: date,
      );

      return bookings;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getBookingStats({
    String? stadiumId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final stats = await _bookingService.getBookingStats(
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

  Future<bool> checkSlotAvailability({
    required String stadiumId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    try {
      return await _bookingService.checkSlotAvailability(
        stadiumId: stadiumId,
        date: date,
        startTime: startTime,
        endTime: endTime,
        excludeBookingId: excludeBookingId,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
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

  void setSelectedBooking(Booking? booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBooking = null;
    notifyListeners();
  }

  List<Booking> getBookingsByStatus(String status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  List<Booking> getBookingsByDateRange(DateTime fromDate, DateTime toDate) {
    return _bookings.where((booking) {
      return booking.date.isAfter(fromDate) && booking.date.isBefore(toDate);
    }).toList();
  }

  int get totalBookingsCount => _bookings.length;
  int get confirmedBookingsCount => _bookings.where((b) => b.isConfirmed).length;
  int get pendingBookingsCount => _bookings.where((b) => b.isPending).length;
  int get cancelledBookingsCount => _bookings.where((b) => b.isCancelled).length;

  double get totalRevenue {
    return _bookings.fold(0.0, (sum, booking) {
      if (booking.isConfirmed || booking.isCompleted) {
        return sum + booking.totalAmount;
      }
      return sum;
    });
  }

  double get pendingRevenue {
    return _bookings.fold(0.0, (sum, booking) {
      if (booking.isPending) {
        return sum + booking.totalAmount;
      }
      return sum;
    });
  }
}
