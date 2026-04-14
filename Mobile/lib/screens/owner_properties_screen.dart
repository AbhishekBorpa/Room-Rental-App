import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import 'create_room_screen.dart';
import 'room_detail_screen.dart';
import 'edit_room_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/room_card.dart';

class OwnerPropertiesScreen extends StatefulWidget {
  const OwnerPropertiesScreen({super.key});

  @override
  State<OwnerPropertiesScreen> createState() => _OwnerPropertiesScreenState();
}

class _OwnerPropertiesScreenState extends State<OwnerPropertiesScreen> {
  final _apiService = ApiService();
  List<Room> _myRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyListings();
  }

  Future<void> _fetchMyListings() async {
    setState(() => _isLoading = true);
    final rooms = await _apiService.getOwnerRooms();
    setState(() {
      _myRooms = rooms;
      _isLoading = false;
    });
  }

  Future<void> _deleteProperty(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property?'),
        content: const Text('Are you sure you want to remove this listing? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiService.deleteRoom(id);
      if (success) {
        _fetchMyListings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property removed')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen()));
              _fetchMyListings();
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _fetchMyListings,
            child: _myRooms.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myRooms.length,
                  itemBuilder: (context, index) {
                    final room = _myRooms[index];
                    return Stack(
                      children: [
                        RoomCard(
                          room: room,
                          onTap: () async {
                             await Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: room)));
                             _fetchMyListings();
                          },
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Row(
                            children: [
                              _buildActionCircle(
                                icon: Icons.edit,
                                color: Colors.blue,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditRoomScreen(room: room)),
                                  );
                                  _fetchMyListings();
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildActionCircle(
                                icon: Icons.delete,
                                color: Colors.red,
                                onTap: () => _deleteProperty(room.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
          ),
    );
  }

  Widget _buildActionCircle({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text('No properties listed yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Start by listing your first room and earn extra income.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('List a Room'),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen()));
                _fetchMyListings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
