import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String title;
  final String otherUserId; // Receiver ID

  const ChatDetailScreen({Key? key, required this.roomId, required this.title, required this.otherUserId}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _apiService = ApiService();
  final _msgCtrl = TextEditingController();
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String _myId = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final me = await _apiService.getMe();
    if(me != null) _myId = me.id;

    final msgs = await _apiService.getThreadMessages(widget.roomId, widget.otherUserId);
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });
  }

  void _send() async {
    if (_msgCtrl.text.isEmpty) return;
    final text = _msgCtrl.text;
    _msgCtrl.clear();
    final success = await _apiService.sendMessage(widget.otherUserId, widget.roomId, text);
    if (success) _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg['senderId'] == _myId;
                    return Container(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['content'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Type a message...'))),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _send,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
