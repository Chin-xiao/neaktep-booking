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
import 'package:neak_booking_app/all_notifications_screen.dart';
import 'package:neak_booking_app/components/safe_network_image.dart'; // ✅ Added this
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Neak Booking',
      theme: ThemeData(
        primaryColor: AppColors.primary,
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
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          foregroundColor: AppColors.textPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == true
              ? const MainNavigation()
              : const LoginScreen();
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
  String? userProfileImage;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    // Request permission first
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Force token update
    await _authService.updateFCMToken();

    // 1. App is Terminated, user taps notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });

    // 2. App is in Foreground, we show a local dialog or snackbar
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground message: ${message.notification?.title}");
      if (message.notification != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification!.title}: ${message.notification!.body}",
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: "View",
              onPressed: () => _handleNotificationClick(message),
            ),
          ),
        );
      }
    });

    // 3. App is in Background, user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });
  }

  void _handleNotificationClick(RemoteMessage message) async {
    final data = message.data;
    if (data['type'] == 'hotel_alert' && data['hotel_id'] != null) {
      final String hotelId = data['hotel_id'];
      debugPrint("Navigating to hotel $hotelId from notification");
      // Fetch hotel details and navigate
      final ApiService apiService = ApiService();
      final hotel = await apiService.fetchHotelById(hotelId);
      if (hotel != null && mounted) {
        Navigator.of(context).push(AppRoutes.toDetail(hotel));
      }
    }
  }

  Future<void> _fetchUserData() async {
    final data = await _authService.getUserProfile();
    if (data != null && mounted) {
      debugPrint('📥 Home Profile Data from API: $data');
      setState(() {
        displayUserName = data['name'] ?? data['username'] ?? "User";
        // Get profile image from different possible field names
        String? imageUrl =
            data['profile_photo_url'] ??
            data['avatar'] ??
            data['profile_image'] ??
            data['photo'];

        debugPrint('🎯 Raw image URL from API: $imageUrl');

        if (imageUrl != null && imageUrl.isNotEmpty) {
          // If it's already a full URL, keep it
          if (imageUrl.startsWith('http')) {
            debugPrint('✅ Full URL detected: $imageUrl');
            final separator = imageUrl.contains('?') ? '&' : '?';
            userProfileImage =
                '$imageUrl${separator}t=${DateTime.now().millisecondsSinceEpoch}';
          } else {
            // It's a relative path - convert it
            debugPrint('🔄 Relative path detected: $imageUrl');
            String cleanPath = imageUrl;
            if (cleanPath.startsWith('/')) {
              cleanPath = cleanPath.substring(1);
            }
            if (cleanPath.startsWith('storage/')) {
              cleanPath = cleanPath.substring(8);
            }
            // use AuthService.storageBaseUrl for current domain
            userProfileImage =
                '${_authService.storageBaseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
          }
          debugPrint('✅ Final home profile image URL: $userProfileImage');
        } else {
          debugPrint('⚠️ No profile image URL found in API response');
          userProfileImage = null;
        }
      });
    }
  }

  void _onTabChanged(int index) {
    setState(() => _selectedIndex = index);
    // Refresh user data when navigating to profile tab and back
    if (index == 3) {
      // Profile tab - will be updated there
    } else if (index == 0) {
      // Home tab - refresh profile data to show updated image
      _fetchUserData();
    }
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
            userProfileImage: userProfileImage,
          ),
          const MyBookingScreen(),
          const MessageScreen(),
          const ProfileScreen(),
        ],
      ),
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
  final String userName;
  final String? userProfileImage;

  const HotelHomeScreen({
    super.key,
    required this.onProfileClick,
    required this.userName,
    this.userProfileImage,
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
                onRefresh: () async =>
                    setState(() => _hotelsFuture = _apiService.fetchHotels()),
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
                        if (hotels.isNotEmpty)
                          _buildRecommendedItem(context, hotels.first),
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

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        GestureDetector(
          onTap: widget.onProfileClick,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage:
                  (widget.userProfileImage != null &&
                      widget.userProfileImage!.isNotEmpty)
                  ? NetworkImage(widget.userProfileImage!)
                  : const NetworkImage('https://i.pravatar.cc/150?img=11'),
              child:
                  (widget.userProfileImage == null ||
                      widget.userProfileImage!.isEmpty)
                  ? const Icon(Icons.person, size: 24, color: Colors.grey)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, ${widget.userName}!",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                "Find your perfect stay",
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(
            () => _showNotificationDropdown = !_showNotificationDropdown,
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchInput(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      readOnly: true,
      onTap: () => Navigator.push(context, AppRoutes.toSearch()),
      decoration: InputDecoration(
        hintText: "Search hotels, villas, resorts...",
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 24),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    ),
  );

  Widget _buildPopularList(BuildContext context, List<Hotel> hotels) =>
      SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: hotels.length,
          itemBuilder: (context, index) =>
              _buildPopularCard(context, hotels[index]),
        ),
      );

  Widget _buildPopularCard(BuildContext context, Hotel hotel) => Container(
    width: 220,
    margin: const EdgeInsets.only(right: 16),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${hotel.price.toStringAsFixed(0)} /night',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            hotel.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildRecommendedItem(BuildContext context, Hotel hotel) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
      child: Row(
        children: [
          // ✅ FIXED: Changed imageUrl to image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SafeNetworkImage(url: hotel.image, width: 80, height: 80),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.location,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${hotel.rating}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "\$${hotel.price.toStringAsFixed(0)} /night",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  /// Previously a horizontal carousel.  Now shows the full list
  /// vertically so that the user can scroll down to see all items.
  Widget _buildBestTodayList(BuildContext context, List<Hotel> hotels) {
    // if you want to filter for a "best today" flag, apply it here.
    final list = hotels; // .where((h) => h.isBestToday).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildBestTodayCard(context, list[index]),
      ),
    );
  }

  Widget _buildBestTodayCard(BuildContext context, Hotel hotel) => Container(
    margin: const EdgeInsets.only(right: 16),
    padding: const EdgeInsets.all(12),
    width: MediaQuery.of(context).size.width * 0.85,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () => Navigator.of(context).push(AppRoutes.toDetail(hotel)),
      child: Row(
        children: [
          // ✅ FIXED: Changed imageUrl to image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SafeNetworkImage(url: hotel.image, width: 75, height: 75),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.location,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "${hotel.rating}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${hotel.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
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

  Widget _buildNotificationDropdown(BuildContext context) => Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showNotificationDropdown = false),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        alignment: Alignment.topRight,
        child: Container(
          margin: const EdgeInsets.only(top: 75, right: 16),
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text("Booking Confirmed"),
                subtitle: Text("Your stay is ready!"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AllNotificationsScreen(),
                    ),
                  ),
                  child: const Text("View All"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _sectionHeader(String title) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Implement see all functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('See all $title coming soon!')),
            );
          },
          child: Text(
            "See All",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLocationBanner() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.primary.withOpacity(0.05),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
    ),
    child: InkWell(
      onTap: () {
        // TODO: Implement location change
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location change coming soon!')),
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_pin,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Phnom Penh, Cambodia",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
        ],
      ),
    ),
  );

  Widget _buildCategoryRow() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        _buildCategoryItem("All", Icons.apps, true),
        _buildCategoryItem("Hotels", Icons.hotel, false),
        _buildCategoryItem("Villas", Icons.villa, false),
        _buildCategoryItem("Apartments", Icons.apartment, false),
        _buildCategoryItem("Resorts", Icons.pool, false),
        _buildCategoryItem("Cabins", Icons.cabin, false),
      ],
    ),
  );

  Widget _buildCategoryItem(String title, IconData icon, bool isSelected) =>
      Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
}
