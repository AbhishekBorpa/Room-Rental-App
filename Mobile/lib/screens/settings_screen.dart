import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: true,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false,
            onChanged: (val) {},
          ),
          const ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Terms of Service'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
