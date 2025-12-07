import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class MapService {
  static Future<void> openInMaps({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$label',
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open maps';
    }
  }
  
  static Future<void> openDirections({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$startLatitude,$startLongitude'
      '&destination=$endLatitude,$endLongitude'
      '&travelmode=driving',
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open directions';
    }
  }
  
  static String getStaticMapUrl({
    required double latitude,
    required double longitude,
    int width = 400,
    int height = 200,
    int zoom = 15,
    String markerColor = 'red',
  }) {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=$latitude,$longitude'
        '&zoom=$zoom'
        '&size=${width}x$height'
        '&scale=2'
        '&markers=color:$markerColor%7C$latitude,$longitude'
        '&key=YOUR_GOOGLE_MAPS_API_KEY'; // Replace with your API key
  }
  
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;
    
    return distance;
  }
  
  static double _toRadians(double degree) {
    return degree * (3.141592653589793 / 180);
  }
  
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final distanceInMeters = (distanceInKm * 1000).round();
      return '$distanceInMeters م';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} كم';
    }
  }
}
