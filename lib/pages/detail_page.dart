import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../utils/models.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';
import '../components/app_button.dart';
import '../components/safe_network_image.dart';
import '../routes/app_routes.dart';
import '../services/hotel_service.dart';
import '../components/review_tile.dart';
import '../components/rating_summary.dart';

// Optimized Google Maps Widget
class HotelMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String hotelName;
  final VoidCallback onMapTap;

  const HotelMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.hotelName,
    required this.onMapTap,
  });

  @override
  State<HotelMapWidget> createState() => _HotelMapWidgetState();
}

class _HotelMapWidgetState extends State<HotelMapWidget> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.latitude == null || widget.longitude == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusMd,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude!, widget.longitude!),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('hotel_${widget.hotelName}'),
                  position: LatLng(widget.latitude!, widget.longitude!),
                  infoWindow: InfoWindow(title: widget.hotelName),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                setState(() => _isMapReady = true);
              },
              onTap: (_) => widget.onMapTap(),
            ),
            // Loading indicator
            if (!_isMapReady)
              Container(
                color: Colors.white,
                child: const Center(child: CircularProgressIndicator()),
              ),
            // Custom Controls Overlay
            if (_isMapReady)
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    // Center on Hotel Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.center_focus_strong,
                          color: AppColors.primary,
                        ),
                        onPressed: _centerOnHotel,
                        tooltip: 'Center on hotel',
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // My Location Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.my_location, color: AppColors.primary),
                        onPressed: _showMyLocation,
                        tooltip: 'Show my location',
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _centerOnHotel() async {
    if (_mapController == null ||
        widget.latitude == null ||
        widget.longitude == null)
      return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.latitude!, widget.longitude!),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _showMyLocation() async {
    if (_mapController == null) return;

    try {
      // Get current location
      final locationService = LocationService();
      final locationData = await locationService
          .getCurrentLocationWithAddress();

      if (locationData != null &&
          locationData['latitude'] != null &&
          locationData['longitude'] != null) {
        final userLat = locationData['latitude'] as double;
        final userLng = locationData['longitude'] as double;

        // Animate to user's location
        await _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(userLat, userLng), zoom: 15),
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Showing your location: ${locationData['address'] ?? 'Unknown'}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to get your current location'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: AppColors.surface,
      elevation: 2,
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final HotelService _hotelService = HotelService();
  late Future<List<Review>> _reviewsFuture;
  late Future<RatingSummary?> _ratingSummaryFuture;

  Hotel get hotel => widget.hotel;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _hotelService.fetchReviews(
      hotelId: widget.hotel.id.toString(),
    );
    _ratingSummaryFuture = _hotelService.fetchRatingSummary(
      hotelId: widget.hotel.id.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      SizedBox(height: AppSpacing.spacingLg),
                      _buildQuickInfoChips(),
                      SizedBox(height: AppSpacing.spacingLg),
                      _buildDescriptionCard(),
                      SizedBox(height: AppSpacing.spacingLg),
                      _buildFacilitiesSection(),
                      SizedBox(height: AppSpacing.spacingLg),
                      _buildAmenitiesHighlight(),
                      SizedBox(height: AppSpacing.spacingLg),
                      if (widget.hotel.rooms.isNotEmpty) ...[
                        _buildRoomList(),
                        SizedBox(height: AppSpacing.spacingLg),
                      ],
                      _buildReviewsSection(),
                      SizedBox(height: AppSpacing.spacingLg),
                      _buildLocationSection(),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBookingBar(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            SafeNetworkImage(
              url: widget.hotel.image,
              height: 380,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black26],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hotel.name,
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildRatingBadge(),
          ],
        ),
        SizedBox(height: AppSpacing.spacingXs),
        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 4),
            Text(
              hotel.location,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppColors.warning, size: 18),
          const SizedBox(width: 4),
          Text(
            hotel.rating.toString(),
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoChips() {
    return const Wrap(
      spacing: 12.0,
      children: [
        _InfoChip(icon: Icons.wifi, label: 'WiFi'),
        _InfoChip(icon: Icons.local_parking, label: 'Parking'),
        _InfoChip(icon: Icons.coffee, label: 'Café'),
        _InfoChip(icon: Icons.pool, label: 'Pool'),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      backgroundColor: AppColors.surface,
      elevation: 2,
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [AppColors.softShadow],
      ),
      child: Text(
        hotel.description,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpacing.spacingMd),
        Wrap(
          runSpacing: AppSpacing.spacingMd,
          spacing: AppSpacing.spacingMd,
          children: hotel.facilities.map((f) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getFacilityIcon(f), size: 28, color: AppColors.primary),
                SizedBox(height: 4),
                Text(
                  f,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getFacilityIcon(String name) {
    switch (name.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'café':
      case 'cafe':
        return Icons.local_cafe;
      case 'pool':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildAmenitiesHighlight() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: AppColors.cardShadow,
      ),
      child: Text(
        'Enjoy complimentary breakfast, free cancellation, and 24/7 support!',
        style: AppTypography.bodySmall.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRoomList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hotel.rooms.map((room) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusLg,
            boxShadow: [AppColors.softShadow],
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacingXs),
                    Text(
                      '${room.bedCount} Bed • ${room.bathroomCount} Bath',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${room.price.toStringAsFixed(0)}',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews & Ratings',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                AppRoutes.toReviews(hotelId: widget.hotel.id.toString()),
              ),
              child: Text(
                'View All',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.spacingMd),

        // Rating Summary
        FutureBuilder<RatingSummary?>(
          future: _ratingSummaryFuture,
          builder: (context, summarySnapshot) {
            if (summarySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final summary = summarySnapshot.data;
            if (summary != null && summary.totalReviews > 0) {
              return RatingSummaryCard(summary: summary);
            }

            return Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppColors.warning, size: 24),
                  SizedBox(width: AppSpacing.spacingSm),
                  Text(
                    '${widget.hotel.rating.toStringAsFixed(1)} (${widget.hotel.rating > 0 ? "Based on hotel data" : "No ratings yet"})',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(height: AppSpacing.spacingMd),

        // Reviews List
        FutureBuilder<List<Review>>(
          future: _reviewsFuture,
          builder: (context, reviewsSnapshot) {
            if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = reviewsSnapshot.data ?? [];
            if (reviews.isEmpty) {
              return Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.reviews_outlined,
                      color: AppColors.textMuted,
                      size: 48,
                    ),
                    SizedBox(height: AppSpacing.spacingSm),
                    Text(
                      'No reviews yet',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: AppSpacing.spacingSm),
                    AppElevatedButton(
                      label: 'Write a Review',
                      onPressed: () => _showAddReviewDialog(),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                ...reviews
                    .take(3)
                    .map(
                      (review) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.spacingMd),
                        child: ReviewTile(review: review),
                      ),
                    ),
                if (reviews.length > 3) ...[
                  SizedBox(height: AppSpacing.spacingSm),
                  AppElevatedButton(
                    label: 'View All ${reviews.length} Reviews',
                    onPressed: () => Navigator.push(
                      context,
                      AppRoutes.toReviews(hotelId: widget.hotel.id.toString()),
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.spacingMd),
                AppElevatedButton(
                  label: 'Write a Review',
                  onPressed: () => _showAddReviewDialog(),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showAddReviewDialog() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Write a Review',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate this hotel',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.spacingSm),
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
                SizedBox(height: AppSpacing.spacingMd),
                Text(
                  'Share your experience',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.spacingSm),
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
            AppElevatedButton(
              label: isSubmitting ? 'Submitting...' : 'Submit Review',
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
                          hotelId: widget.hotel.id.toString(),
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
                              _reviewsFuture = _hotelService.fetchReviews(
                                hotelId: widget.hotel.id.toString(),
                              );
                              _ratingSummaryFuture = _hotelService
                                  .fetchRatingSummary(
                                    hotelId: widget.hotel.id.toString(),
                                  );
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInMaps() async {
    if (hotel.latitude == null || hotel.longitude == null) return;

    final url =
        'https://www.google.com/maps/search/?api=1&query=${hotel.latitude},${hotel.longitude}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback: try to open in browser
      final fallbackUrl =
          'https://maps.google.com/maps?q=${hotel.latitude},${hotel.longitude}';
      if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open maps application'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Location',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (hotel.latitude != null && hotel.longitude != null)
              TextButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.map, size: 18),
                label: const Text('View on Map'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.spacingMd),
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppSpacing.borderRadiusLg,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: AppSpacing.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.location,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hotel.latitude != null && hotel.longitude != null) ...[
                SizedBox(height: AppSpacing.spacingMd),
                HotelMapWidget(
                  latitude: hotel.latitude,
                  longitude: hotel.longitude,
                  hotelName: hotel.name,
                  onMapTap: _openInMaps,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBookingBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [AppColors.softShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'From',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    '\$${hotel.price.toStringAsFixed(0)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AppElevatedButton(
              label: 'Book Now',
              onPressed: () =>
                  Navigator.push(context, AppRoutes.toBookingSummary(hotel)),
            ),
          ],
        ),
      ),
    );
  }
}
