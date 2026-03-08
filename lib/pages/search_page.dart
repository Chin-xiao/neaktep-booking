import 'dart:async';
import 'package:flutter/material.dart';

// Ensure these paths match your project structure
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';
import '../components/app_input_field.dart';
import '../components/app_widgets.dart';
import '../utils/models.dart';
import '../routes/app_routes.dart';
import '../components/safe_network_image.dart';
import '../services/location_service.dart';
import '../services/hotel_service.dart';

// --- 2. SEARCH PAGE UI ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HotelService _hotelService = HotelService();
  final LocationService _locationService = LocationService();
  late FilterState _filters;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  int _searchToken = 0;

  List<Hotel> _results = const [];
  String _query = '';
  bool _loadingResults = false;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    _filters = FilterState(
      minPrice: 0.0,
      maxPrice: 2000.0,
      location: '',
      selectedFacilities: [],
      rating: 0,
    );
    _runSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _query = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _runSearch);
  }

  Future<void> _runSearch() async {
    debugPrint("🔍 Running search with query: '$_query'");
    if (!mounted) return;
    setState(() => _loadingResults = true);

    final currentToken = ++_searchToken;
    final results = await _hotelService.searchHotels(
      query: _query.trim(),
      minPrice: _filters.minPrice,
      maxPrice: _filters.maxPrice,
      rating: _filters.rating,
      location: _filters.location,
    );

    debugPrint("🔍 Search results: ${results.length} hotels");
    if (!mounted || currentToken != _searchToken) return;

    setState(() {
      _results = results;
      _loadingResults = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      final locationData = await _locationService
          .getCurrentLocationWithAddress();

      if (locationData != null && mounted) {
        setState(() {
          _filters = FilterState(
            minPrice: _filters.minPrice,
            maxPrice: _filters.maxPrice,
            rating: _filters.rating,
            selectedFacilities: _filters.selectedFacilities,
            location: locationData['address'] ?? '',
          );
        });

        // Run search with new location
        _runSearch();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location set to: ${locationData['address']}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get current location. Please check permissions and try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting location. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _gettingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        title: Text(
          'Discover Stays',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
          color: AppColors.textPrimary,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildSearchBar()),
          if (_loadingResults)
            SliverFillRemaining(child: Center(child: LoadingState()))
          else if (_results.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildHotelCard(_results[index], index),
                  childCount: _results.length,
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spacingXl)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              hint: 'Search destinations, hotels...',
              controller: _controller,
              onChanged: _onQueryChanged,
              showFilterIcon: true,
              onFilterTap: () async {
                final result = await Navigator.push(
                  context,
                  AppRoutes.toFilter(_filters),
                );
                if (result != null) {
                  setState(() => _filters = result);
                  _runSearch();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              icon: _gettingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location, color: Colors.white),
              onPressed: _gettingLocation ? null : _getCurrentLocation,
              tooltip: 'Use current location',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.hotel_outlined,
      title: 'No Hotels Found',
      subtitle:
          'Try changing your search criteria or filters to find available stays',
      actionButton: OutlinedButton.icon(
        onPressed: () {
          _controller.clear();
          _query = '';
          _filters = FilterState(
            minPrice: 0.0,
            maxPrice: 2000.0,
            location: '',
            selectedFacilities: [],
            rating: 0,
          );
          _runSearch();
        },
        icon: const Icon(Icons.refresh),
        label: const Text('Reset Search'),
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [AppColors.softShadow],
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: InkWell(
        borderRadius: AppSpacing.borderRadiusLg,
        onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              // Hotel Image
              ClipRRect(
                borderRadius: AppSpacing.borderRadiusLg,
                child: SafeNetworkImage(
                  url: hotel.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Hotel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${hotel.price.toStringAsFixed(0)}',
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'per night',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${hotel.rating}',
                                style: AppTypography.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
