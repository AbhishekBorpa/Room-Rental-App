import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _apiService = ApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final data = await _apiService.getMyBookings();
    setState(() {
      _bookings = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty 
          ? const Center(child: Text('No active bookings found'))
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                final b = _bookings[index];
                final r = b['roomId'] ?? {};
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(r['title'] ?? 'Room', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Move in: ${b['startDate']?.split('T')[0] ?? 'N/A'}"),
                        Text("Status: ${(b['status'] ?? '').toUpperCase()}", style: TextStyle(
                          color: b['status'] == 'pending' ? Colors.orange : AppTheme.secondaryColor,
                          fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                    trailing: Text("₹${b['amount']}"),
                  ),
                );
              },
            ),
    );
  }
}
