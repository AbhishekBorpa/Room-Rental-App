import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'tenant';
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscureText = true;

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await _apiService.register({
      'name': _nameCtrl.text,
      'email': _emailCtrl.text,
      'password': _passCtrl.text,
      'phone': _phoneCtrl.text,
      'role': _role,
    });
    
    if (result['success']) {
      await _apiService.saveUserRole(_role);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScaffold(role: _role)),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Join RoomRent', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                const Text('Enter your details to get started', style: TextStyle(color: AppTheme.textMuted)),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _nameCtrl, 
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl, 
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.mail_outline)), 
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl, 
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)), 
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Enter valid phone number' : null,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl, 
                  decoration: InputDecoration(
                    labelText: 'Password', 
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ), 
                  obscureText: _obscureText,
                  validator: (v) => v!.length < 6 ? 'Password too short' : null,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 32),
                const Text('I am a...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildRoleCard('tenant', 'Tenant', Icons.search, 'Find a room')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRoleCard('owner', 'Owner', Icons.vpn_key_outlined, 'List a room')),
                  ],
                ).animate().fadeIn(delay: 500.ms).scale(),
                
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 8,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Create Account'),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(String role, String title, IconData icon, String subtitle) {
    bool isSelected = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryColor : AppTheme.textDark)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 10, color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.8) : AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}

