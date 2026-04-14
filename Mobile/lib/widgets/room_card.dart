import 'package:flutter/material.dart';
import '../models/room.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: room.images.isNotEmpty
                        ? Image.network(
                            room.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
                          )
                        : const Center(child: Icon(Icons.home_work, size: 40, color: Colors.grey)),
                  ),
                ),
                // Badges
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      room.roomType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          room.city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            // Details Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹\${room.rent}/mo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (room.locality != null) ...[
                     Text(
                      room.locality!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      _buildFeatureChip(Icons.chair, room.furnishing),
                      const SizedBox(width: 12),
                      _buildFeatureChip(Icons.wc, room.genderPreference),
                      const SizedBox(width: 12),
                      _buildFeatureChip(Icons.restaurant, room.foodType),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
