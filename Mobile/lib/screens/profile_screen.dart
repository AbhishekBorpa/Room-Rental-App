import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = await _apiService.getMe();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  void _logout() async {
    await _apiService.logout();
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_user == null) return const Center(child: Text('Please login to view profile'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user!))).then((_) => _fetchProfile()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withAlpha(20),
              child: Text(_user!.name[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: AppTheme.primaryColor)),
            ),
            const SizedBox(height: 16),
            Text(_user!.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(_user!.email, style: const TextStyle(color: AppTheme.textMuted)),
            const SizedBox(height: 32),
            _buildActionTile(Icons.person, 'Account Type', _user!.role.toUpperCase()),
            _buildActionTile(Icons.phone, 'Phone Number', _user!.phone),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor, side: const BorderSide(color: AppTheme.errorColor)),
                child: const Text('Logout'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(20), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
      subtitle: Text(value, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
