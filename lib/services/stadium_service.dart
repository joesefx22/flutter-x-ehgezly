import 'package:ehgezly_app/models/stadium.dart';
import 'package:ehgezly_app/services/api_client.dart';
import 'package:ehgezly_app/utils/app_constants.dart';

class StadiumService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Stadium>> getStadiums({
    String? type,
    String? city,
    double? minPrice,
    double? maxPrice,
    List<String>? features,
    String? searchQuery,
    int page = 1,
    int limit = AppConstants.stadiumsPerPage,
    String? sortBy,
    String? order = 'desc',
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
      'order': order,
    };

    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }
    if (city != null && city.isNotEmpty) {
      queryParameters['city'] = city;
    }
    if (minPrice != null) {
      queryParameters['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParameters['maxPrice'] = maxPrice.toString();
    }
    if (features != null && features.isNotEmpty) {
      queryParameters['features'] = features.join(',');
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParameters['search'] = searchQuery;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sortBy'] = sortBy;
    }

    final response = await _apiClient.get<List<Stadium>>(
      AppConstants.stadiums,
      queryParameters: queryParameters,
      fromJson: (json) => (json as List<dynamic>)
          .map((stadium) => Stadium.fromJson(stadium as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Stadium> getStadiumById(String stadiumId) async {
    final response = await _apiClient.get<Stadium>(
      '${AppConstants.stadiums}/$stadiumId',
      fromJson: (json) => Stadium.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<StadiumSlot>> getAvailableSlots({
    required String stadiumId,
    required DateTime date,
  }) async {
    final response = await _apiClient.get<List<StadiumSlot>>(
      '${AppConstants.stadiums}/$stadiumId/slots',
      queryParameters: {
        'date': date.toIso8601String(),
      },
      fromJson: (json) => (json as List<dynamic>)
          .map((slot) => StadiumSlot.fromJson(slot as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Stadium>> getNearbyStadiums({
    required double latitude,
    required double longitude,
    double radius = 10, // in kilometers
    String? type,
  }) async {
    final response = await _apiClient.get<List<Stadium>>(
      '${AppConstants.stadiums}/nearby',
      queryParameters: {
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        if (type != null && type.isNotEmpty) 'type': type,
      },
      fromJson: (json) => (json as List<dynamic>)
          .map((stadium) => Stadium.fromJson(stadium as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<String>> getAvailableFeatures() async {
    final response = await _apiClient.get<List<String>>(
      '${AppConstants.stadiums}/features',
      fromJson: (json) => List<String>.from(json as List<dynamic>),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<String>> getAvailableCities() async {
    final response = await _apiClient.get<List<String>>(
      '${AppConstants.stadiums}/cities',
      fromJson: (json) => List<String>.from(json as List<dynamic>),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Stadium> createStadium({
    required String name,
    required String type,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required double pricePerHour,
    double depositPercentage = 0.3,
    List<String> features = const [],
    List<String> images = const [],
  }) async {
    final response = await _apiClient.post<Stadium>(
      AppConstants.stadiums,
      body: {
        'name': name,
        'type': type,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'pricePerHour': pricePerHour,
        'depositPercentage': depositPercentage,
        'features': features,
        'images': images,
      },
      fromJson: (json) => Stadium.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<Stadium> updateStadium({
    required String stadiumId,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    double? pricePerHour,
    double? depositPercentage,
    List<String>? features,
    List<String>? images,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      'stadiumId': stadiumId,
    };

    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (address != null) body['address'] = address;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (pricePerHour != null) body['pricePerHour'] = pricePerHour;
    if (depositPercentage != null) body['depositPercentage'] = depositPercentage;
    if (features != null) body['features'] = features;
    if (images != null) body['images'] = images;
    if (isActive != null) body['isActive'] = isActive;

    final response = await _apiClient.put<Stadium>(
      '${AppConstants.stadiums}/$stadiumId',
      body: body,
      fromJson: (json) => Stadium.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> deleteStadium(String stadiumId) async {
    final response = await _apiClient.delete(
      '${AppConstants.stadiums}/$stadiumId',
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> addStadiumImages(String stadiumId, List<String> imageUrls) async {
    final response = await _apiClient.post(
      '${AppConstants.stadiums}/$stadiumId/images',
      body: {'images': imageUrls},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<void> removeStadiumImage(String stadiumId, String imageUrl) async {
    final response = await _apiClient.delete(
      '${AppConstants.stadiums}/$stadiumId/images',
      body: {'imageUrl': imageUrl},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }

  Future<List<Stadium>> getMyStadiums() async {
    final response = await _apiClient.get<List<Stadium>>(
      '${AppConstants.stadiums}/my',
      fromJson: (json) => (json as List<dynamic>)
          .map((stadium) => Stadium.fromJson(stadium as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<Map<String, dynamic>> getStadiumStats(String stadiumId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${AppConstants.stadiums}/$stadiumId/stats',
      fromJson: (json) => Map<String, dynamic>.from(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<Stadium>> searchStadiums(String query) async {
    final response = await _apiClient.get<List<Stadium>>(
      '${AppConstants.stadiums}/search',
      queryParameters: {'q': query},
      fromJson: (json) => (json as List<dynamic>)
          .map((stadium) => Stadium.fromJson(stadium as Map<String, dynamic>))
          .toList(),
      requiresAuth: true,
    );

    if (response.success) {
      return response.data ?? [];
    } else {
      throw Exception(response.message);
    }
  }

  Future<void> updateStadiumSlots(
    String stadiumId,
    List<Map<String, dynamic>> slots,
  ) async {
    final response = await _apiClient.post(
      '${AppConstants.stadiums}/$stadiumId/slots',
      body: {'slots': slots},
      requiresAuth: true,
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
