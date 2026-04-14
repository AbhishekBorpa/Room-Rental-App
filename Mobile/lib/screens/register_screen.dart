import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'tenant';
  final _apiService = ApiService();
  bool _isLoading = false;

  void _handleRegister() async {
    setState(() => _isLoading = true);
    final result = await _apiService.register({
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
      'password': _passCtrl.text,
      'phone': _phoneCtrl.text,
      'role': _role,
    });
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 16),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'I want to...'),
                items: const [
                   DropdownMenuItem(value: 'tenant', child: Text('Rent a Room')),
                   DropdownMenuItem(value: 'owner', child: Text('List my Room')),
                ],
                onChanged: (val) => setState(() => _role = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
