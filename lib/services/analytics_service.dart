import 'package:flutter/material.dart';
import 'package:ehgezly_app/services/api_client.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();
  
  Future<Map<String, dynamic>> getDashboardStats({
    String? ownerId,
    String? stadiumId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        if (ownerId != null) 'ownerId': ownerId,
        if (stadiumId != null) 'stadiumId': stadiumId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiClient.get(
        '/analytics/dashboard',
        queryParameters: params,
      );
      
      if (response.success) {
        return response.data;
      }
      
      throw Exception('Failed to load dashboard stats');
    } catch (e) {
      debugPrint('AnalyticsService.getDashboardStats error: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getRevenueChartData({
    required String stadiumId,
    required DateTime startDate,
    required DateTime endDate,
    String interval = 'day', // day, week, month
  }) async {
    try {
      final response = await _apiClient.get(
        '/analytics/revenue-chart',
        queryParameters: {
          'stadiumId': stadiumId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'interval': interval,
        },
      );
      
      if (response.success) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      }
      
      throw Exception('Failed to load revenue chart data');
    } catch (e) {
      debugPrint('AnalyticsService.getRevenueChartData error: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getBookingAnalytics({
    String? stadiumId,
    String? ownerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        if (stadiumId != null) 'stadiumId': stadiumId,
        if (ownerId != null) 'ownerId': ownerId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiClient.get(
        '/analytics/bookings',
        queryParameters: params,
      );
      
      if (response.success) {
        return List<Map<String, dynamic>>.from(response.data['analytics'] ?? []);
      }
      
      throw Exception('Failed to load booking analytics');
    } catch (e) {
      debugPrint('AnalyticsService.getBookingAnalytics error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getUserAnalytics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        'userId': userId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiClient.get(
        '/analytics/user',
        queryParameters: params,
      );
      
      if (response.success) {
        return response.data;
      }
      
      throw Exception('Failed to load user analytics');
    } catch (e) {
      debugPrint('AnalyticsService.getUserAnalytics error: $e');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getPopularSlots({
    required String stadiumId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        'stadiumId': stadiumId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiClient.get(
        '/analytics/popular-slots',
        queryParameters: params,
      );
      
      if (response.success) {
        return List<Map<String, dynamic>>.from(response.data['slots'] ?? []);
      }
      
      throw Exception('Failed to load popular slots');
    } catch (e) {
      debugPrint('AnalyticsService.getPopularSlots error: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getCancellationAnalysis({
    required String stadiumId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        'stadiumId': stadiumId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiClient.get(
        '/analytics/cancellations',
        queryParameters: params,
      );
      
      if (response.success) {
        return response.data;
      }
      
      throw Exception('Failed to load cancellation analysis');
    } catch (e) {
      debugPrint('AnalyticsService.getCancellationAnalysis error: $e');
      rethrow;
    }
  }
}
