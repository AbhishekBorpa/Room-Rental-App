import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_detail_screen.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({Key? key}) : super(key: key);

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final _apiService = ApiService();
  List<dynamic> _threads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    final threads = await _apiService.getChatThreads();
    setState(() {
      _threads = threads;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages'), automaticallyImplyLeading: false),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _threads.isEmpty
          ? const Center(child: Text('No messages yet'))
          : ListView.builder(
              itemCount: _threads.length,
              itemBuilder: (context, index) {
                final thread = _threads[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(thread['roomId']?['title'] ?? 'Room Inquiry'),
                  subtitle: Text(thread['content']),
                  onTap: () {
                    // Navigate to individual chat
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        roomId: thread['roomId']?['_id'] ?? '',
                        title: thread['roomId']?['title'] ?? 'Chat',
                        otherUserId: thread['receiverId']['_id'], 
                      )
                    ));
                  },
                );
              },
            ),
    );
  }
}
