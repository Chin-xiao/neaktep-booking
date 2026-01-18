import 'dart:async';

import 'package:flutter/material.dart';

import '../components/safe_network_image.dart';
import '../layout/round_icon_button.dart';
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

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  int _searchToken = 0;

  List<RecentSearchItem> _recentSearches = const [];
  List<Hotel> _recentlyViewed = const [];
  List<Hotel> _results = const [];
  String _query = '';
  bool _loadingResults = true;

  @override
  void initState() {
    super.initState();
    _defaultFilters = FilterState.initial();
    _filters = _defaultFilters;
    _dataFuture = _hotelService.fetchSearchPageData().then((data) {
      _recentSearches = data.recentSearches;
      _recentlyViewed = data.recentlyViewed;
      return data;
    });
    _runSearch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters => !_filters.matches(_defaultFilters);

  Future<void> _openFilters() async {
    final FilterState? result = await Navigator.of(
      context,
    ).push<FilterState>(AppRoutes.toFilter(_filters));
    if (result != null) {
      setState(() => _filters = result);
      _runSearch();
    }
  }

  void _onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), _runSearch);
  }

  Future<void> _runSearch() async {
    setState(() => _loadingResults = true);
    final token = ++_searchToken;
    final results = await _hotelService.searchHotels(
      query: _query,
      filters: _filters,
    );
    if (!mounted || token != _searchToken) return;
    setState(() {
      _results = results;
      _loadingResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      body: FutureBuilder<SearchPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          final hasError = snapshot.hasError;
          final loadingData =
              snapshot.connectionState == ConnectionState.waiting;
          return Column(
            children: [
              const SizedBox(height: 8),
              _buildSearchBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (hasError)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Unable to load saved searches.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    _buildSectionHeader(
                      title: 'Recent Searches',
                      actionLabel: _recentSearches.isNotEmpty
                          ? 'Clear All'
                          : null,
                      onAction: _recentSearches.isNotEmpty
                          ? () => setState(() => _recentSearches = const [])
                          : null,
                    ),
                    const SizedBox(height: 8),
                    if (loadingData)
                      _buildShimmerPlaceholder()
                    else if (_recentSearches.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No recent searches yet.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      ..._buildRecentSearchList(_recentSearches),
                    const SizedBox(height: 18),
                    _buildSectionHeader(
                      title: 'Recently Viewed',
                      actionLabel: 'See All',
                      onAction: () {},
                    ),
                    const SizedBox(height: 10),
                    if (loadingData)
                      _buildShimmerPlaceholder()
                    else
                      ..._recentlyViewed.map(_buildHotelCard),
                    const SizedBox(height: 18),
                    _buildSectionHeader(
                      title: 'Results',
                      actionLabel: _loadingResults
                          ? null
                          : '${_results.length} found',
                    ),
                    const SizedBox(height: 10),
                    if (_loadingResults)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.6,
                          ),
                        ),
                      )
                    else if (_results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No stays match your search. Try adjusting filters.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      ..._results.map(_buildHotelCard),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: RoundIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Search',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RoundIconButton(icon: Icons.notifications_none, onPressed: () {}),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textMuted, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                onSubmitted: (_) => _runSearch(),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  isCollapsed: true,
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
                    top: -1,
                    right: -1,
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

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: TextStyle(
                color: actionLabel == 'Clear All'
                    ? AppColors.accent
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget _buildRecentSearchItem(RecentSearchItem item) {
    return InkWell(
      onTap: () {
        _controller.text = item.title;
        _onQueryChanged(item.title);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRecentSearchList(List<RecentSearchItem> items) {
    final widgets = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      widgets.add(_buildRecentSearchItem(items[i]));
      if (i != items.length - 1) {
        widgets.add(const Divider(height: 1));
      }
    }
    return widgets;
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'hotel-${hotel.id}',
              child: SafeNetworkImage(
                url: hotel.imageUrl,
                width: 78,
                height: 78,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                  const SizedBox(height: 4),
                  Text(
                    hotel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
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
