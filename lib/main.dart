import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'massage_screen.dart'; // Ensure filename is exactly this
import 'search_screen.dart';
// import 'my_booking_screen.dart'; // Uncomment if this is a separate file

void main() => runApp(
  const MaterialApp(debugShowCheckedModeBanner: false, home: MainNavigation()),
);

// --- NAVIGATION WRAPPER (Optimized with IndexedStack) ---
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
    // Pre-loading screens to prevent slowness during tab switching
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
      // IndexedStack keeps all pages alive in the background
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3056D3),
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
class HotelHomeScreen extends StatelessWidget {
  final VoidCallback onProfileClick;
  const HotelHomeScreen({super.key, required this.onProfileClick});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: GestureDetector(
                  onTap: onProfileClick,
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
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      ),
                    ),
                    _buildHeaderIcon(Icons.notifications_none),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildLocationBanner(),
              const SizedBox(height: 24),
              _sectionHeader("Most Popular"),
              const SizedBox(height: 16),
              _buildPopularList(),
              const SizedBox(height: 24),
              _sectionHeader("Recommended for you"),
              const SizedBox(height: 16),
              _buildCategoryRow(),
              const SizedBox(height: 20),
              _buildRecommendedItem(
                "Serenity Sands",
                "Honolulu, HI",
                "\$270",
                4.0,
                "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400",
              ),
              const SizedBox(height: 24),
              _sectionHeader("Best Today 🔥"),
              const SizedBox(height: 16),
              _buildBestTodayList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Icon(icon, size: 20),
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

  Widget _buildPopularList() => SizedBox(
    height: 280,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildPopularCard(
          "The Horizon Retreat",
          "\$480",
          "Los Angeles, CA",
          "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500",
        ),
        _buildPopularCard(
          "Opal Grove Inn",
          "\$190",
          "San Diego, CA",
          "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500",
        ),
      ],
    ),
  );

  Widget _buildPopularCard(
    String name,
    String price,
    String location,
    String imgUrl,
  ) => Container(
    width: 220,
    margin: const EdgeInsets.only(right: 16),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
    child: Stack(
      children: [
        Image.network(
          imgUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
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
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                location,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "/night",
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildRecommendedItem(
    String name,
    String location,
    String price,
    double rating,
    String imgUrl,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imgUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  Text(
                    location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "$price /night",
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
              " $rating",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildBestTodayList(BuildContext context) => SizedBox(
    height: 120,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _buildBestTodayCard(
          context,
          "Phnom Penh 51 Hotel",
          "Daun Penh, PP",
          "\$150",
          "\$200",
          "https://images.unsplash.com/photo-1551882547-ff43c63faf7c?w=400",
        ),
      ],
    ),
  );

  Widget _buildBestTodayCard(
    BuildContext context,
    String name,
    String loc,
    String price,
    String old,
    String img,
  ) => Container(
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
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(img, width: 70, height: 70, fit: BoxFit.cover),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                loc,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    price,
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
                color: !isBookedSelected ? Colors.white : Colors.transparent,
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
  ) => Container(
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
