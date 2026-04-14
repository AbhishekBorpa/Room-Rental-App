import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const RoomRentalApp());
}

class RoomRentalApp extends StatelessWidget {
  const RoomRentalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(),
      child: MaterialApp(
        title: 'Room Rental App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _hasToken = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await _apiService.getToken();
    setState(() {
      _hasToken = token != null && token.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasToken ? const MainScaffold() : const LoginScreen();
  }
}
