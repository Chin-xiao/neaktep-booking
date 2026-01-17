import 'package:flutter/material.dart';

import 'components/safe_network_image.dart';

// --- PART 1: MESSAGE LIST SCREEN ---
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        "name": "Phin ChanSophal",
        "msg": "Thank you! 😊",
        "time": "7:12 Am",
        "unread": 3,
        "img": 'https://i.pravatar.cc/150?img=11',
      },
      {
        "name": "Ms. Sokry",
        "msg": "Yes! please take a order",
        "time": "9:28 Am",
        "unread": 0,
        "img": 'https://i.pravatar.cc/150?img=5',
      },
      {
        "name": "Mr. SoKheng",
        "msg": "I think this one is good",
        "time": "4:35 Pm",
        "unread": 0,
        "img": 'https://i.pravatar.cc/150?img=8',
      },
      {
        "name": "Ms. Da. Rong",
        "msg": "Wow, this is really epic",
        "time": "8:12 Pm",
        "unread": 0,
        "img": 'https://i.pravatar.cc/150?img=9',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          "Message",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Pro Search Bar from your design
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.grey),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(chat['img']),
                  ),
                  title: Text(
                    chat['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    chat['msg'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chat['time'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      if (chat['unread'] > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat['unread'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          userName: chat['name'],
                          userImg: chat['img'],
                        ),
                      ),
                    );
                  },
                );
              },
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
}

// --- PART 2: INDIVIDUAL CHAT SCREEN ---
class ChatDetailScreen extends StatelessWidget {
  final String userName;
  final String userImg;
  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userImg,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(radius: 18, backgroundImage: NetworkImage(userImg)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Online",
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
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
                _buildChatHotelCard(), // The missing Hotel Info Card from your design
                const SizedBox(height: 20),
                _bubble(
                  "hi for this hotel with a king sweet room are there still any vacancies?",
                  true,
                  "10:15 AM",
                ),
                _bubble("Hey Dear", false, "10:30 AM"),
                _bubble(
                  "Yes the room is available, so you can make an order.",
                  false,
                  "10:31 AM",
                ),
              ],
            ),
          ),
          _buildReplyBar(),
        ],
      ),
    );
  }

  // --- MISSING UI: Hotel Info Card at Top of Chat ---
  Widget _buildChatHotelCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SafeNetworkImage(
              url: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=200&q=80',
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The Aston Vill Hotel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Veum Point, Michikoton",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "\$120 /night",
                  style: TextStyle(
                    color: Color(0xFF3056D3),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const Text(" 4.7", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bubble(String text, bool isMe, String time) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
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
            child: Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // --- MISSING UI: Reply bar with proper styling ---
  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Write a reply",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.sentiment_satisfied_alt),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            backgroundColor: Color(0xFF3056D3),
            child: Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
