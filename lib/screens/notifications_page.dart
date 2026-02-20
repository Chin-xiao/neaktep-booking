import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  // Static data for a "real" feel
  final List<Map<String, String>> notifications = const [
    {
      "title": "Booking Confirmed",
      "body": "Your stay at NagaWorld is ready! View your receipt in details.",
      "time": "2 mins ago",
      "type": "booking"
    },
    {
      "title": "Payment Successful",
      "body": "We received your receipt for Booking #BK991. Status: Paid.",
      "time": "1 hour ago",
      "type": "payment"
    },
    {
      "title": "Exclusive Offer",
      "body": "Enjoy 10% off your next luxury stay. Valid until next Sunday!",
      "time": "Yesterday",
      "type": "promo"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationCard(item);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getIconColor(item['type']).withOpacity(0.1),
          child: Icon(_getIcon(item['type']), color: _getIconColor(item['type']), size: 20),
        ),
        title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item['body']!, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 8),
            Text(item['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        onTap: () {
          // Add navigation to detail if needed
        },
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'booking': return Icons.hotel;
      case 'payment': return Icons.account_balance_wallet;
      default: return Icons.notifications;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'booking': return Colors.blue;
      case 'payment': return Colors.green;
      default: return Colors.purple;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No notifications yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}