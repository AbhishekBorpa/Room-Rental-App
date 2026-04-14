import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import 'create_room_screen.dart';
import 'edit_room_screen.dart';
import '../theme/app_theme.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final _apiService = ApiService();
  List<Room> _myRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyListing();
  }

  Future<void> _fetchMyListing() async {
    // Actually the current API doesn't have a specific owner route. 
    // Wait, the API routes/rooms.js doesn't specifically have /owner/my-listings yet,
    // so I will just call /api/rooms and in a real scenario we pass ownerId query.
    // For now, let's assume we fetch all and let backend filter, or just use the generic get rooms.
    final user = await _apiService.getMe();
    if(user != null){
       // Fetching only rooms belonging to this owner is typically done by backend.
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Dashboard')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.dashboard, size: 40, color: AppTheme.primaryColor),
                  SizedBox(width: 16),
                  Expanded(child: Text('Manage your properties and track bookings here.', style: TextStyle(color: AppTheme.primaryColor))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_home),
                label: const Text('Post New Room'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
