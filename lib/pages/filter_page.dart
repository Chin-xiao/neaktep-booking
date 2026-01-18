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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: RoundIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Filter By',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
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
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        _buildLabel('Placeholder'),
                        const SizedBox(height: 8),
                        _buildGuestDropdown(options),
                        const SizedBox(height: 22),
                        _buildLabel('Price'),
                        const SizedBox(height: 4),
                        _buildPriceSlider(options),
                        const SizedBox(height: 8),
                        _buildInstantBook(),
                        const SizedBox(height: 16),
                        _buildLabel('Location'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: options.locations
                              .map(
                                (location) => _buildChip(
                                  location,
                                  _state.location == location,
                                  () {
                                    setState(() {
                                      _state = _state.copyWith(
                                        location: location,
                                      );
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        _buildLabel('Facilities'),
                        const SizedBox(height: 10),
                        ...options.facilities.map((facility) {
                          final isChecked = _state.facilities.contains(
                            facility,
                          );
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.trailing,
                            activeColor: AppColors.primary,
                            title: Text(
                              facility,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: isChecked,
                            onChanged: (value) {
                              final updated = Set<String>.from(
                                _state.facilities,
                              );
                              if (value == true) {
                                updated.add(facility);
                              } else {
                                updated.remove(facility);
                              }
                              setState(() {
                                _state = _state.copyWith(facilities: updated);
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 12),
                        _buildLabel('Ratings'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: options.ratings
                              .map(_buildRatingChip)
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: PrimaryButton(
                    label: 'Apply Filter',
                    onPressed: () => Navigator.pop(context, _state),
                    height: 52,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildGuestDropdown(FilterOptions options) {
    return DropdownButtonFormField<String>(
      key: ValueKey(_state.guestOption),
      initialValue: _state.guestOption,
      items: options.guestOptions
          .map(
            (option) =>
                DropdownMenuItem<String>(value: option, child: Text(option)),
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
          vertical: 14,
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
    );
  }

  Widget _buildPriceSlider(FilterOptions options) {
    final label =
        '\$${_state.priceRange.start.round()} - \$${_state.priceRange.end.round()}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(),
            Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: RangeSlider(
            values: _state.priceRange,
            min: options.minPrice,
            max: options.maxPrice,
            divisions: 8,
            labels: RangeLabels(
              '\$${_state.priceRange.start.round()}',
              '\$${_state.priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _state = _state.copyWith(priceRange: values);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstantBook() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Instant Book',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'Book without waiting for the host to respond',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: _state.instantBook,
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary
                : null,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.25)
                : AppColors.divider,
          ),
          onChanged: (value) {
            setState(() {
              _state = _state.copyWith(instantBook: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
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
