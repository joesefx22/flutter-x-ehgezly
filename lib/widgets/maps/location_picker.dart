import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ehgezly_app/widgets/common/button.dart';
import 'package:ehgezly_app/services/location_service.dart';
import 'package:ehgezly_app/utils/helpers.dart';

class LocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng> onLocationSelected;
  final String? hintText;
  
  const LocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
    this.hintText,
  });
  
  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }
  
  void _initializeLocation() {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _addMarker(_selectedLocation!);
    }
  }
  
  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
            widget.onLocationSelected(newPosition);
          },
        ),
      );
      _selectedLocation = position;
    });
  }
  
  Future<void> _useCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      
      final position = await LocationService.getCurrentLocation();
      final location = LatLng(position.latitude, position.longitude);
      
      _addMarker(location);
      widget.onLocationSelected(location);
      
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(location, 15),
      );
    } catch (e) {
      Helpers.showErrorSnackbar(context, 'فشل في الحصول على الموقع الحالي');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Center map on selected location or default location (Cairo)
    if (_selectedLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
      );
    } else {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(30.0444, 31.2357), 10),
      );
    }
  }
  
  void _onMapTap(LatLng position) {
    _addMarker(position);
    widget.onLocationSelected(position);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.hintText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.hintText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(30.0444, 31.2357),
                    zoom: 10,
                  ),
                  markers: _markers,
                  onTap: _onMapTap,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                ),
                
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _useCurrentLocation,
                    mini: true,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedLocation != null
                    ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(6)}'
                    : 'انقر على الخريطة لتحديد الموقع',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
