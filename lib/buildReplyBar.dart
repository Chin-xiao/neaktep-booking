import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> _messages = [];
  bool _showEmoji = false;

  void _sendMessage() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "text": text,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });

    _replyController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleEmojiKeyboard() {
    if (_showEmoji) {
      setState(() => _showEmoji = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showEmoji = true);
    }
  }

  // ✅ FIXED: Use dynamic instead of Emoji
  void _onEmojiSelected(dynamic emoji) {
    final text = _replyController.text;
    final selection = _replyController.selection;

    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;

    final newText = text.replaceRange(start, end, emoji.emoji);

    _replyController.text = newText;
   _replyController.selection = TextSelection.collapsed(
  offset: (start + emoji.emoji.length).toInt(),
);

  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    return Align(
      alignment: msg["isMe"] ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: msg["isMe"] ? const Color(0xFF3056D3) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg["text"],
              style: TextStyle(
                color: msg["isMe"] ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg["time"],
              style: TextStyle(
                fontSize: 10,
                color: msg["isMe"] ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar() {
   
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.sentiment_satisfied_alt),
                onPressed: _toggleEmojiKeyboard,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _replyController,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() => _showEmoji = false);
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: "Write a reply",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFF3056D3),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        Offstage(
  offstage: !_showEmoji,
  child: SizedBox(
    height: 300,
    child: EmojiPicker(
      onEmojiSelected: (category, emoji) {
        _onEmojiSelected(emoji);
      },
    ),
  ),
),

      ],
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.userImg)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: const TextStyle(fontSize: 16)),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12, color: Colors.green),
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildReplyBar(),
        ],
      ),
    );
  }
}
