import 'package:flutter/material.dart';

import '../components/rating_summary.dart';
import '../components/review_tile.dart';
import '../layout/round_icon_button.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final HotelService _hotelService = HotelService();
  late final Future<List<Review>> _reviewsFuture;
  late final Future<RatingSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _hotelService.fetchReviews();
    _summaryFuture = _hotelService.fetchRatingSummary();
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
          child: RoundIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Reviews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.more_horiz, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          FutureBuilder<RatingSummary>(
            future: _summaryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    minHeight: 4,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Text(
                  'Unable to load rating summary.',
                  style: TextStyle(color: AppColors.textMuted),
                );
              }
              return RatingSummaryCard(summary: snapshot.data!);
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<Review>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Text(
                  'No reviews yet.',
                  style: TextStyle(color: AppColors.textMuted),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reviews (${reviews.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ReviewTile(review: review),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
