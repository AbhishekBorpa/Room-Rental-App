import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../widgets/room_card.dart';
import '../widgets/shimmer_card.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'room_detail_screen.dart';
import '../widgets/filter_sheet.dart';
import 'dart:async';
import 'room_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Room> _rooms = [];
  bool _isLoading = true;
  String _selectedCity = 'All';

  final List<String> _cities = ['All', 'Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad'];
  
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  Map<String, String> _advancedFilters = {};

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      // Combine all filters
      Map<String, String> consolidatedFilters = {..._advancedFilters};
      
      if (_selectedCity != 'All') {
        consolidatedFilters['city'] = _selectedCity;
      }
      
      if (_searchCtrl.text.isNotEmpty) {
        consolidatedFilters['search'] = _searchCtrl.text;
      }

      final rooms = await _apiService.getRooms(
        filters: consolidatedFilters.isEmpty ? null : consolidatedFilters,
      );
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load rooms')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRooms();
    });
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(initialFilters: _advancedFilters),
    );

    if (result != null) {
      setState(() {
        _advancedFilters = result;
      });
      _fetchRooms();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomMapScreen())),
        label: const Text('Map View'),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 600.ms),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Perfect Room',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppTheme.primaryColor),
                  )
                ],
              ),
            ),
            
            // Search / Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'Search locality or title...',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      ),
                      child: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Cities List
            SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _cities.length,
                itemBuilder: (context, index) {
                  final city = _cities[index];
                  final isSelected = city == _selectedCity;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCity = city);
                      _fetchRooms();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                         border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        city,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Rooms List
            Expanded(
              child: _isLoading 
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: 3,
                    itemBuilder: (context, index) => const ShimmerCard(),
                  )
                : _rooms.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No rooms found',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _rooms.length,
                        itemBuilder: (context, index) {
                          return RoomCard(
                            room: _rooms[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoomDetailScreen(room: _rooms[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
