import 'package:flutter/material.dart';

// --- 1. FILTER STATE ---
class FilterState {
  final double minPrice;
  final double maxPrice;
  final int rating;
  final List<String> selectedFacilities;
  final String? location;
  final String guestOption;

  FilterState({
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.rating = 0,
    this.selectedFacilities = const [],
    this.location,
    this.guestOption = '1 Guest',
  });

  FilterState copyWith({
    double? minPrice,
    double? maxPrice,
    int? rating,
    List<String>? selectedFacilities,
    String? location,
    String? guestOption,
  }) {
    return FilterState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      rating: rating ?? this.rating,
      selectedFacilities: selectedFacilities ?? this.selectedFacilities,
      location: location ?? this.location,
      guestOption: guestOption ?? this.guestOption,
    );
  }
}

// --- 2. BOOKING MODEL ---
class Booking {
  final int id;
  final Hotel hotel;
  final DateTime checkIn;
  final DateTime checkOut;
  final DateTime createdAt; // ✅ Fix: Essential for timer logic
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.hotel,
    required this.checkIn,
    required this.checkOut,
    required this.createdAt,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      hotel: Hotel.fromJson(json['hotel'] as Map<String, dynamic>? ?? {}),
      checkIn:
          DateTime.tryParse(json['check_in']?.toString() ?? '') ??
          DateTime.now(),
      checkOut:
          DateTime.tryParse(json['check_out']?.toString() ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0.0') ?? 0.0,
      status: (json['status']?.toString() ?? 'pending').toLowerCase().trim(),
    );
  }

  Color get statusColor {
    switch (status) {
      case 'confirmed':
      case 'booked':
        return Colors.green; // ✅ Handles both status names
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// --- 3. ROOM MODEL ---
class Room {
  final String name;
  final String bedConfiguration;
  final int bedCount;
  final int bathroomCount;
  final double price;

  Room({
    required this.name,
    required this.bedConfiguration,
    required this.bedCount,
    required this.bathroomCount,
    required this.price,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name:
          json['room_name']?.toString() ??
          json['name']?.toString() ??
          'Standard Room',
      bedConfiguration: json['bed_configuration']?.toString() ?? '',
      bedCount: int.tryParse(json['bed_count']?.toString() ?? '1') ?? 1,
      bathroomCount:
          int.tryParse(json['bathroom_count']?.toString() ?? '1') ?? 1,
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

// --- 4. HOTEL MODEL ---
class Hotel {
  final int id;
  final String name;
  final String location;
  final double price;
  final String image;
  final double rating;
  final String description;
  final List<String> facilities;
  final List<Room> rooms;
  final String? mapImageUrl;
  final bool isPopular;
  final bool isBestToday;
  final double? latitude;
  final double? longitude;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.image,
    required this.rating,
    required this.description,
    this.rooms = const [],
    this.facilities = const [],
    this.mapImageUrl,
    this.isPopular = false,
    this.isBestToday = false,
    this.latitude,
    this.longitude,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return Hotel(
        id: 0,
        name: 'N/A',
        location: '',
        price: 0,
        image: '',
        rating: 0,
        description: '',
      );
    }

    final roomsJson = json['rooms'] as List? ?? [];
    final roomList = roomsJson
        .map((r) => Room.fromJson(r as Map<String, dynamic>))
        .toList();

    double displayPrice =
        double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0;
    if (displayPrice == 0 && roomList.isNotEmpty) {
      displayPrice = roomList.first.price;
    }

    final facilityItems = <String>{};
    final rawAmenities =
        json['amenities'] ?? json['facilities'] ?? json['features'];

    if (rawAmenities is List) {
      for (var item in rawAmenities) {
        if (item is Map) {
          if (item['items'] is List) {
            facilityItems.addAll(
              (item['items'] as List).map((e) => e.toString()),
            );
          } else if (item['name'] != null) {
            facilityItems.add(item['name'].toString());
          }
        } else {
          facilityItems.add(item.toString());
        }
      }
    }

    final locationStr =
        json['location']?.toString() ??
        json['address']?.toString() ??
        'Address unknown';

    double? parsedLat = double.tryParse(json['latitude']?.toString() ?? '');
    double? parsedLng = double.tryParse(json['longitude']?.toString() ?? '');

    if ((parsedLat == null || parsedLng == null) && locationStr.contains(',')) {
      final parts = locationStr.split(',');
      if (parts.length == 2) {
        final parsedLatFromLoc = double.tryParse(parts[0].trim());
        final parsedLngFromLoc = double.tryParse(parts[1].trim());
        if (parsedLatFromLoc != null && parsedLngFromLoc != null) {
          parsedLat = parsedLatFromLoc;
          parsedLng = parsedLngFromLoc;
        }
      }
    }

    return Hotel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? 'Hotel Name',
      location: locationStr,
      price: displayPrice,
      image:
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['image_path']?.toString() ??
          '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      description:
          json['description']?.toString() ?? 'No description available.',
      facilities: facilityItems.toList(),
      rooms: roomList,
      mapImageUrl: json['map_link']?.toString() ?? json['map_url']?.toString(),
      isPopular:
          json['is_popular'] == true ||
          json['is_popular'] == 1 ||
          json['is_popular'].toString() == "1",
      isBestToday:
          json['is_best_today'] == true ||
          json['is_best_today'] == 1 ||
          json['is_best_today'].toString() == "1",
      latitude: parsedLat,
      longitude: parsedLng,
    );
  }
}

// --- 5. FACILITY GROUP MODEL ---
class FacilityGroup {
  final String title;
  final List<String> facilities;

  FacilityGroup({required this.title, required this.facilities});

  factory FacilityGroup.fromJson(Map<String, dynamic> json) {
    return FacilityGroup(
      title: json['name']?.toString() ?? 'General',
      facilities:
          (json['items'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

// --- 6. SEARCH PAGE DATA ---
class SearchPageData {
  final List<RecentSearchItem> recentSearches;
  final List<Hotel> recentlyViewed;
  final List<Hotel> popular;
  final List<Hotel> recommended;

  const SearchPageData({
    required this.recentSearches,
    required this.recentlyViewed,
    required this.popular,
    required this.recommended,
  });

  factory SearchPageData.fromJson(Map<String, dynamic> json) {
    return SearchPageData(
      recentSearches:
          (json['recent_searches'] as List?)
              ?.map((e) => RecentSearchItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentlyViewed:
          (json['recently_viewed'] as List?)
              ?.map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      popular:
          (json['popular'] as List? ?? json['popular_hotels'] as List? ?? [])
              .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList(),
      recommended:
          (json['recommended'] as List? ??
                  json['recommended_hotels'] as List? ??
                  [])
              .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class RecentSearchItem {
  final String title;
  final String subtitle;
  const RecentSearchItem({required this.title, required this.subtitle});

  factory RecentSearchItem.fromJson(Map<String, dynamic> json) {
    return RecentSearchItem(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
    );
  }
}

// --- 7. FILTER OPTIONS ---
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

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      guestOptions:
          (json['guest_options'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      locations:
          (json['locations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      facilities:
          (json['facilities'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      minPrice: double.tryParse(json['min_price']?.toString() ?? '0.0') ?? 0.0,
      maxPrice:
          double.tryParse(json['max_price']?.toString() ?? '1000.0') ?? 1000.0,
      ratings:
          (json['ratings'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [5, 4, 3, 2, 1],
    );
  }
}

// --- 8. REVIEW MODELS ---
class Review {
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? userId; // Store user ID to fetch avatar if needed

  const Review({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.userId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Extract user data - backend might return user as nested object or flat fields
    final userObj = json['user'];

    // Try multiple possible field names for avatar
    final avatar =
        json['user_avatar'] ??
        json['avatar'] ??
        json['avatar_url'] ??
        userObj?['avatar_url'] ??
        userObj?['avatar'] ??
        userObj?['profile_photo_url'] ??
        userObj?['profile_photo'] ??
        '';

    final userName =
        json['user_name'] ??
        json['reviewer_name'] ??
        userObj?['name'] ??
        'Guest';

    final userId = json['user_id']?.toString() ?? userObj?['id']?.toString();

    debugPrint('👤 Review Data:');
    debugPrint('   JSON keys: ${json.keys.toList()}');
    debugPrint('   user_name: $userName');
    debugPrint('   user_avatar: $avatar');
    debugPrint('   user_id: $userId');
    if (userObj != null) {
      debugPrint('   user object keys: ${userObj.keys.toList()}');
      debugPrint('   user object: $userObj');
    }

    return Review(
      userName: userName,
      userAvatar: avatar,
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      comment: json['comment']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      userId: userId,
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalReviews;
  final List<int> bars;

  const RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.bars,
  });

  double getPercentForStar(int starLevel) {
    if (totalReviews == 0) return 0.0;
    int index = 5 - starLevel;
    if (index >= 0 && index < bars.length) {
      return bars[index] / totalReviews;
    }
    return 0.0;
  }

  factory RatingSummary.fromJson(dynamic json) {
    if (json == null || json is! Map) {
      return const RatingSummary(
        averageRating: 0.0,
        totalReviews: 0,
        bars: [0, 0, 0, 0, 0],
      );
    }

    return RatingSummary(
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      bars:
          (json['bars'] as List?)
              ?.map((e) => int.tryParse(e.toString()) ?? 0)
              .toList() ??
          [0, 0, 0, 0, 0],
    );
  }
}
