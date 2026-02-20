import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- PROJECT IMPORTS ---
import 'package:neak_booking_app/screens/login_screen.dart'; 
import 'package:neak_booking_app/services/auth_service.dart'; 
import 'package:neak_booking_app/services/api_service.dart'; 
import 'package:neak_booking_app/my_booking_screen.dart'; 
import 'package:neak_booking_app/massage_screen.dart';
import 'package:neak_booking_app/profile_screen.dart';
import 'package:neak_booking_app/routes/app_routes.dart';
import 'package:neak_booking_app/utils/app_colors.dart';
import 'package:neak_booking_app/utils/models.dart';
import 'package:neak_booking_app/notification_detail_screen.dart';
import 'package:neak_booking_app/all_notifications_screen.dart';
import 'package:neak_booking_app/components/safe_network_image.dart'; // ✅ Added this

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neak Booking',
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
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data == true ? const MainNavigation() : const LoginScreen();
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}

// --- MAIN NAVIGATION (THE HUB) ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String displayUserName = "User";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final data = await _authService.getUserProfile();
    if (data != null && mounted) {
      setState(() {
        displayUserName = data['name'] ?? data['username'] ?? "User";
      });
    }
  }
  
  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex, 
        children: [
          HotelHomeScreen(
            onProfileClick: () => _onTabChanged(3),
            userName: displayUserName,
          ),
          const MyBookingScreen(), 
          const MessageScreen(),
          const ProfileScreen(),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

// --- HOME SCREEN ---
class HotelHomeScreen extends StatefulWidget {
  final VoidCallback onProfileClick;
  final String userName;

  const HotelHomeScreen({
    super.key, 
    required this.onProfileClick,
    required this.userName,
  });

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  bool _showNotificationDropdown = false;
  late Future<List<Hotel>> _hotelsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _hotelsFuture = _apiService.fetchHotels();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          FutureBuilder<List<Hotel>>(
            future: _hotelsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final hotels = snapshot.data ?? [];
              final popularHotels = hotels.where((h) => h.isPopular).toList();

              return RefreshIndicator(
                onRefresh: () async => setState(() => _hotelsFuture = _apiService.fetchHotels()),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 20),
                        _buildSearchInput(context),
                        const SizedBox(height: 24),
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
                        if (hotels.isNotEmpty) _buildRecommendedItem(context, hotels.first),
                        const SizedBox(height: 24),
                        _sectionHeader("Best Today"),
                        const SizedBox(height: 16),
                        _buildBestTodayList(context, hotels),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_showNotificationDropdown) _buildNotificationDropdown(context),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: GestureDetector(
      onTap: widget.onProfileClick,
      child: const CircleAvatar(
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
      ),
    ),
    title: Text(widget.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    subtitle: const Text("Phnom Penh, RUPP"),
    trailing: GestureDetector(
      onTap: () => setState(() => _showNotificationDropdown = !_showNotificationDropdown),
      child: _buildIconContainer(Icons.notifications_none),
    ),
  );

  Widget _buildSearchInput(BuildContext context) => TextField(
    readOnly: true, 
    onTap: () => Navigator.push(context, AppRoutes.toSearch()),
    decoration: InputDecoration(
      hintText: "Search hotel, villa, etc...",
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    ),
  );

  Widget _buildIconContainer(IconData icon) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
    child: Icon(icon, size: 20),
  );

  Widget _buildPopularList(BuildContext context, List<Hotel> hotels) => SizedBox(
    height: 280,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: hotels.length,
      itemBuilder: (context, index) => _buildPopularCard(context, hotels[index]),
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
          // ✅ FIXED: Changed imageUrl to image
          SafeNetworkImage(
            url: hotel.image, 
            height: double.infinity, 
            width: double.infinity,
          ),
          Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
          Positioned(bottom: 15, left: 15, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(hotel.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(hotel.location, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            Text('\$${hotel.price.toStringAsFixed(0)} /night', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ])),
        ],
      ),
    ),
  );

  Widget _buildRecommendedItem(BuildContext context, Hotel hotel) => InkWell(
    onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
    child: Row(children: [
      // ✅ FIXED: Changed imageUrl to image
      ClipRRect(
        borderRadius: BorderRadius.circular(16), 
        child: SafeNetworkImage(url: hotel.image, width: 80, height: 80)
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text("\$${hotel.price.toStringAsFixed(0)} /night", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      ])),
      Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), Text(" ${hotel.rating}", style: const TextStyle(fontWeight: FontWeight.bold))]),
    ]),
  );

  Widget _buildBestTodayList(BuildContext context, List<Hotel> hotels) => SizedBox(
    height: 120,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: hotels.length,
      itemBuilder: (context, index) => _buildBestTodayCard(context, hotels[index]),
    ),
  );

  Widget _buildBestTodayCard(BuildContext context, Hotel hotel) => InkWell(
    onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.85,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(children: [
        // ✅ FIXED: Changed imageUrl to image
        ClipRRect(
          borderRadius: BorderRadius.circular(12), 
          child: SafeNetworkImage(url: hotel.image, width: 75, height: 75)
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
          Text(hotel.location, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text('\$${hotel.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ])),
      ]),
    ),
  );

  Widget _buildNotificationDropdown(BuildContext context) => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showNotificationDropdown = false),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.only(top: 75, right: 16),
          width: 280,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text("Booking Confirmed"), subtitle: Text("Your stay is ready!")),
              Padding(padding: const EdgeInsets.all(8.0), child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllNotificationsScreen())), child: const Text("View All"))),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _sectionHeader(String title) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const Text("See All", style: TextStyle(color: Colors.blue)),
  ]);

  Widget _buildLocationBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
    child: const Row(children: [
      Icon(Icons.location_pin, color: Color(0xFF0D47A1)),
      SizedBox(width: 12),
      Expanded(child: Text("Change Location for nearby villas")),
      Icon(Icons.arrow_forward_ios, size: 16),
    ]),
  );

  Widget _buildCategoryRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      _buildCategoryItem("All", Icons.apps, true),
      _buildCategoryItem("Villas", Icons.villa, false),
      _buildCategoryItem("Hotels", Icons.hotel, false),
    ]),
  );

  Widget _buildCategoryItem(String t, IconData i, bool s) => Container(
    margin: const EdgeInsets.only(right: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: s ? const Color(0xFF3056D3) : Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(i, size: 18, color: s ? Colors.white : Colors.grey),
      const SizedBox(width: 8),
      Text(t, style: TextStyle(color: s ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    ]),
  );
}