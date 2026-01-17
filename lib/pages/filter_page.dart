import 'package:flutter/material.dart';

import '../layout/primary_button.dart';
import '../layout/round_icon_button.dart';
import '../services/hotel_service.dart';
import '../utils/app_colors.dart';
import '../utils/models.dart';

class FilterPage extends StatefulWidget {
  final FilterState initial;

  const FilterPage({super.key, required this.initial});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final HotelService _hotelService = HotelService();
  late final Future<FilterOptions> _optionsFuture;
  late FilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
    _optionsFuture = _hotelService.fetchFilterOptions();
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
          'Filter By',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<FilterOptions>(
        future: _optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Unable to load filters.'));
          }
          final options = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const Text(
                'Placeholder',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _state.guestOption,
                items: options.guestOptions
                    .map(
                      (option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _state = _state.copyWith(guestOption: value);
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
                icon: const Icon(Icons.keyboard_arrow_down),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${_state.priceRange.start.round()} - \$${_state.priceRange.end.round()}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
              RangeSlider(
                values: _state.priceRange,
                min: options.minPrice,
                max: options.maxPrice,
                divisions: 8,
                activeColor: AppColors.primary,
                onChanged: (values) {
                  setState(() {
                    _state = _state.copyWith(priceRange: values);
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Instant Book',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Book without waiting for the host to respond',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                value: _state.instantBook,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _state = _state.copyWith(instantBook: value);
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: options.locations.map((location) {
                  final isSelected = _state.location == location;
                  return ChoiceChip(
                    label: Text(location),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _state = _state.copyWith(location: location);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Facilities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...options.facilities.map(
                (facility) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                  title: Text(facility),
                  value: _state.facilities.contains(facility),
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    final updated = Set<String>.from(_state.facilities);
                    if (value == true) {
                      updated.add(facility);
                    } else {
                      updated.remove(facility);
                    }
                    setState(() {
                      _state = _state.copyWith(facilities: updated);
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ratings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: options.ratings.map(_buildRatingChip).toList(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Apply Filter',
                onPressed: () => Navigator.pop(context, _state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingChip(int rating) {
    final isSelected = _state.rating == rating;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _state = _state.copyWith(rating: rating);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              rating.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
