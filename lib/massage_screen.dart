import 'package:flutter/material.dart';

// --- PART 1: MESSAGE LIST SCREEN ---
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {}, // Handled by MainNavigation
        ),
        title: const Text("Message", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100], 
                borderRadius: BorderRadius.circular(15)
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...", 
                        border: InputBorder.none, 
                        contentPadding: EdgeInsets.only(left: 10)
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.grey),
                ],
              ),
            ),
          ),
          // Conversations List
          Expanded(
            child: ListView(
              children: [
                _buildChatItem(context, "Phin ChanSophal", "Thank you! 😊", "7:12 Am", 3, 'https://i.pravatar.cc/150?img=11'),
                _buildChatItem(context, "Ms. Sokry", "Yes! please take a order", "9:28 Am", 0, 'https://i.pravatar.cc/150?img=5'),
                _buildChatItem(context, "Mr. SoKheng", "I think this one is good", "4:35 Pm", 0, 'https://i.pravatar.cc/150?img=8'),
                _buildChatItem(context, "Ms. Da. Rong", "Wow, this is really epic", "8:12 Pm", 0, 'https://i.pravatar.cc/150?img=9'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF3056D3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String msg, String time, int unread, String img) {
    return ListTile(
      onTap: () {
        // Navigates to the ChatDetailScreen defined below
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => ChatDetailScreen(userName: name, userImg: img))
        );
      },
      leading: CircleAvatar(radius: 25, backgroundImage: NetworkImage(img)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          if (unread > 0)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
        ],
      ),
    );
  }
}

// --- PART 2: INDIVIDUAL CHAT SCREEN ---
class ChatDetailScreen extends StatelessWidget {
  final String userName;
  final String userImg;

  const ChatDetailScreen({super.key, required this.userName, required this.userImg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(userImg)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Online", style: TextStyle(color: Colors.blue[700], fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: const [
          Icon(Icons.videocam_outlined, color: Colors.black),
          SizedBox(width: 15),
          Icon(Icons.call_outlined, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildChatHotelCard(),
                const SizedBox(height: 20),
                _buildMessageBubble("hi for this hotel with a king sweet room are there still any vacancies?", true, "10:15 AM"),
                _buildMessageBubble("Hey Dear", false, "10:30 AM"),
                _buildMessageBubble("Yes the room is available, so you can make an order.", false, "10:31 AM"),
              ],
            ),
          ),
          _buildReplyBar(),
        ],
      ),
    );
  }

  Widget _buildChatHotelCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10), 
            child: Image.network('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=200', width: 60, height: 60, fit: BoxFit.cover)
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("The Aston Vill Hotel", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Veum Point, Michikoton", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text("\$120 /night", style: TextStyle(color: Color(0xFF3056D3), fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const Text(" 4.7", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xFF3056D3) : Colors.grey[100],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: Radius.circular(isMe ? 15 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 15),
            ),
          ),
          child: Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 14)),
        ),
        Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Write a reply", 
                  border: InputBorder.none, 
                  prefixIcon: Icon(Icons.sentiment_satisfied_alt)
                )
              ),
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            backgroundColor: Color(0xFF3056D3), 
            child: Icon(Icons.send, color: Colors.white)
          ),
        ],
      ),
    );
  }
}