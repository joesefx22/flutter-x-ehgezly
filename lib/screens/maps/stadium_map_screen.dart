import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ehgezly_app/services/map_service.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class StadiumMapScreen extends StatefulWidget {
  static const routeName = '/maps/stadium';
  
  final double latitude;
  final double longitude;
  final String stadiumName;
  final String? stadiumAddress;
  
  const StadiumMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.stadiumName,
    this.stadiumAddress,
  });
  
  @override
  State<StadiumMapScreen> createState() => _StadiumMapScreenState();
}

class _StadiumMapScreenState extends State<StadiumMapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isMapLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }
  
  void _initializeMap() {
    final marker = Marker(
      markerId: const MarkerId('stadium'),
      position: LatLng(widget.latitude, widget.longitude),
      infoWindow: InfoWindow(
        title: widget.stadiumName,
        snippet: widget.stadiumAddress,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    
    setState(() {
      _markers.add(marker);
      _isMapLoading = false;
    });
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  
  Future<void> _openInGoogleMaps() async {
    try {
      await MapService.openInMaps(
        latitude: widget.latitude,
        longitude: widget.longitude,
        label: widget.stadiumName,
      );
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في فتح الخرائط');
    }
  }
  
  Future<void> _getDirections() async {
    // TODO: Get current location
    final currentLat = 30.0444; // Cairo coordinates for demo
    final currentLng = 31.2357;
    
    try {
      await MapService.openDirections(
        startLatitude: currentLat,
        startLongitude: currentLng,
        endLatitude: widget.latitude,
        endLongitude: widget.longitude,
      );
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في فتح الاتجاهات');
    }
  }
  
  Widget _buildStadiumInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stadiumName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.stadiumAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.stadiumAddress!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: _getDirections,
                  text: 'الاتجاهات',
                  icon: Icons.directions_outlined,
                  type: ButtonType.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: _openInGoogleMaps,
                  text: 'فتح في خرائط',
                  icon: Icons.open_in_new_outlined,
                  type: ButtonType.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الموقع'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: 15,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: false,
          ),
          if (_isMapLoading)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStadiumInfo(),
          ),
        ],
      ),
    );
  }
}
