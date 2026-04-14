import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Shimmer
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 24,
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
                    
                    Container(
                      height: 24,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                 .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
                
                const SizedBox(height: 16),
                Row(
                  children: List.generate(3, (index) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
