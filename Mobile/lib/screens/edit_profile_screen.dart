import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  void _save() async {
    setState(() => _isLoading = true);
    final success = await _apiService.updateProfile({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
    });
    setState(() => _isLoading = false);
    
    if (success) {
      if(mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 16),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
