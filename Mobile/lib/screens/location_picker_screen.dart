import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../constants.dart';
import '../theme/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const LocationPickerScreen({super.key, this.initialLocation = const LatLng(28.6139, 77.2090)});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  MapboxMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onMapClick(Point<double> point, LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });
    _updateMarker();
  }

  void _updateMarker() async {
    if (_mapController == null) return;
    await _mapController!.clearSymbols();
    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: _selectedLocation!,
        iconImage: "marker-15",
        iconSize: 2.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selectedLocation),
            child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          )
        ],
      ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: AppConstants.mapboxAccessToken,
            initialCameraPosition: CameraPosition(target: widget.initialLocation, zoom: 14),
            onMapCreated: _onMapCreated,
            onMapClick: _onMapClick,
            onStyleLoadedCallback: _updateMarker,
            myLocationEnabled: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(child: Text('Tap on the map to place a marker at your room\'s location.', style: TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30),
              child: Icon(Icons.location_on, color: AppTheme.primaryColor, size: 40),
            ),
          ),
        ],
      ),
    );
  }
}
