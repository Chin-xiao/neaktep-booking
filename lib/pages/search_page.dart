import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Ensure these paths match your project structure
import '../utils/app_colors.dart';
import '../utils/models.dart';
import '../routes/app_routes.dart';
import '../components/safe_network_image.dart';

// --- 1. HOTEL SERVICE ---
class HotelService {
  static const String baseUrl = "https://foods-tunes-vessel-leasing.trycloudflare.com/api";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Hotel>> searchHotels({
    String? query,
    double? minPrice,
    double? maxPrice,
    int? rating,
    List<String>? facilities,
    String? location,
  }) async {
    try {
      final Map<String, String> params = {};
      if (query != null && query.isNotEmpty) params['search'] = query;
      if (minPrice != null && minPrice > 0) params['min_price'] = minPrice.toString();
      if (maxPrice != null && maxPrice < 5000) params['max_price'] = maxPrice.toString();
      if (rating != null && rating > 0) params['rating'] = rating.toString();
      if (location != null && location.isNotEmpty) params['location'] = location;

      final uri = Uri.parse('$baseUrl/hotels/search').replace(queryParameters: params);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> hotelsJson = (decoded is Map && decoded.containsKey('data')) 
            ? decoded['data'] 
            : (decoded is List ? decoded : []);
        return hotelsJson.map((json) => Hotel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Search Service Error: $e');
      return [];
    }
  }
}

// --- 2. SEARCH PAGE UI ---
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HotelService _hotelService = HotelService();
  late FilterState _filters;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  int _searchToken = 0;

  List<Hotel> _results = const [];
  String _query = '';
  bool _loadingResults = false;

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
    
    if (!mounted || currentToken != _searchToken) return;
    
    setState(() {
      _results = results;
      _loadingResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Discover Stays', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _loadingResults 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _results.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) => _buildHotelCard(_results[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        onChanged: _onQueryChanged,
        decoration: InputDecoration(
          hintText: 'Search destinations...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: AppColors.primary, size: 20),
              onPressed: () async {
                final result = await Navigator.push(context, AppRoutes.toFilter(_filters));
                if (result != null && result is FilterState) {
                  setState(() => _filters = result);
                  _runSearch();
                }
              },
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "No hotels found matching your search.",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        // ✅ Uses the fixed AppRoutes that handles the Hero transition
        onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                // ✅ FIXED: Using 'hotel.image' and SafeNetworkImage
                child: SafeNetworkImage(
                  url: hotel.image, 
                  width: 90, 
                  height: 90,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hotel.location, 
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                        Text(
                          '\$${hotel.price.toStringAsFixed(0)}', 
                          style: const TextStyle(
                            color: AppColors.primary, 
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          )
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              " ${hotel.rating}", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
                            ),
                          ],
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