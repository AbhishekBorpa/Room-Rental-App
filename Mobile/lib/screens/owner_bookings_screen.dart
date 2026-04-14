import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  final _apiService = ApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _updatingId; // Track which booking is being updated

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getOwnerBookings();
      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    setState(() => _updatingId = id);
    try {
      final success = await _apiService.updateBookingStatus(id, status);
      if (success) {
        // Optimistic UI update or just re-fetch
        await _fetchBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking request $status'),
              backgroundColor: status == 'confirmed' ? AppTheme.secondaryColor : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Booking Requests'),
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        foregroundColor: AppTheme.textDark,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _fetchBookings,
            child: _bookings.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final b = _bookings[index];
                    final room = b['roomId'] ?? {};
                    final tenant = b['tenantId'] ?? {};
                    final status = b['status'] ?? 'pending';
                    final isUpdating = _updatingId == b['_id'];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 2,
                      shadowColor: Colors.black.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    room['title'] ?? 'Room Name', 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark)
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      tenant['name']?[0] ?? 'U', 
                                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)
                                    )
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tenant['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                    Text('Contact: ${tenant['phone'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Estimated Rent', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                    Text('₹${b['amount'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Move-in Date', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                    Text(b['startDate']?.split('T')[0] ?? 'TBD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            if (status == 'pending') ...[
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: isUpdating ? null : () => _updateStatus(b['_id'], 'rejected'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red, 
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: const BorderSide(color: Colors.red, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isUpdating ? null : () => _updateStatus(b['_id'], 'confirmed'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.secondaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: isUpdating 
                                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
                  },
                ),
          ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    String label = 'PENDING';
    if (status == 'confirmed') {
      color = AppTheme.secondaryColor;
      label = 'CONFIRMED';
    } else if (status == 'rejected') {
      color = Colors.red;
      label = 'REJECTED';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        label, 
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          const Text('No booking requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Share your room listing to get requests.', style: TextStyle(color: AppTheme.textMuted)),
        ],
      ),
    ).animate().fadeIn();
  }
}

