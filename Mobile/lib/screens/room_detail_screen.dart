import 'package:flutter/material.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'book_room_screen.dart';
import 'chat_detail_screen.dart';
import '../services/api_service.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _apiService = ApiService();
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void _checkFavorite() async {
    final favs = await _apiService.getFavorites();
    if (mounted && favs.any((r) => r.id == widget.room.id)) {
      setState(() => _isFavorite = true);
    }
  }

  void _toggleFav() async {
    final favs = await _apiService.toggleFavorite(widget.room.id);
    setState(() => _isFavorite = favs.contains(widget.room.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            stretch: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppTheme.primaryColor,
            actions: [
               Container(
                 margin: const EdgeInsets.only(right: 16),
                 decoration: BoxDecoration(
                   color: Colors.black.withValues(alpha: 0.3),
                   shape: BoxShape.circle,
                 ),
                 child: IconButton(
                   icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white),
                   onPressed: _toggleFav,
                 ),
               )
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'room_${widget.room.id}',
                    child: PageView.builder(
                      itemCount: widget.room.images.isEmpty ? 1 : widget.room.images.length,
                      onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                      itemBuilder: (context, index) {
                        return widget.room.images.isNotEmpty
                          ? Image.network(widget.room.images[index], fit: BoxFit.cover)
                          : Container(color: Colors.grey[300], child: const Icon(Icons.home, size: 100, color: Colors.grey));
                      },
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Image Indicators
                  if (widget.room.images.length > 1)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.room.images.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: _currentImageIndex == entry.key ? 0.9 : 0.4,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.room.roomType.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.room.title,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.room.locality ?? ''}, ${widget.room.city}',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Monthly Rent', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹${widget.room.rent}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Security Deposit', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹${widget.room.deposit}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: 0.1),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Divider(color: Color(0xFFF1F5F9)),
                ),
                
                // Amenities Grid
                Text('Property Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildAmenityCard(Icons.chair_outlined, 'Furnishing', widget.room.furnishing),
                    _buildAmenityCard(Icons.person_outline, 'Preferred', widget.room.genderPreference),
                    _buildAmenityCard(Icons.restaurant_outlined, 'Food', widget.room.foodType),
                    _buildAmenityCard(Icons.bathtub_outlined, 'Bathroom', widget.room.bathroom),
                    _buildAmenityCard(Icons.group_outlined, 'Bachelors', widget.room.bachelorsAllowed ? 'Allowed' : 'No'),
                    if(widget.room.nearMetro) _buildAmenityCard(Icons.train_outlined, 'Metro', 'Nearby'),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Description
                if (widget.room.description != null && widget.room.description!.isNotEmpty) ...[
                  Text('About this place', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    widget.room.description!,
                    style: TextStyle(height: 1.6, color: AppTheme.textDark.withValues(alpha: 0.8), fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                ],

                // Owner Info
                Text('Listed By', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.room.ownerId is Map ? widget.room.ownerId['name'] ?? 'Property Owner' : 'Property Owner',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text('Verified Owner', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.phone_outlined, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 120), // Space for bottom bar
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
          ]
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                onPressed: () {
                   if(widget.room.ownerId != null) {
                     final ownerId = widget.room.ownerId is Map ? widget.room.ownerId['_id'] : widget.room.ownerId;
                     Navigator.push(context, MaterialPageRoute(
                       builder: (_) => ChatDetailScreen(roomId: widget.room.id, title: widget.room.title, otherUserId: ownerId)
                     ));
                   }
                },
                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => BookRoomScreen(room: widget.room)));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityCard(IconData icon, String title, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          Text(
            value[0].toUpperCase() + value.substring(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}

