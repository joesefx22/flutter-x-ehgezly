import 'package:ehgezly_app/models/booking.dart';
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class BookingService {
  final ApiClient _apiClient = ApiClient();

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
    final response = await _apiClient.post<Booking>(
      AppConstants.bookings,
      body: {
        'stadiumId': stadiumId,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'playersCount': playersCount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (voucherCode != null && voucherCode.isNotEmpty) 'voucherCode': voucherCode,
        'payDeposit': payDeposit,
      },
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Booking>> getUserBookings({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = AppConstants.itemsPerPage,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (fromDate != null) {
      queryParameters['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParameters['toDate'] = toDate.toIso8601String();
    }

    final response = await _apiClient.get<List<Booking>>(
      '${AppConstants.bookings}/my',
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Booking>> getStadiumBookings({
    required String stadiumId,
    String? status,
    DateTime? date,
    int page = 1,
    int limit = AppConstants.itemsPerPage,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (date != null) {
      queryParameters['date'] = date.toIso8601String();
    }

    final response = await _apiClient.get<List<Booking>>(
      '${AppConstants.stadiums}/$stadiumId/bookings',
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Booking> getBookingById(String bookingId) async {
    final response = await _apiClient.get<Booking>(
      '${AppConstants.bookings}/$bookingId',
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Booking> updateBooking({
    required String bookingId,
    String? notes,
    int? playersCount,
    String? status,
  }) async {
    final body = <String, dynamic>{
      'bookingId': bookingId,
    };

    if (notes != null) body['notes'] = notes;
    if (playersCount != null) body['playersCount'] = playersCount;
    if (status != null) body['status'] = status;

    final response = await _apiClient.put<Booking>(
      '${AppConstants.bookings}/$bookingId',
      body: body,
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Booking> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    final response = await _apiClient.post<Booking>(
      '${AppConstants.bookings}/$bookingId/cancel',
      body: {'reason': reason},
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Booking> confirmBooking(String bookingId) async {
    final response = await _apiClient.post<Booking>(
      '${AppConstants.bookings}/$bookingId/confirm',
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Booking> completeBooking(String bookingId) async {
    final response = await _apiClient.post<Booking>(
      '${AppConstants.bookings}/$bookingId/complete',
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<bool> checkSlotAvailability({
    required String stadiumId,
    required DateTime date,
    required String startTime,
    required String endTime,
    String? excludeBookingId,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.bookings}/check-availability',
      queryParameters: {
        'stadiumId': stadiumId,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        if (excludeBookingId != null) 'excludeBookingId': excludeBookingId,
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!['available'] as bool? ?? false;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Booking>> getTodayBookings() async {
    final response = await _apiClient.get<List<Booking>>(
      '${AppConstants.bookings}/today',
      fromJson: (json) => (json as List<dynamic>)
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Booking>> getUpcomingBookings() async {
    final response = await _apiClient.get<List<Booking>>(
      '${AppConstants.bookings}/upcoming',
      fromJson: (json) => (json as List<dynamic>)
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getBookingStats({
    String? stadiumId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParameters = <String, dynamic>{};
    
    if (stadiumId != null) queryParameters['stadiumId'] = stadiumId;
    if (fromDate != null) queryParameters['fromDate'] = fromDate.toIso8601String();
    if (toDate != null) queryParameters['toDate'] = toDate.toIso8601String();

    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.bookings}/stats',
      queryParameters: queryParameters,
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> sendBookingReminder(String bookingId) async {
    final response = await _apiClient.post(
      '${AppConstants.bookings}/$bookingId/reminder',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<Booking> createBookingForUser({
    required String stadiumId,
    required String userId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required int playersCount,
    String? notes,
    bool payDeposit = false,
  }) async {
    final response = await _apiClient.post<Booking>(
      '${AppConstants.bookings}/admin/create',
      body: {
        'stadiumId': stadiumId,
        'userId': userId,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'playersCount': playersCount,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'payDeposit': payDeposit,
      },
      fromJson: (json) => Booking.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }
}
