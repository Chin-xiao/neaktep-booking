import 'package:flutter/material.dart';
import '../services/hotel_service.dart';
import '../utils/models.dart';
import 'notification_detail_screen.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({super.key});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  final HotelService _hotelService = HotelService();
  String _selectedFilter = 'All';

  // Key to force refresh the FutureBuilder
  Key _refreshKey = UniqueKey();

  void _refreshNotifications() {
    setState(() {
      _refreshKey = UniqueKey();
    });
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Color(0xFF3056D3)),
            onPressed: () {
              // You can implement a "Mark all as read" API call here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
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
          
          // Notifications List via API
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refreshNotifications(),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                key: _refreshKey,
                future: _hotelService.fetchNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }

                  final allNotifications = snapshot.data ?? [];
                  final filtered = _applyFilter(allNotifications);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(filtered[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> list) {
    if (_selectedFilter == 'Unread') {
      return list.where((n) => n['is_read'] == 0 || n['is_read'] == false).toList();
    } else if (_selectedFilter == 'Read') {
      return list.where((n) => n['is_read'] == 1 || n['is_read'] == true).toList();
    }
    return list;
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3056D3) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n) {
    final bool isRead = n['is_read'] == 1 || n['is_read'] == true;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFF3056D3).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3056D3).withOpacity(0.1),
          child: const Icon(Icons.notifications, color: Color(0xFF3056D3)),
        ),
        title: Text(
          n['title'] ?? 'Notification',
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(n['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(
              n['created_at_human'] ?? 'Just now',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(
                // If the backend sent a booking object, convert it. Otherwise null.
                booking: n['booking'] != null ? Booking.fromJson(n['booking']) : null,
                title: n['title'],
                message: n['message'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Wrap in ListView to enable pull-to-refresh
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        const Icon(Icons.notifications_none, size: 80, color: Colors.grey),
        const Center(child: Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Failed to load notifications"),
          TextButton(onPressed: _refreshNotifications, child: const Text("Try Again")),
        ],
      ),
    );
  }
}