import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';
import '../services/location_service.dart';

class FilterPage extends StatefulWidget {
  final FilterState initial;

  const FilterPage({super.key, required this.initial});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late double _minPrice;
  late double _maxPrice;
  late int _rating;
  late List<String> _selectedFacilities;
  late String _location;
  final List<String> _allFacilities = ["Wifi", "Pool", "Gym", "Parking", "Spa"];

  final LocationService _locationService = LocationService();
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    // Initialize state from existing filters
    _minPrice = widget.initial.minPrice;
    _maxPrice = widget.initial.maxPrice;
    _rating = widget.initial.rating;
    _selectedFacilities = List.from(widget.initial.selectedFacilities);
    _location = widget.initial.location ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Filters", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              "Reset",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Price Range"),
            const SizedBox(height: 10),
            _buildPriceSlider(),
            const SizedBox(height: 30),

            _sectionTitle("Rating"),
            const SizedBox(height: 10),
            _buildRatingPicker(),
            const SizedBox(height: 30),

            _sectionTitle("Location"),
            const SizedBox(height: 10),
            _buildLocationPicker(),
            const SizedBox(height: 30),

            _sectionTitle("Facilities"),
            const SizedBox(height: 10),
            _buildFacilitiesChipGrid(),
          ],
        ),
      ),
      bottomNavigationBar: _buildApplyButton(),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 2000,
          divisions: 20,
          activeColor: AppColors.primary,
          labels: RangeLabels(
            "\$${_minPrice.round()}",
            "\$${_maxPrice.round()}",
          ),
          onChanged: (values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "\$${_minPrice.round()}",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              "\$${_maxPrice.round()}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        bool isSelected = _rating == starValue;
        return GestureDetector(
          onTap: () => setState(() => _rating = isSelected ? 0 : starValue),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.amber,
                ),
                const SizedBox(width: 4),
                Text(
                  "$starValue",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFacilitiesChipGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _allFacilities.map((facility) {
        final isSelected = _selectedFacilities.contains(facility);
        return FilterChip(
          label: Text(facility),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selected
                  ? _selectedFacilities.add(facility)
                  : _selectedFacilities.remove(facility);
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          // ✅ Return the new FilterState back to SearchPage
          final result = FilterState(
            minPrice: _minPrice,
            maxPrice: _maxPrice,
            rating: _rating,
            selectedFacilities: _selectedFacilities,
            location: _location,
          );
          Navigator.pop(context, result);
        },
        child: const Text(
          "Apply Filter",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: _location),
          onChanged: (value) => _location = value,
          decoration: InputDecoration(
            hintText: 'Enter location or use current location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            suffixIcon: IconButton(
              icon: _isGettingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppColors.primary),
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the location icon to use your current location',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      final locationData = await _locationService
          .getCurrentLocationWithAddress();

      if (locationData != null && mounted) {
        setState(() {
          _location = locationData['address'] ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location set to: ${_location}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to get current location. Please check permissions.',
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
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0.0;
      _maxPrice = 2000.0;
      _rating = 0;
      _selectedFacilities.clear();
      _location = '';
    });
  }
}
