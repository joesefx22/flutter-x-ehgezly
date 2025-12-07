import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة');
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('تم رفض إذن الموقع');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('تم رفض إذن الموقع بشكل دائم');
      }
      
      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      debugPrint('LocationService.getCurrentLocation error: $e');
      rethrow;
    }
  }
  
  static Future<double> calculateDistanceToStadium({
    required double stadiumLat,
    required double stadiumLng,
  }) async {
    try {
      final currentPosition = await getCurrentLocation();
      
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        stadiumLat,
        stadiumLng,
      );
      
      return distance / 1000; // Convert to kilometers
    } catch (e) {
      debugPrint('LocationService.calculateDistanceToStadium error: $e');
      return 0;
    }
  }
  
  static Future<bool> isWithinRadius({
    required double targetLat,
    required double targetLng,
    required double radiusKm,
  }) async {
    try {
      final distance = await calculateDistanceToStadium(
        stadiumLat: targetLat,
        stadiumLng: targetLng,
      );
      
      return distance <= radiusKm;
    } catch (e) {
      debugPrint('LocationService.isWithinRadius error: $e');
      return false;
    }
  }
  
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
  }
  
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('LocationService.openLocationSettings error: $e');
    }
  }
  
  static Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('LocationService.openAppSettings error: $e');
    }
  }
}
