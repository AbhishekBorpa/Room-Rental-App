import 'package:flutter/material.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'book_room_screen.dart';
import 'chat_detail_screen.dart';
import '../services/api_service.dart';

class RoomDetailScreen extends StatefulWidget {
  final Room room;

  const RoomDetailScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _apiService = ApiService();
  bool _isFavorite = false;

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
            expandedHeight: 300,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: AppTheme.primaryColor,
            actions: [
               IconButton(
                 icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.white),
                 onPressed: _toggleFav,
               )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.room.images.isNotEmpty
                      ? Image.network(widget.room.images.first, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300], child: const Icon(Icons.home, size: 100, color: Colors.grey)),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.transparent,
                          Colors.black.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
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
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.room.title,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '\${widget.room.locality ?? ''}, \${widget.room.city}',
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
                        const Text('Rent', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                        Text('₹\${widget.room.rent}/mo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor)),
                      ],
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[200]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deposit', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                        Text('₹\${widget.room.deposit}', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: 0.1),
                
                const SizedBox(height: 32),
                
                // Amenities Grid
                Text('Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildAmenityCard(Icons.chair, 'Furnishing', widget.room.furnishing),
                    _buildAmenityCard(Icons.wc, 'Preferred', widget.room.genderPreference),
                    _buildAmenityCard(Icons.restaurant, 'Food', widget.room.foodType),
                    _buildAmenityCard(Icons.bathtub, 'Bathroom', widget.room.bathroom),
                    _buildAmenityCard(Icons.person, 'Bachelors', widget.room.bachelorsAllowed ? 'Allowed' : 'No'),
                    if(widget.room.nearMetro) _buildAmenityCard(Icons.train, 'Metro', 'Nearby'),
                  ],
                ).animate().fadeIn().slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Description
                if (widget.room.description != null && widget.room.description!.isNotEmpty) ...[
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    widget.room.description!,
                    style: TextStyle(height: 1.6, color: AppTheme.textDark.withAlpha(200)),
                  ),
                  const SizedBox(height: 100), // padding for bottom bar
                ]
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => BookRoomScreen(room: widget.room)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                ),
                child: const Text('Schedule Visit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                   if(widget.room.ownerId != null) {
                     final ownerId = widget.room.ownerId is Map ? widget.room.ownerId['_id'] : widget.room.ownerId;
                     Navigator.push(context, MaterialPageRoute(
                       builder: (_) => ChatDetailScreen(roomId: widget.room.id, title: widget.room.title, otherUserId: ownerId)
                     ));
                   }
                },
                child: const Text('Contact Owner'),
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
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(50))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          Text(value.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }
}
