import 'package:flutter/material.dart';

import '../components/safe_network_image.dart';
import '../layout/round_icon_button.dart';
import '../layout/section_header.dart';
import '../routes/app_routes.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HotelService _hotelService = HotelService();
  late final Future<SearchPageData> _dataFuture;
  late final FilterState _defaultFilters;
  late FilterState _filters;

  @override
  void initState() {
    super.initState();
    _dataFuture = _hotelService.fetchSearchPageData();
    _defaultFilters = FilterState.initial();
    _filters = _defaultFilters;
  }

  bool get _hasActiveFilters => !_filters.matches(_defaultFilters);

  Future<void> _openFilters() async {
    final FilterState? result = await Navigator.of(
      context,
    ).push<FilterState>(AppRoutes.toFilter(_filters));
    if (result != null) {
      setState(() => _filters = result);
    }
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
          padding: const EdgeInsets.only(left: 16),
          child: RoundIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RoundIconButton(
              icon: Icons.notifications_none,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _buildSearchBar(),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<SearchPageData>(
              future: _dataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Unable to load results.'));
                }
                final data = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  children: [
                    SectionHeader(
                      title: 'Recent Searches',
                      actionLabel: 'Clear All',
                      actionColor: AppColors.accent,
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    ..._buildRecentSearchList(data.recentSearches),
                    const SizedBox(height: 12),
                    SectionHeader(
                      title: 'Recently Viewed',
                      actionLabel: 'See All',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    ...data.recentlyViewed.map(_buildRecentlyViewedCard),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textMuted),
            const SizedBox(width: 8),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Stack(
              clipBehavior: Clip.none,
              children: [
                RoundIconButton(
                  icon: Icons.tune,
                  onPressed: _openFilters,
                  backgroundColor: AppColors.background,
                  iconColor: AppColors.primary,
                ),
                if (_hasActiveFilters)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchItem(RecentSearchItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecentSearchList(List<RecentSearchItem> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      widgets.add(_buildRecentSearchItem(items[i]));
      if (i != items.length - 1) {
        widgets.add(const Divider());
      }
    }
    return widgets;
  }

  Widget _buildRecentlyViewedCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'hotel-${hotel.id}',
            child: SafeNetworkImage(
              url: hotel.imageUrl,
              width: 72,
              height: 72,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 6),
                  Text(
                    '\$${hotel.price} /night',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
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
}
