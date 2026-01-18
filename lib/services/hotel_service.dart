import '../utils/models.dart';

class HotelService {
  Future<SearchPageData> fetchSearchPageData() async {
    await _simulateLatency();
    return SearchPageData(
      recentSearches: const [
        RecentSearchItem(
          title: 'Caravan Hotel by EHM',
          subtitle: 'Samdech Mongkol Iem St. (228)',
        ),
        RecentSearchItem(
          title: 'Phnom Penh 51 Hotel & Residences',
          subtitle: '#17, Street Pasteur, Chakto Mouk',
        ),
        RecentSearchItem(
          title: 'Ohana Phnom Penh Palace Hotel',
          subtitle: '#4-6, Street 148, Sangkat Phsar Kandal',
        ),
      ],
      recentlyViewed: [
        demoHotels.firstWhere((hotel) => hotel.id == 'sun-moon'),
        demoHotels.firstWhere((hotel) => hotel.id == 'g-mekong'),
      ],
    );
  }

  Future<List<Hotel>> searchHotels({
    required String query,
    required FilterState filters,
  }) async {
    await _simulateLatency();
    final lower = query.trim().toLowerCase();

    bool matchesQuery(Hotel hotel) {
      return lower.isEmpty ||
          hotel.name.toLowerCase().contains(lower) ||
          hotel.location.toLowerCase().contains(lower);
    }

    bool supportsInstantBook(Hotel hotel) {
      return hotel.facilities.contains('24-Hours Front Desk');
    }

    final filtered = demoHotels.where((hotel) {
      final withinPrice =
          hotel.price >= filters.priceRange.start &&
          hotel.price <= filters.priceRange.end;
      final meetsRating = hotel.rating >= filters.rating;
      final matchesFacilities = filters.facilities.every(
        (facility) => hotel.facilities.contains(facility),
      );
      final matchesLocation =
          filters.location.isEmpty ||
          hotel.location.toLowerCase().contains(filters.location.toLowerCase());
      final matchesInstant = !filters.instantBook || supportsInstantBook(hotel);
      return matchesQuery(hotel) &&
          withinPrice &&
          meetsRating &&
          matchesFacilities &&
          matchesLocation &&
          matchesInstant;
    }).toList();

    filtered.sort((a, b) => a.price.compareTo(b.price));
    return filtered;
  }

  Future<FilterOptions> fetchFilterOptions() async {
    await _simulateLatency();
    return const FilterOptions(
      guestOptions: [
        '1 Guest (1 Adult)',
        '2 Guest (2 Adult)',
        '3 Guest (2 Adult, 1 Children)',
      ],
      locations: ['Sen Sok', 'Daun Penh', 'Phnom Penh'],
      facilities: ['Free Wifi', 'Swimming Pool', 'TV', 'Laundry'],
      minPrice: 0,
      maxPrice: 80,
      ratings: [5, 4, 3, 2, 1],
    );
  }

  Future<Hotel> fetchHotelDetail(String id) async {
    await _simulateLatency();
    return demoHotels.firstWhere(
      (hotel) => hotel.id == id,
      orElse: () => demoHotels.first,
    );
  }

  Future<List<Review>> fetchReviews() async {
    await _simulateLatency();
    return demoReviews;
  }

  Future<RatingSummary> fetchRatingSummary() async {
    await _simulateLatency();
    return const RatingSummary(
      average: 4.4,
      total: 532,
      bars: [210, 150, 90, 60, 22],
    );
  }

  Future<List<FacilityGroup>> fetchFacilityGroups() async {
    await _simulateLatency();
    return facilityGroups;
  }

  Future<void> _simulateLatency() {
    return Future<void>.delayed(const Duration(milliseconds: 650));
  }
}

const List<Hotel> demoHotels = [
  Hotel(
    id: 'horizon-retreat',
    name: 'The Horizon Retreat',
    location: 'Los Angeles, CA',
    rating: 4.5,
    price: 480,
    imageUrl:
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900',
    description:
        'A skyline escape with serene suites, spa rituals, and panoramic '
        'sunset views.',
    facilities: ['AC', 'Restaurant', 'Swimming Pool', '24-Hours Front Desk'],
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ),
  Hotel(
    id: 'opal-grove',
    name: 'Opal Grove Inn',
    location: 'San Diego, CA',
    rating: 4.2,
    price: 190,
    imageUrl:
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=900',
    description:
        'Coastal comfort with leafy courtyards, bright rooms, and an easy walk '
        'to the bay.',
    facilities: ['Free Wifi', 'Restaurant', 'Laundry', '24-Hours Front Desk'],
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ),
  Hotel(
    id: 'serenity-sands',
    name: 'Serenity Sands',
    location: 'Honolulu, HI',
    rating: 4.0,
    price: 270,
    imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=900',
    description:
        'Beachfront calm with ocean-view balconies, open-air dining, and a '
        'sunlit pool deck.',
    facilities: [
      'Free Wifi',
      'Swimming Pool',
      'Restaurant',
      '24-Hours Front Desk',
    ],
    mapImageUrl:
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=800',
  ),
  Hotel(
    id: 'aston-vill',
    name: 'The Aston Vill Hotel',
    location: 'Veum Point, Michikoton',
    rating: 4.6,
    price: 120,
    imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=900',
    description:
        'The ideal place for those looking for a luxurious and tranquil holiday '
        'experience with stunning sea views.',
    facilities: ['AC', 'Restaurant', 'Swimming Pool', '24-Hours Front Desk'],
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ),
  Hotel(
    id: 'sun-moon',
    name: 'SUN & MOON, Urban Hotel',
    location: '#68, corner of street 136',
    rating: 4.0,
    price: 230,
    imageUrl:
        'https://smuhg.b-cdn.net/wp-content/uploads/2025/10/EXCELLENCE-01-scaled.jpg',
    description:
        'A vibrant city stay with rooftop views, smart rooms, and quick access '
        'to riverside dining.',
    facilities: [
      'Free Wifi',
      'Restaurant',
      'Swimming Pool',
      '24-Hours Front Desk',
    ],
    mapImageUrl:
        'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=800',
  ),
  Hotel(
    id: 'g-mekong',
    name: 'G Mekong Hotel Phnom Penh',
    location: 'Preah Monivong Boulevard',
    rating: 3.8,
    price: 290,
    imageUrl:
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=900',
    description:
        'Modern rooms with a quiet courtyard, ideal for business stays and '
        'late-night city strolls.',
    facilities: ['Free Wifi', 'TV', 'Laundry', '24-Hours Front Desk'],
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ),
  Hotel(
    id: 'phnom-penh-51',
    name: 'Phnom Penh 51 Hotel & Residences',
    location: 'Daun Penh, Phnom Penh',
    rating: 4.4,
    price: 150,
    imageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=80',
    description:
        'Residential comfort with a boutique touch, close to embassies and '
        'art galleries.',
    facilities: ['Free Wifi', 'Restaurant', 'Swimming Pool', 'Laundry'],
    mapImageUrl:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ),
];

const List<Review> demoReviews = [
  Review(
    name: 'Kim Borrdy',
    avatarUrl: 'https://i.pravatar.cc/150?img=48',
    rating: 4.5,
    comment:
        'Amazing! The room is good than the picture. Thanks for amazing experience!',
  ),
  Review(
    name: 'Mirai Kamazuki',
    avatarUrl: 'https://i.pravatar.cc/150?img=11',
    rating: 5.0,
    comment:
        'The service is on point, and I really like the facilities. Good job!',
  ),
  Review(
    name: 'Jzenklen',
    avatarUrl: 'https://i.pravatar.cc/150?img=13',
    rating: 5.0,
    comment: 'Comfortable beds and great city views. Would stay again.',
  ),
  Review(
    name: 'Rezikan Akay',
    avatarUrl: 'https://i.pravatar.cc/150?img=16',
    rating: 5.0,
    comment: 'The staff was so helpful and the breakfast was delicious.',
  ),
  Review(
    name: 'Rezingkaly',
    avatarUrl: 'https://i.pravatar.cc/150?img=52',
    rating: 5.0,
    comment: 'Lovely stay with modern rooms. Highly recommended.',
  ),
  Review(
    name: 'Andiziky',
    avatarUrl: 'https://i.pravatar.cc/150?img=23',
    rating: 5.0,
    comment: 'Fast check-in and clean facilities. Really enjoyed my stay.',
  ),
];

const List<FacilityGroup> facilityGroups = [
  FacilityGroup(
    title: 'Food and Drink',
    items: [
      'A la carte dinner',
      'A la carte lunch',
      'Breakfast',
      'Vegetarian meal',
    ],
  ),
  FacilityGroup(
    title: 'Transportation',
    items: [
      'Airport transfer',
      'Taxi service',
      'Car rental',
      'On-site parking',
    ],
  ),
  FacilityGroup(
    title: 'General',
    items: [
      '24-hour front desk',
      'Concierge',
      'Luggage storage',
      'Daily housekeeping',
      'Elevator',
      'Smoke-free property',
      'Air conditioning',
      'Balcony',
    ],
  ),
  FacilityGroup(
    title: 'Hotel Service',
    items: ['Laundry service', 'Room service'],
  ),
  FacilityGroup(
    title: 'Business Facilities',
    items: [
      'Meeting rooms',
      'Printing service',
      'High-speed Wi-Fi',
      'Private work pods',
      'Event support staff',
      'Coffee corner',
    ],
  ),
  FacilityGroup(
    title: 'Nearby facilities',
    items: [
      'Pharmacy',
      'Convenience store',
      'Shopping mall',
      'Public park',
      'Bank',
      'Cafes & restaurants',
      'ATM',
      'Bus stop',
    ],
  ),
  FacilityGroup(
    title: 'Kids',
    items: ['Kids pool', 'Baby cot on request', 'Kids menu'],
  ),
  FacilityGroup(title: 'Connectivity', items: ['Free Wifi', 'Smart TV']),
  FacilityGroup(
    title: 'Public Facilities',
    items: [
      'Swimming pool',
      'Fitness center',
      'Garden',
      'Lounge',
      'Terrace',
      'Spa',
      'Sauna',
      'Parking',
      'Cafe',
      'Restaurant',
      'Bar',
      '24-Hours Front Desk',
      'ATM',
      'Elevator',
      'Security',
      'Lobby',
    ],
  ),
];
