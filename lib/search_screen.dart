import 'package:flutter/material.dart';
import 'all_notifications_screen.dart' show AllNotificationsScreen;
import '../components/safe_network_image.dart';
import '../services/hotel_service.dart';
import '../utils/models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HotelService _hotelService = HotelService();
  final TextEditingController _searchController = TextEditingController();

  // --- Data State ---
  List<Hotel> _hotels = [];
  bool _isLoading = true;

  // --- Filter States ---
  RangeValues _priceRange = const RangeValues(0, 500);
  String _selectedLocation = "Sen Sok";
  int _selectedRating = 4;
  final Map<String, bool> _facilities = {
    "Wifi": false,
    "Pool": false,
    "Tv": false,
    "Laundry": false,
  };

  @override
  void initState() {
    super.initState();
    // ✅ Load default data immediately when screen opens
    _fetchHotels();
  }

  /// ✅ The core logic to fetch data from your API
  Future<void> _fetchHotels() async {
    setState(() => _isLoading = true);

    // Convert Map of facilities to a List of names for the API
    List<String> selectedFacilities = _facilities.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final results = await _hotelService.searchHotels(
      query: _searchController.text,
      minPrice: _priceRange.start,
      maxPrice: _priceRange.end,
      rating: _selectedRating,
      location: _selectedLocation,
      facilities: selectedFacilities,
    );

    if (mounted) {
      setState(() {
        _hotels = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllNotificationsScreen()),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 20),
          
          // --- Dynamic Results Section ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF3056D3)))
                : _hotels.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _hotels.length,
                        itemBuilder: (context, index) {
                          final hotel = _hotels[index];
                          return _buildLargeSearchCard(hotel);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _fetchHotels(), // ✅ Search when pressing 'Enter'
                decoration: const InputDecoration(
                  hintText: "Search hotel...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF3056D3)),
              onPressed: () => _showFilterModal(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 20),
                    const Center(child: Text("Filter By", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 25),
                    
                    Text("Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    RangeSlider(
                      values: _priceRange,
                      max: 2000,
                      activeColor: const Color(0xFF3056D3),
                      onChanged: (val) => setModalState(() => _priceRange = val),
                    ),
                    
                    const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 10,
                      children: ["Sen Sok", "Daun Penh", "Phnom Penh"].map((loc) {
                        bool isSel = _selectedLocation == loc;
                        return ChoiceChip(
                          label: Text(loc),
                          selected: isSel,
                          selectedColor: const Color(0xFF3056D3),
                          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black),
                          onSelected: (_) => setModalState(() => _selectedLocation = loc),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._facilities.keys.map((f) => CheckboxListTile(
                      title: Text(f),
                      value: _facilities[f],
                      activeColor: const Color(0xFF3056D3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setModalState(() => _facilities[f] = val!),
                    )),
                    
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3056D3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _fetchHotels(); // ✅ Re-fetch with new filters
                        },
                        child: const Text("Apply Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLargeSearchCard(Hotel hotel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SafeNetworkImage(
            url: hotel.image,
            height: 200,
            width: double.infinity,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text("\$${hotel.price}", style: const TextStyle(color: Color(0xFF3056D3), fontWeight: FontWeight.bold)),
          ],
        ),
        Text(hotel.location, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No hotels found matching your search.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}