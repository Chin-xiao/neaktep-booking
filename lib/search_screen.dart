import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Values for the Filter Logic
  RangeValues _priceRange = const RangeValues(50, 250);
  bool _isWifiSelected = true;
  bool _isPoolSelected = false;
  String _selectedLocation = "Sen Sok";

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
        title: const Text("Search", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          _buildNotificationIcon(),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchBar(context),
          ),
          const SizedBox(height: 20),
          _buildCategoryTabs(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSearchResultCard(
                  "Citadines Flatiron Phnom Penh",
                  "Street 102, Phnom Penh City Centre",
                  "\$290",
                  4.9,
                  "3 bed",
                  "2 bathroom",
                  "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800",
                ),
                _buildSearchResultCard(
                  "Sensory Park Urban Hotel",
                  "32 Samdach Louis Em St. (282)",
                  "\$180",
                  4.9,
                  "2 bed",
                  "3 bathroom",
                  "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Search Bar with Filter Trigger ---
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search hotel...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF3056D3)),
            onPressed: () => _showFilterModal(context),
          ),
        ],
      ),
    );
  }

  // --- Results Card matching Pic 3 ---
  Widget _buildSearchResultCard(String name, String loc, String price, double rate, String bed, String bath, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(img, height: 220, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 15, left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" $rate", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const Positioned(
                top: 15, right: 15,
                child: CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.favorite_border, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3056D3))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Text("Per Night", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.king_bed_outlined, color: Colors.grey, size: 18),
              Text(" $bed  •  ", style: const TextStyle(color: Colors.grey)),
              const Icon(Icons.bathtub_outlined, color: Colors.grey, size: 18),
              Text(" $bath", style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  // --- THE FILTER MODAL (Matches Pic 4) ---
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return StatefulBuilder( // Important: Allows UI to update inside Modal
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 20),
                  const Center(child: Text("Filter By", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("\$${_priceRange.start.round()} - \$${_priceRange.end.round()}", style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    max: 1000,
                    activeColor: const Color(0xFF3056D3),
                    onChanged: (values) => setModalState(() => _priceRange = values),
                  ),

                  const SizedBox(height: 20),
                  const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: ["Sen Sok", "Daun Penh", "Phnom Penh"].map((loc) {
                      return ChoiceChip(
                        label: Text(loc),
                        selected: _selectedLocation == loc,
                        selectedColor: const Color(0xFF3056D3),
                        labelStyle: TextStyle(color: _selectedLocation == loc ? Colors.white : Colors.black),
                        onSelected: (val) => setModalState(() => _selectedLocation = loc),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  CheckboxListTile(
                    title: const Text("Free Wifi"),
                    value: _isWifiSelected,
                    onChanged: (val) => setModalState(() => _isWifiSelected = val!),
                  ),
                  CheckboxListTile(
                    title: const Text("Swimming Pool"),
                    value: _isPoolSelected,
                    onChanged: (val) => setModalState(() => _isPoolSelected = val!),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3056D3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        setState(() {}); // Apply values to parent SearchScreen
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filter", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // --- Minor Helpers ---
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        children: ["All", "Villas", "Hotels", "Apartments"].map((tab) {
          bool isAll = tab == "All";
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isAll ? const Color(0xFF3056D3) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(tab, style: TextStyle(color: isAll ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
          child: const Icon(Icons.notifications_none, color: Colors.black),
        ),
        const Positioned(right: 8, top: 8, child: CircleAvatar(radius: 5, backgroundColor: Colors.red)),
      ],
    );
  }
}