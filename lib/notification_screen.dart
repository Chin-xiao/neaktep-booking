import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      'title': 'Special Offer!',
      'message': 'Get 20% off on your next booking at luxury hotels',
      'icon': Icons.local_offer,
      'color': Colors.orange,
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking for The Aston Vill Hotel is confirmed',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'time': '5 hours ago',
      'isRead': false,
    },
    {
      'title': 'New Message',
      'message': 'You have a new message from the hotel staff',
      'icon': Icons.message,
      'color': Colors.blue,
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'title': 'Payment Successful',
      'message': 'Your payment of \$120 has been processed successfully',
      'icon': Icons.payment,
      'color': Colors.purple,
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'title': 'Review Reminder',
      'message': 'Please rate your recent stay at Mystic Palms Resort',
      'icon': Icons.star,
      'color': Colors.amber,
      'time': '3 days ago',
      'isRead': true,
    },
  ];

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
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF3056D3)),
            onPressed: _markAllAsRead,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationCard(notifications[index], index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        const Text(
          "No Notifications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          "You're all caught up!",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) => GestureDetector(
    onTap: () => _markAsRead(index),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification['isRead']
            ? Colors.white
            : notification['color'].withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification['isRead']
              ? Colors.grey.shade200
              : notification['color'].withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification['color'].withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification['icon'], color: notification['color'], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification['isRead'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () => _deleteNotification(index),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notification['time'],
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    ),
  );

  void _markAsRead(int index) {
    setState(() {
      notifications[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Notification deleted"),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // Undo logic can be added here
          },
        ),
      ),
    );
  }
}
