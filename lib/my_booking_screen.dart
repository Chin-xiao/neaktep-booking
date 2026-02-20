import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'notification_detail_screen.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool isBookedSelected = true;
  late Future<List<dynamic>> _bookingsFuture;
  final ApiService _apiService = ApiService();
  String _searchQuery = "";
  Timer? _timer;
  List<int> _hiddenBookingIds = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadBookings() {
    setState(() {
      _bookingsFuture = _apiService.fetchMyBookings();
    });
  }

  String _getTimeLeft(String createdAt) {
    try {
      DateTime createdTime = DateTime.parse(createdAt);
      DateTime expiryTime = createdTime.add(const Duration(minutes: 30));
      Duration diff = expiryTime.difference(DateTime.now());
      if (diff.isNegative) return "00:00";
      return "${diff.inMinutes.remainder(60).toString().padLeft(2, '0')}:${diff.inSeconds.remainder(60).toString().padLeft(2, '0')}";
    } catch (e) {
      return "00:00";
    }
  }

  // --- ACTIONS ---
  Future<void> _handleConfirm(dynamic bookingId) async {
    bool? confirm = await _showConfirmDialog("Confirm Trip?", "Once confirmed, we'll notify the hotel to prepare for your arrival.");
    if (confirm == true) {
      _showLoading();
      bool success = await _apiService.updateBookingStatus(bookingId, 'booked');
      if (mounted) Navigator.pop(context);
      if (success) {
        _loadBookings();
        _showSnackBar("Trip Confirmed!", Colors.green);
      }
    }
  }

  Future<void> _handleCancel(dynamic bookingId) async {
    bool? confirm = await _showConfirmDialog("Cancel Trip?", "Are you sure you want to cancel this reservation?");
    if (confirm == true) {
      _showLoading();
      bool success = await _apiService.cancelBooking(bookingId);
      if (mounted) Navigator.pop(context);
      if (success) {
        _loadBookings();
        _showSnackBar("Trip Cancelled", Colors.orange);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildModernSearchBar(),
                _buildSegmentedControl(),
              ],
            ),
          ),
          _buildBookingList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Text("My Trips", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
      ),
      actions: [
        if (!isBookedSelected && _hiddenBookingIds.isNotEmpty)
          IconButton(
            onPressed: () => setState(() => _hiddenBookingIds.clear()),
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
          ),
      ],
    );
  }

  Widget _buildModernSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: const InputDecoration(
            hintText: "Search destinations...",
            prefixIcon: Icon(Icons.search, color: Colors.black45),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            _segmentItem("Active", isBookedSelected, () => setState(() => isBookedSelected = true)),
            _segmentItem("History", !isBookedSelected, () => setState(() => isBookedSelected = false)),
          ],
        ),
      ),
    );
  }

  Widget _segmentItem(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : [],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? Colors.black : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return FutureBuilder<List<dynamic>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        }
        final all = snapshot.data ?? [];
        final filtered = all.where((b) {
          if (_hiddenBookingIds.contains(b['id'])) return false;
          final s = b['status']?.toString().toLowerCase() ?? 'pending';
          final name = b['hotel']['name'].toString().toLowerCase();
          bool matchesTab = isBookedSelected 
              ? (s == 'pending' || s == 'booked' || s == 'confirmed') 
              : (s == 'cancelled' || s == 'completed');
          return matchesTab && name.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filtered.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildEliteCard(filtered[index]),
              childCount: filtered.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEliteCard(dynamic booking) {
    final hotel = booking['hotel'] ?? {};
    final String status = (booking['status'] ?? "pending").toString().toLowerCase();
    final bool isPending = status == 'pending';
    final String timeLeft = _getTimeLeft(booking['created_at'] ?? DateTime.now().toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(hotel['image_url'] ?? "", height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(top: 15, left: 15, child: _statusBadge(status)),
              if (isPending && timeLeft != "00:00")
                Positioned(
                  top: 15, right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(timeLeft, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(hotel['name'] ?? "Hotel", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5))),
                    Text("\$${booking['total_price']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (isPending)
                      Expanded(child: _actionBtn("Confirm", Colors.blueAccent, Colors.white, () => _handleConfirm(booking['id']))),
                    if (isPending) const SizedBox(width: 10),
                    Expanded(
                      child: _actionBtn("Invoice", Colors.grey[100]!, Colors.black87, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationDetailScreen(booking: booking)));
                      }),
                    ),
                    if (!isBookedSelected)
                      IconButton(onPressed: () => setState(() => _hiddenBookingIds.add(booking['id'])), icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ],
                ),
                if (isPending)
                  Center(
                    child: TextButton(
                      onPressed: () => _handleCancel(booking['id']),
                      child: const Text("Cancel Reservation", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color bg, Color text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
        child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Widget _statusBadge(String s) {
    Color c = s == 'pending' ? Colors.orange : (s == 'cancelled' ? Colors.red : Colors.green);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Text(s.toUpperCase(), style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplane_ticket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No trips found", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- UTILS ---
  void _showLoading() => showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
  
  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
  }

  Future<bool?> _showConfirmDialog(String t, String c) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t), content: Text(c),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Go Back")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes, Proceed")),
        ],
      ),
    );
  }
}