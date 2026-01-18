import 'package:flutter/material.dart';
import 'notification_detail_screen.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({super.key});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  // Sample notifications data
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking for Serenity Sands has been confirmed!',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'timestamp': '5 minutes ago',
      'detailedDescription':
          'Your booking for Serenity Sands Resort has been successfully confirmed. Check-in date: January 25, 2026. Check-out date: January 28, 2026. Booking ID: #BS2026001',
      'isRead': false,
    },
    {
      'title': 'Special Offer',
      'message': 'Get 20% off on selected villas this week',
      'icon': Icons.local_offer,
      'iconColor': Colors.orange,
      'timestamp': '2 hours ago',
      'detailedDescription':
          'Limited time offer! Enjoy 20% discount on all premium villa bookings this week. Use promo code: VILLA20. Offer valid until January 24, 2026.',
      'isRead': false,
    },
    {
      'title': 'New Message',
      'message': 'You have a new message from Phnom Penh Hotel',
      'icon': Icons.mail,
      'iconColor': Colors.blue,
      'timestamp': '1 day ago',
      'detailedDescription':
          'Phnom Penh Hotel has sent you a message regarding your upcoming reservation. They have special amenities available for your stay.',
      'isRead': true,
    },
    {
      'title': 'Review Request',
      'message': 'How was your stay? Please leave a review',
      'icon': Icons.star,
      'iconColor': Colors.amber,
      'timestamp': '3 days ago',
      'detailedDescription':
          'We hope you enjoyed your recent stay at Ocean View Resort. Your feedback helps us improve our services. Please take a moment to rate your experience.',
      'isRead': true,
    },
    {
      'title': 'Payment Received',
      'message': 'Payment of \$450 has been received successfully',
      'icon': Icons.payment,
      'iconColor': Colors.green,
      'timestamp': '5 days ago',
      'detailedDescription':
          'Your payment of \$450 for booking #BS2026001 has been successfully processed. Thank you for choosing our service!',
      'isRead': true,
    },
    {
      'title': 'Booking Reminder',
      'message': 'Your check-in is tomorrow at Serenity Sands',
      'icon': Icons.event,
      'iconColor': Colors.purple,
      'timestamp': '1 week ago',
      'detailedDescription':
          'This is a friendly reminder that your check-in at Serenity Sands Resort is scheduled for tomorrow, January 25, 2026 at 2:00 PM.',
      'isRead': true,
    },
  ];

  String _selectedFilter = 'All';

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'Unread') {
      return _notifications.where((n) => !n['isRead']).toList();
    } else if (_selectedFilter == 'Read') {
      return _notifications.where((n) => n['isRead']).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF3056D3)),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Unread'),
                const SizedBox(width: 8),
                _buildFilterChip('Read'),
              ],
            ),
          ),
          
          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final unreadCount = _notifications.where((n) => !n['isRead']).length;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3056D3) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (label == 'Unread' && unreadCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : const Color(0xFF3056D3),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unreadCount',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF3056D3) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFF3056D3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : const Color(0xFF3056D3).withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(
                  title: notification['title'],
                  message: notification['message'],
                  icon: notification['icon'],
                  iconColor: notification['iconColor'],
                  timestamp: notification['timestamp'],
                  detailedDescription: notification['detailedDescription'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (notification['iconColor'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['iconColor'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF3056D3),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            notification['timestamp'],
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
