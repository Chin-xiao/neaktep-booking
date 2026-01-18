import 'package:flutter/material.dart';

import '../components/review_tile.dart';
import '../components/safe_network_image.dart';
import '../layout/primary_button.dart';
import '../layout/round_icon_button.dart';
import '../layout/section_header.dart';
import '../routes/app_routes.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../utils/models.dart';

class DetailPage extends StatefulWidget {
  final Hotel hotel;

  const DetailPage({super.key, required this.hotel});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final HotelService _hotelService = HotelService();
  late final Future<Hotel> _detailFuture;
  late final Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _hotelService.fetchHotelDetail(widget.hotel.id);
    _reviewsFuture = _hotelService.fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Hotel>(
      future: _detailFuture,
      builder: (context, snapshot) {
        final hotel = snapshot.data ?? widget.hotel;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [_buildHeroImage(hotel), _buildDetailCard(hotel)],
                ),
              ),
              _buildTopBar(context),
              if (isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    minHeight: 2,
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _buildBookingBar(hotel),
        );
      },
    );
  }

  Widget _buildHeroImage(Hotel hotel) {
    return Hero(
      tag: 'hotel-${hotel.id}',
      child: SafeNetworkImage(
        url: hotel.imageUrl,
        height: 280,
        width: double.infinity,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            RoundIconButton(
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
              backgroundColor: AppColors.surface.withOpacity(0.9),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Detail',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ),
            ),
            RoundIconButton(
              icon: Icons.more_horiz,
              onPressed: () {},
              backgroundColor: AppColors.surface.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(Hotel hotel) {
    final recommendations = demoHotels
        .where((h) => h.id != hotel.id)
        .take(4)
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.near_me, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        hotel.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Common Facilities',
            actionLabel: 'See All',
            onAction: () => Navigator.of(context).push(
              AppRoutes.toFacilities(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: hotel.facilities
                .take(4)
                .map((facility) => _buildFacilityItem(facility))
                .toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: hotel.description,
              style: const TextStyle(color: AppColors.textMuted, height: 1.5),
              children: const [
                TextSpan(
                  text: ' Read More',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(
            title: 'Location',
            actionLabel: 'Open Map',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SafeNetworkImage(
              url: hotel.mapImageUrl,
              height: 130,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_pin,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hotel.location,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildReviewSection(),
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Recommendation',
            actionLabel: 'See All',
            onAction: () {},
          ),
          const SizedBox(height: 12),
          _buildRecommendationList(recommendations),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(String facility) {
    return SizedBox(
      width: 74,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(facilityIcon(facility), color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            facility,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingBar(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                Text(
                  '\$${hotel.price}.00',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                label: 'Booking Now',
                onPressed: () {},
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Reviews',
          actionLabel: 'See All',
          onAction: () => Navigator.of(context).push(AppRoutes.toReviews()),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(
                  color: AppColors.primary,
                  minHeight: 4,
                ),
              );
            }
            final reviews = snapshot.data ?? [];
            final preview = reviews.take(2).toList();
            if (preview.isEmpty) {
              return const Text(
                'No reviews yet.',
                style: TextStyle(color: AppColors.textMuted),
              );
            }
            return Column(
              children: [
                ...preview.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ReviewTile(review: review, dense: true),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecommendationList(List<Hotel> hotels) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hotels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = hotels[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(AppRoutes.toDetail(item)),
                    child: Container(
              width: 220,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'hotel-${item.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SafeNetworkImage(
                        url: item.imageUrl,
                        width: 64,
                        height: 64,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            Expanded(
                              child: Text(
                                item.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '\$${item.price}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/night',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
