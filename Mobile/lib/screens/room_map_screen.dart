import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../constants.dart';
import 'room_detail_screen.dart';

class RoomMapScreen extends StatefulWidget {
  const RoomMapScreen({super.key});

  @override
  State<RoomMapScreen> createState() => _RoomMapScreenState();
}

class _RoomMapScreenState extends State<RoomMapScreen> {
  MapboxMapController? _mapController;
  final ApiService _apiService = ApiService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    final rooms = await _apiService.getRooms();
    setState(() {
      _rooms = rooms.where((r) => r.latitude != null && r.longitude != null).toList();
      _isLoading = false;
    });
    // Markers are added in _onStyleLoaded
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() async {
    if (_mapController == null || _rooms.isEmpty) return;
    _addMarkers();
  }

  void _addMarkers() async {
    if (_mapController == null || _rooms.isEmpty) return;

    for (var room in _rooms) {
      await _mapController!.addSymbol(
        SymbolOptions(
          geometry: LatLng(room.latitude!, room.longitude!),
          iconImage: "marker-15", // Standard Mapbox marker icon
          iconSize: 1.5,
          textField: '₹${room.rent}',
          textOffset: const Offset(0, 2),
          textColor: '#6366F1',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 2,
        ),
      );
    }
    
    // Center map on first room if available
    if (_rooms.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_rooms.first.latitude!, _rooms.first.longitude!),
          12,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Nearby'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MapboxMap(
            accessToken: AppConstants.mapboxAccessToken,
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6139, 77.2090), // Default Delhi
              zoom: 10,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.Tracking,
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          
          // Horizontal Room Cards at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return GestureDetector(
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(LatLng(room.latitude!, room.longitude!), 14),
                      );
                    },
                    onDoubleTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                        ]
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: room.images.isNotEmpty 
                              ? Image.network(room.images.first, width: 80, height: 80, fit: BoxFit.cover)
                              : Container(width: 80, height: 80, color: Colors.grey[200]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(room.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('₹${room.rent}/mo', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                Text(room.locality ?? room.city, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
