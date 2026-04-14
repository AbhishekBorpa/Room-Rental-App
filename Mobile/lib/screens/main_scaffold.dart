import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'messages_list_screen.dart';
import 'profile_screen.dart';
import 'owner_properties_screen.dart';
import 'owner_bookings_screen.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  final String role;
  const MainScaffold({super.key, this.role = 'tenant'});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  List<Widget> _getScreens() {
    if (widget.role == 'owner') {
      return [
        const OwnerPropertiesScreen(), // Will list properties
        const OwnerBookingsScreen(),  // Will list requests
        const MessagesListScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      const HomeScreen(),
      const FavoritesScreen(),
      const MessagesListScreen(),
      const ProfileScreen(),
    ];
  }

  List<NavigationDestination> _getDestinations() {
    if (widget.role == 'owner') {
      return const [
        NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business), label: 'My Rooms'),
        NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Requests'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
    return const [
      NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Explore'),
      NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
      NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Inbox'),
      NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: AppTheme.primaryColor.withAlpha(30),
        destinations: _getDestinations(),
      ),
    );
  }
}
