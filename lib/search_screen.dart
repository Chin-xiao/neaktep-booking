import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // These are your actual global filter states
  RangeValues _priceRange = const RangeValues(0, 80);
  bool _instantBook = false;
  String _selectedLocation = "Sen Sok";
  int _selectedRating = 4;
  
  // Facilities Map
  final Map<String, bool> _facilities = {
    "Wifi": false,
    "Pool": true,
    "Tv": false,
    "Laundry": true,
  };

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
        title: const Text("Search", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 20),
          // Category tabs...
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLargeSearchCard("Citadines Flatiron", "Street 102, PP", "\$290", 4.9, "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800"),
              ],
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
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const Expanded(child: TextField(decoration: InputDecoration(hintText: "Search hotel...", border: InputBorder.none))),
            IconButton(
              icon: const Icon(Icons.tune, color: Color(0xFF3056D3)),
              onPressed: () => _showFilterModal(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- FIXED FILTER MODAL ---
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // 1. THIS IS THE KEY: StatefulBuilder makes the modal interactive
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
                    // Price Range
                    Text("Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    RangeSlider(
                      values: _priceRange,
                      max: 500,
                      activeColor: const Color(0xFF3056D3),
                      onChanged: (val) {
                        // 2. Use setModalState to update the slider immediately
                        setModalState(() => _priceRange = val);
                      },
                    ),

                    // Instant Book Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Instant Book", style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _instantBook,
                      activeThumbColor: const Color(0xFF3056D3),
                      onChanged: (val) => setModalState(() => _instantBook = val),
                    ),

                    // Location Chips
                    const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: ["Sen Sok", "Daun Penh", "Phnom Penh"].map((loc) {
                        bool isSel = _selectedLocation == loc;
                        return ChoiceChip(
                          label: Text(loc),
                          selected: isSel,
                          selectedColor: const Color(0xFF3056D3),
                          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black),
                          onSelected: (bool selected) {
                            setModalState(() => _selectedLocation = loc);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    // Facilities Checkboxes
                    const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold)),
                    ..._facilities.keys.map((f) => CheckboxListTile(
                      title: Text(f),
                      value: _facilities[f],
                      activeColor: const Color(0xFF3056D3),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setModalState(() => _facilities[f] = val!),
                    )),

                    const SizedBox(height: 20),
                    // Rating Buttons
                    const Text("Ratings", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [5, 4, 3, 2, 1].map((star) {
                        bool isSel = _selectedRating == star;
                        return GestureDetector(
                          onTap: () => setModalState(() => _selectedRating = star),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? const Color(0xFF3056D3).withValues(alpha: 0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSel ? const Color(0xFF3056D3) : Colors.grey[200]!),
                            ),
                            child: Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(" $star")]),
                          ),
                        );
                      }).toList(),
                    ),

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
                          // 3. Close modal and trigger main UI update
                          setState(() {}); 
                          Navigator.pop(context);
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

  Widget _buildLargeSearchCard(String name, String loc, String price, double rate, String img) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(img, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(price, style: const TextStyle(color: Color(0xFF3056D3), fontWeight: FontWeight.bold)),
          ],
        ),
        Text(loc, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
      ],
    );
  }
}