import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final result = await _apiService.login(_emailCtrl.text, _passCtrl.text);
    setState(() => _isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Login to find your perfect room',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScaffold()),
                  );
                },
                child: const Text('Skip for now'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
