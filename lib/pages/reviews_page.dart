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
      floatingActionButton: widget.hotelId != null
          ? FloatingActionButton(
              onPressed: () => _showAddReviewDialog(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
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
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                // ✅ FIXED: Null and error safety check before rendering the card
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
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
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
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
                        const Icon(
                          Icons.sort,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Renders the review list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 32),
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

  void _showAddReviewDialog(BuildContext context) {
    double selectedRating = 5.0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(
            'Write a Review',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate this hotel',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starRating = index + 1;
                    return IconButton(
                      onPressed: () => setState(
                        () => selectedRating = starRating.toDouble(),
                      ),
                      icon: Icon(
                        starRating <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                        size: 32,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Share your experience',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tell others about your stay...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (commentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please write a comment'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final result = await _hotelService.submitReview(
                          hotelId: widget.hotelId!,
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                        );

                        if (mounted) {
                          Navigator.pop(dialogContext);

                          if (result['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Review submitted successfully!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Refresh reviews
                            setState(() {
                              _initData();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ??
                                      'Failed to submit review',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isSubmitting ? 'Submitting...' : 'Submit Review'),
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
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
