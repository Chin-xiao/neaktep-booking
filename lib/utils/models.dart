import 'package:flutter/material.dart';

class Hotel {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int price;
  final String imageUrl;
  final String description;
  final List<String> facilities;
  final String mapImageUrl;

  const Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.facilities,
    required this.mapImageUrl,
  });
}

class RecentSearchItem {
  final String title;
  final String subtitle;

  const RecentSearchItem({required this.title, required this.subtitle});
}

class SearchPageData {
  final List<RecentSearchItem> recentSearches;
  final List<Hotel> recentlyViewed;

  const SearchPageData({
    required this.recentSearches,
    required this.recentlyViewed,
  });
}

class FilterOptions {
  final List<String> guestOptions;
  final List<String> locations;
  final List<String> facilities;
  final double minPrice;
  final double maxPrice;
  final List<int> ratings;

  const FilterOptions({
    required this.guestOptions,
    required this.locations,
    required this.facilities,
    required this.minPrice,
    required this.maxPrice,
    required this.ratings,
  });
}

class FilterState {
  final RangeValues priceRange;
  final bool instantBook;
  final String location;
  final Set<String> facilities;
  final int rating;
  final String guestOption;

  FilterState({
    required this.priceRange,
    required this.instantBook,
    required this.location,
    required this.facilities,
    required this.rating,
    required this.guestOption,
  });

  FilterState copyWith({
    RangeValues? priceRange,
    bool? instantBook,
    String? location,
    Set<String>? facilities,
    int? rating,
    String? guestOption,
  }) {
    return FilterState(
      priceRange: priceRange ?? this.priceRange,
      instantBook: instantBook ?? this.instantBook,
      location: location ?? this.location,
      facilities: Set<String>.from(facilities ?? this.facilities),
      rating: rating ?? this.rating,
      guestOption: guestOption ?? this.guestOption,
    );
  }

  factory FilterState.initial() {
    return FilterState(
      priceRange: const RangeValues(0, 80),
      instantBook: false,
      location: 'Sen Sok',
      facilities: <String>{'Free Wifi', 'Laundry'},
      rating: 4,
      guestOption: '3 Guest (2 Adult, 1 Children)',
    );
  }

  bool matches(FilterState other) {
    return priceRange.start == other.priceRange.start &&
        priceRange.end == other.priceRange.end &&
        instantBook == other.instantBook &&
        location == other.location &&
        rating == other.rating &&
        guestOption == other.guestOption &&
        _setEquals(facilities, other.facilities);
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) {
      return false;
    }
    return a.containsAll(b);
  }
}

class Review {
  final String name;
  final String avatarUrl;
  final double rating;
  final String comment;

  const Review({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
  });
}

class RatingSummary {
  final double average;
  final int total;
  final List<int> bars; // 5 → 1 star counts order

  const RatingSummary({
    required this.average,
    required this.total,
    required this.bars,
  });
}

class FacilityGroup {
  final String title;
  final List<String> items;

  const FacilityGroup({required this.title, required this.items});
}
