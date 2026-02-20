import 'package:flutter/material.dart';
import '../components/rating_summary.dart'; 
import '../components/review_tile.dart';
import '../layout/round_icon_button.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class ReviewsPage extends StatefulWidget {
  final String? hotelId;
  const ReviewsPage({super.key, this.hotelId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final HotelService _hotelService = HotelService();
  
  late Future<List<Review>> _reviewsFuture;
  late Future<RatingSummary?> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // These calls use the service methods defined in hotel_service.dart
    _reviewsFuture = _hotelService.fetchReviews(hotelId: widget.hotelId);
    _summaryFuture = _hotelService.fetchRatingSummary(hotelId: widget.hotelId);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _initData();
    });
    // Waits for both backend calls to finish
    await Future.wait([_reviewsFuture, _summaryFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: RoundIconButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Guest Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _handleRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), 
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            // --- 1. Rating Summary Section ---
            FutureBuilder<RatingSummary?>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                
                // ✅ FIXED: Null and error safety check before rendering the card
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink(); 
                }
                
                // Passes the valid RatingSummary object to the component
                return RatingSummaryCard(summary: snapshot.data!);
              },
            ),
            
            const SizedBox(height: 32),
            
            // --- 2. Reviews List Section ---
            FutureBuilder<List<Review>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                
                final reviews = snapshot.data ?? [];
                
                if (reviews.isEmpty) {
                  return _buildEmptyState();
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Reviews (${reviews.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(Icons.sort, size: 20, color: AppColors.textMuted),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Renders the review list
                    ListView.separated(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        return ReviewTile(review: reviews[index]);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet.', 
            style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to share your experience!', 
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}