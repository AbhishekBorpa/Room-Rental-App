import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../widgets/room_card.dart';
import 'room_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _apiService = ApiService();
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final rooms = await _apiService.getFavorites();
    setState(() {
      _rooms = rooms;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Rooms'), automaticallyImplyLeading: false),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _rooms.isEmpty 
          ? const Center(child: Text('No favorite rooms yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _rooms.length,
              itemBuilder: (context, index) {
                return RoomCard(
                  room: _rooms[index],
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => RoomDetailScreen(room: _rooms[index]))).then((_) => _fetchFavorites());
                  },
                );
              },
            ),
    );
  }
}
