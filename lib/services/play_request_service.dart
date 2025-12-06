import 'package:ehgezly_app/models/play_request.dart';
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class PlayRequestService {
  final ApiClient _apiClient = ApiClient();

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
    final response = await _apiClient.post<PlayRequest>(
      AppConstants.playRequests,
      body: {
        'stadiumId': stadiumId,
        'date': date.toIso8601String(),
        'startTime': startTime,
        'endTime': endTime,
        'requiredPlayers': requiredPlayers,
        'ageGroup': ageGroup,
        'level': level,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (bookingId != null && bookingId.isNotEmpty) 'bookingId': bookingId,
      },
      fromJson: (json) => PlayRequest.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<PlayRequest>> getPlayRequests({
    String? stadiumId,
    DateTime? date,
    String? ageGroup,
    String? level,
    String? status,
    int page = 1,
    int limit = AppConstants.itemsPerPage,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (stadiumId != null && stadiumId.isNotEmpty) {
      queryParameters['stadiumId'] = stadiumId;
    }
    if (date != null) {
      queryParameters['date'] = date.toIso8601String();
    }
    if (ageGroup != null && ageGroup.isNotEmpty) {
      queryParameters['ageGroup'] = ageGroup;
    }
    if (level != null && level.isNotEmpty) {
      queryParameters['level'] = level;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _apiClient.get<List<PlayRequest>>(
      AppConstants.playRequests,
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((request) => PlayRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<PlayRequest>> getMyPlayRequests({
    String? status,
    bool asCreator = true,
    bool asJoiner = true,
  }) async {
    final response = await _apiClient.get<List<PlayRequest>>(
      '${AppConstants.playRequests}/my',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        'asCreator': asCreator.toString(),
        'asJoiner': asJoiner.toString(),
      },
      fromJson: (json) => (json as List<dynamic>)
          .map((request) => PlayRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<PlayRequest> getPlayRequestById(String requestId) async {
    final response = await _apiClient.get<PlayRequest>(
      '${AppConstants.playRequests}/$requestId',
      fromJson: (json) => PlayRequest.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<PlayRequest> joinPlayRequest({
    required String requestId,
    String? notes,
  }) async {
    final response = await _apiClient.post<PlayRequest>(
      '${AppConstants.playRequests}/$requestId/join',
      body: {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      fromJson: (json) => PlayRequest.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<PlayRequest> leavePlayRequest(String requestId) async {
    final response = await _apiClient.post<PlayRequest>(
      '${AppConstants.playRequests}/$requestId/leave',
      fromJson: (json) => PlayRequest.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
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
    final body = <String, dynamic>{
      'requestId': requestId,
    };

    if (requiredPlayers != null) body['requiredPlayers'] = requiredPlayers;
    if (ageGroup != null) body['ageGroup'] = ageGroup;
    if (level != null) body['level'] = level;
    if (status != null) body['status'] = status;
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.put<PlayRequest>(
      '${AppConstants.playRequests}/$requestId',
      body: body,
      fromJson: (json) => PlayRequest.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> deletePlayRequest(String requestId) async {
    final response = await _apiClient.delete(
      '${AppConstants.playRequests}/$requestId',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> closePlayRequest(String requestId) async {
    final response = await _apiClient.post(
      '${AppConstants.playRequests}/$requestId/close',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> cancelPlayRequest({
    required String requestId,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.playRequests}/$requestId/cancel',
      body: {'reason': reason},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<List<PlayRequest>> getStadiumPlayRequests({
    required String stadiumId,
    String? status,
    DateTime? date,
  }) async {
    final queryParameters = <String, dynamic>{
      'stadiumId': stadiumId,
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (date != null) {
      queryParameters['date'] = date.toIso8601String();
    }

    final response = await _apiClient.get<List<PlayRequest>>(
      '${AppConstants.stadiums}/$stadiumId/play-requests',
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((request) => PlayRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getPlayRequestStats({
    String? stadiumId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (stadiumId != null) {
      queryParameters['stadiumId'] = stadiumId;
    }
    if (fromDate != null) {
      queryParameters['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParameters['toDate'] = toDate.toIso8601String();
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.playRequests}/stats',
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

  Future<void> notifyJoiners(String requestId, String message) async {
    final response = await _apiClient.post(
      '${AppConstants.playRequests}/$requestId/notify',
      body: {'message': message},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<List<PlayRequest>> searchPlayRequests({
    required String query,
    String? stadiumId,
  }) async {
    final queryParameters = <String, dynamic>{
      'q': query,
    };

    if (stadiumId != null && stadiumId.isNotEmpty) {
      queryParameters['stadiumId'] = stadiumId;
    }

    final response = await _apiClient.get<List<PlayRequest>>(
      '${AppConstants.playRequests}/search',
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((request) => PlayRequest.fromJson(request as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }
}
