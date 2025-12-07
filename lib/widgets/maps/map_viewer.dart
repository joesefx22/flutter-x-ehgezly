import 'package:flutter/material.dart';
import 'package:ehgezly_app/services/map_service.dart';
import 'package:ehgezly_app/widgets/common/button.dart';

class MapViewer extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? label;
  final double? width;
  final double? height;
  final bool showOpenButton;
  
  const MapViewer({
    super.key,
    required this.latitude,
    required this.longitude,
    this.label,
    this.width,
    this.height,
    this.showOpenButton = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final mapUrl = MapService.getStaticMapUrl(
      latitude: latitude,
      longitude: longitude,
      width: (width ?? 400).toInt(),
      height: (height ?? 200).toInt(),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            mapUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.location_off_outlined, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        if (showOpenButton)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AppButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/maps/stadium',
                  arguments: {
                    'latitude': latitude,
                    'longitude': longitude,
                    'stadiumName': label ?? 'الموقع',
                  },
                );
              },
              text: 'عرض الخريطة الكاملة',
              type: ButtonType.text,
              size: ButtonSize.small,
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
