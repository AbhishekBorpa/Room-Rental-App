import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BookRoomScreen extends StatefulWidget {
  final Room room;
  const BookRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<BookRoomScreen> createState() => _BookRoomScreenState();
}

class _BookRoomScreenState extends State<BookRoomScreen> {
  final _apiService = ApiService();
  DateTime? _selectedDate;
  bool _isLoading = false;

  void _book() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a move-in date')));
      return;
    }
    setState(() => _isLoading = true);
    final success = await _apiService.createBooking(widget.room.id, _selectedDate!.toIso8601String(), widget.room.rent);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request sent successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to book')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.room.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Rent: ₹\${widget.room.rent}/mo', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Select Move-in Date', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.textMuted),
                    const SizedBox(width: 12),
                    Text(_selectedDate == null ? 'Choose a date' : '\${_selectedDate!.toLocal()}'.split(' ')[0])
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _book,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Booking Request'),
            )
          ],
        ),
      ),
    );
  }
}
