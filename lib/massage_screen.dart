import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// =====================
/// MESSAGE LIST SCREEN
/// =====================
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Message",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.grey),
                ],
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: ListView(
              children: [
                _chatItem(
                  context,
                  "Phin ChanSophal",
                  "Thank you! 😊",
                  "7:12 AM",
                  3,
                  "https://i.pravatar.cc/150?img=11",
                ),
                _chatItem(
                  context,
                  "Ms. Sokry",
                  "Yes! please take a order",
                  "9:28 AM",
                  0,
                  "https://i.pravatar.cc/150?img=5",
                ),
                _chatItem(
                  context,
                  "Mr. Sokheng",
                  "I think this one is good",
                  "4:35 PM",
                  0,
                  "https://i.pravatar.cc/150?img=8",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chatItem(
    BuildContext context,
    String name,
    String msg,
    String time,
    int unread,
    String img,
  ) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(userName: name, userImg: img),
          ),
        );
      },
      leading: CircleAvatar(backgroundImage: NetworkImage(img)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: const TextStyle(fontSize: 12)),
          if (unread > 0)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

/// =====================
/// CHAT DETAIL SCREEN
/// =====================
class ChatDetailScreen extends StatefulWidget {
  final String userName;
  final String userImg;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userImg,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showEmoji = false;

  List<Map<String, dynamic>> _messages = [];
  
  get SharedPreferences => null;

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Load messages when the screen is opened
  }

  // Save messages to local storage
  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = json.encode(_messages);
    await prefs.setString('chat_${widget.userName}', messagesJson);
  }

  // Load messages from local storage
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_${widget.userName}');
    if (messagesJson != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(json.decode(messagesJson));
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "text": _controller.text.trim(),
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });

    _controller.clear();
    _scrollToBottom();
    _saveMessages(); // Save messages after sending
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.userImg)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return Align(
                  alignment: msg["isMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg["isMe"]
                          ? const Color(0xFF3056D3)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["isMe"] ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Reply Bar + Emoji Picker
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt),
                    onPressed: () => setState(() => _showEmoji = !_showEmoji),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onTap: () => setState(() => _showEmoji = false),
                      decoration: const InputDecoration(
                        hintText: "Write a reply",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF3056D3)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
              Offstage(
                offstage: !_showEmoji,
                child: SizedBox(
                  height: 300,
                  child: EmojiPicker(
                    onEmojiSelected: (_, emoji) {
                      _controller.text += emoji.emoji;
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
