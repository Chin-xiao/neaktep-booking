import 'package:flutter/material.dart';
import 'massage_screen.dart'; // Ensure filename is exactly this
import 'profile_screen.dart';
import 'routes/app_routes.dart';
import 'services/hotel_service.dart';
import 'utils/app_colors.dart';
import 'utils/models.dart';
import 'notification_detail_screen.dart';
import 'all_notifications_screen.dart';
// import 'my_booking_screen.dart'; // Uncomment if this is a separate file

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MainNavigation(),
      ),
    );

// --- NAVIGATION WRAPPER ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HotelHomeScreen(onProfileClick: () => _onTabChanged(3)),
      const MyBookingScreen(),
      const MessageScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

// --- HOME SCREEN ---
class HotelHomeScreen extends StatefulWidget {
  final VoidCallback onProfileClick;
  const HotelHomeScreen({super.key, required this.onProfileClick});

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  bool _showNotificationDropdown = false;

  Hotel _findHotel(String id) {
    return demoHotels.firstWhere(
      (hotel) => hotel.id == id,
      orElse: () => demoHotels.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final popularHotels = [
      _findHotel('horizon-retreat'),
      _findHotel('opal-grove'),
    ];
    final recommendedHotel = _findHotel('serenity-sands');
    final bestTodayHotel = _findHotel('phnom-penh-51');

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: GestureDetector(
                      onTap: widget.onProfileClick,
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=11',
                        ),
                      ),
                    ),
                    title: const Text(
                      "Chhorm Bunthai",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey),
                        Text(" Phnom Penh"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    IconButton(
                      icon: _buildHeaderIcon(Icons.search),
                      onPressed: () =>
                          Navigator.push(context, AppRoutes.toSearch()),
                    ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showNotificationDropdown =
                                  !_showNotificationDropdown;
                            });
                          },
                          child: _buildNotificationIcon(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationBanner(),
                  const SizedBox(height: 24),
                  _sectionHeader("Most Popular"),
                  const SizedBox(height: 16),
                  _buildPopularList(context, popularHotels),
                  const SizedBox(height: 24),
                  _sectionHeader("Recommended for you"),
                  const SizedBox(height: 16),
                  _buildCategoryRow(),
                  const SizedBox(height: 20),
                  _buildRecommendedItem(context, recommendedHotel),
                  const SizedBox(height: 24),
                  _sectionHeader("Best Today"),
                  const SizedBox(height: 16),
                  _buildBestTodayList(context, bestTodayHotel),
                ],
              ),
            ),
          ),
          if (_showNotificationDropdown) _buildNotificationDropdown(context),
        ],
      ),
    );
  }

  Widget _buildNotificationDropdown(BuildContext context) => Positioned.fill(
        child: GestureDetector(
          onTap: () => setState(() => _showNotificationDropdown = false),
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 75, right: 16),
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: const Text(
                        "Notifications",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildNotificationItem(
                      "Booking Confirmed",
                      "Your booking for Serenity Sands has been confirmed!",
                      Icons.check_circle,
                      Colors.green,
                      "5 minutes ago",
                      "Your booking for Serenity Sands Resort has been successfully confirmed. Check-in date: January 25, 2026. Check-out date: January 28, 2026. Booking ID: #BS2026001",
                    ),
                    const Divider(height: 1),
                    _buildNotificationItem(
                      "Special Offer",
                      "Get 20% off on selected villas this week",
                      Icons.local_offer,
                      Colors.orange,
                      "2 hours ago",
                      "Limited time offer! Enjoy 20% discount on all premium villa bookings this week. Use promo code: VILLA20. Offer valid until January 24, 2026.",
                    ),
                    const Divider(height: 1),
                    _buildNotificationItem(
                      "New Message",
                      "You have a new message from Phnom Penh Hotel",
                      Icons.mail,
                      Colors.blue,
                      "1 day ago",
                      "Phnom Penh Hotel has sent you a message regarding your upcoming reservation. They have special amenities available for your stay.",
                    ),
                    const Divider(height: 1),
                    _buildNotificationItem(
                      "Review Request",
                      "How was your stay? Please leave a review",
                      Icons.star,
                      Colors.amber,
                      "3 days ago",
                      "We hope you enjoyed your recent stay at Ocean View Resort. Your feedback helps us improve our services. Please take a moment to rate your experience.",
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3056D3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showNotificationDropdown = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AllNotificationsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "View All",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildHeaderIcon(IconData icon) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20),
      );

  Widget _buildNotificationIcon() => AnimatedScale(
        scale: _showNotificationDropdown ? 1.18 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          offset:
              _showNotificationDropdown ? const Offset(0, -0.05) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _showNotificationDropdown
                  ? const Color(0xFF3056D3).withValues(alpha: 0.16)
                  : Colors.white,
              border: Border.all(
                color: _showNotificationDropdown
                    ? const Color(0xFF3056D3)
                    : Colors.grey.shade200,
              ),
              boxShadow: _showNotificationDropdown
                  ? [
                      BoxShadow(
                        color: const Color(0xFF3056D3).withValues(alpha: 0.28),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              _showNotificationDropdown
                  ? Icons.notifications
                  : Icons.notifications_none,
              size: 20,
              color: _showNotificationDropdown
                  ? const Color(0xFF3056D3)
                  : Colors.black,
            ),
          ),
        ),
      );

  Widget _buildNotificationItem(
    String title,
    String message,
    IconData icon,
    Color iconColor,
    String timestamp,
    String detailedDescription,
  ) =>
      InkWell(
        onTap: () {
          setState(() {
            _showNotificationDropdown = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationDetailScreen(
                title: title,
                message: message,
                icon: icon,
                iconColor: iconColor,
                timestamp: timestamp,
                detailedDescription: detailedDescription,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timestamp,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sectionHeader(String title) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text("See All", style: TextStyle(color: Colors.blue)),
        ],
      );

  Widget _buildLocationBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.location_pin, color: Color(0xFF0D47A1)),
            SizedBox(width: 12),
            Expanded(child: Text("Change Location for nearby villas")),
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      );

  Widget _buildPopularList(BuildContext context, List<Hotel> hotels) =>
      SizedBox(
        height: 280,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children:
              hotels.map((hotel) => _buildPopularCard(context, hotel)).toList(),
        ),
      );

  Widget _buildPopularCard(BuildContext context, Hotel hotel) => Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
          child: Stack(
            children: [
              Hero(
                tag: 'hotel-${hotel.id}',
                child: Image.network(
                  hotel.imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Icon(Icons.favorite, color: Colors.red, size: 16),
                ),
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hotel.location,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${hotel.price}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "/night",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCategoryRow() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryItem("All", Icons.apps, true),
            _buildCategoryItem("Villas", Icons.villa, false),
            _buildCategoryItem("Hotels", Icons.hotel, false),
          ],
        ),
      );

  Widget _buildCategoryItem(String title, IconData icon, bool isSelected) =>
      Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3056D3) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _buildRecommendedItem(BuildContext context, Hotel hotel) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
          child: Row(
            children: [
              Hero(
                tag: 'hotel-${hotel.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    hotel.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        Text(
                          hotel.location,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${hotel.price} /night",
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text(
                    " ${hotel.rating.toStringAsFixed(1)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildBestTodayList(BuildContext context, Hotel hotel) => SizedBox(
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [_buildBestTodayCard(context, hotel, "\$200")],
        ),
      );

  Widget _buildBestTodayCard(BuildContext context, Hotel hotel, String old) =>
      InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'hotel-${hotel.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    hotel.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      hotel.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${hotel.price}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          old,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// --- MY BOOKING SCREEN ---
class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool isBookedSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "My Booking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildToggleButton(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildBookingCard(
                    "Aston Vill Hotel",
                    "Michikoton",
                    "\$120",
                    4.7,
                    "12-14 Nov",
                    "2 Guests",
                    "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton() => Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isBookedSelected = true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBookedSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Booked",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isBookedSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isBookedSelected = false),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        !isBookedSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "History",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !isBookedSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildBookingCard(
    String n,
    String l,
    String p,
    double r,
    String d,
    String g,
    String img,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(img, width: 80, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(" $r"),
                        ],
                      ),
                    ],
                  ),
                  Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  Text(
                    p,
                    style: const TextStyle(
                      color: Color(0xFF3056D3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Dates: $d", style: const TextStyle(fontSize: 11)),
                      Text("Guests: $g", style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
