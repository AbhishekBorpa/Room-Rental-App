import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _titleCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Mumbai');
  final _rentCtrl = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    final success = await _apiService.createRoom({
      'title': _titleCtrl.text,
      'city': _cityCtrl.text,
      'rent': int.tryParse(_rentCtrl.text) ?? 5000,
      'roomType': 'single',
    });
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room posted successfully!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post limit')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextField(controller: _cityCtrl, decoration: const InputDecoration(labelText: 'City')),
            const SizedBox(height: 16),
            TextField(controller: _rentCtrl, decoration: const InputDecoration(labelText: 'Monthly Rent (₹)'), keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Post Room'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
