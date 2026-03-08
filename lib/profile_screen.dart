import 'package:flutter/material.dart';
import 'package:neak_booking_app/services/auth_service.dart';
import 'package:neak_booking_app/screens/login_screen.dart';
import 'package:neak_booking_app/EditProfilePage.dart';
import 'package:neak_booking_app/card_management_page.dart';
import 'package:neak_booking_app/security_settings_page.dart';
import 'package:neak_booking_app/all_notifications_screen.dart';
import 'package:neak_booking_app/screens/help_support_page.dart';
import 'package:neak_booking_app/components/authenticated_image_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? profileImageUrl;
  String totalBookings = "0";
  String totalReviews = "0";
  String averageRating = "0.0";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final data = await AuthService().getUserProfile();
      if (mounted) {
        if (data != null) {
          debugPrint('📥 Profile Data from API: $data');
          setState(() {
            userName = data['name'] ?? "User Name";
            userEmail = data['email'] ?? "email@example.com";

            // Extract stats
            final bookingsRaw =
                data['total_bookings'] ?? data['bookings_count'] ?? 0;
            totalBookings = bookingsRaw.toString();

            final reviewsRaw =
                data['total_reviews'] ?? data['reviews_count'] ?? 0;
            totalReviews = reviewsRaw.toString();

            final ratingRaw = data['average_rating'] ?? data['rating'] ?? 0.0;
            if (ratingRaw is double) {
              averageRating = ratingRaw.toStringAsFixed(1);
            } else if (ratingRaw is int) {
              averageRating = ratingRaw.toString() + ".0";
            } else {
              averageRating =
                  double.tryParse(ratingRaw.toString())?.toStringAsFixed(1) ??
                  "0.0";
            }

            // Try different possible field names for profile image
            String? imageUrl =
                data['profile_photo_url'] ??
                data['avatar'] ??
                data['profile_image'] ??
                data['photo'];

            debugPrint('🎯 Raw image URL from API: $imageUrl');

            // Handle URLs that might already have query parameters
            if (imageUrl != null && imageUrl.isNotEmpty) {
              // If it's already a full URL, keep it
              if (imageUrl.startsWith('http')) {
                debugPrint('✅ Full URL detected: $imageUrl');
                // Just add cache busting
                final separator = imageUrl.contains('?') ? '&' : '?';
                profileImageUrl =
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
                profileImageUrl =
                    '${AuthService().storageBaseUrl}/$cleanPath?t=${DateTime.now().millisecondsSinceEpoch}';
              }
              debugPrint('✅ Final profile image URL: $profileImageUrl');
            } else {
              debugPrint('⚠️ No profile image URL found in API response');
              profileImageUrl = null;
            }
            isLoading = false;
          });
          debugPrint(
            "✅ Profile updated: name=$userName, email=$userEmail, image=$profileImageUrl, bookings=$totalBookings, reviews=$totalReviews, rating=$averageRating",
          );
        } else {
          setState(() {
            userName = "Guest";
            userEmail = "Not logged in";
            isLoading = false;
          });
          debugPrint("❌ No profile data received");
        }
      }
    } catch (e) {
      debugPrint("❌ Profile Fetch Error: $e");
      if (mounted) {
        setState(() {
          userName = "Error";
          userEmail = "Check connection";
          isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: userName,
          currentEmail: userEmail,
          profileImageUrl: profileImageUrl,
        ),
      ),
    );

    // Always refresh profile data when returning from edit page
    setState(() => isLoading = true);
    _fetchUserData();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
            ListTile(
              leading: const Text("🇺🇸", style: TextStyle(fontSize: 24)),
              title: const Text("English (US)"),
              trailing: const Icon(Icons.check_circle, color: Colors.blue),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text("🇰🇭", style: TextStyle(fontSize: 24)),
              title: const Text("Khmer"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildNetworkImage(String url) {
    debugPrint("📸 Building authenticated network image from URL: $url");
    try {
      return AuthenticatedNetworkImageProvider(url);
    } catch (e) {
      debugPrint("❌ Error building image provider: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              color: const Color(0xFF6366F1),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // --- Premium Gradient Header with SliverAppBar ---
                  SliverAppBar(
                    expandedHeight: 300,
                    floating: false,
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6366F1),
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Background Pattern
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      center: Alignment.center,
                                      radius: 1.5,
                                      colors: [
                                        Colors.white,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Profile Content
                            SafeArea(
                              child: SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Profile Image with Glow Effect
                                    GestureDetector(
                                      onTap: _navigateToEditProfile,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 25,
                                              spreadRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Colors.white
                                                  .withOpacity(0.2),
                                              backgroundImage:
                                                  (profileImageUrl != null &&
                                                      profileImageUrl!
                                                          .isNotEmpty)
                                                  ? _buildNetworkImage(
                                                      profileImageUrl!,
                                                    )
                                                  : null,
                                              child:
                                                  (profileImageUrl == null ||
                                                      profileImageUrl!.isEmpty)
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 60,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.edit,
                                                  color: Color(0xFF6366F1),
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // User Info
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),

                                    // Verified Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.verified_user,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Verified Account",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Enhanced Stats Section ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _buildEnhancedStatItem(
                              totalBookings,
                              "Bookings",
                              Icons.calendar_month,
                            ),
                            Container(
                              width: 1,
                              height: 80,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            _buildEnhancedStatItem(
                              totalReviews,
                              "Reviews",
                              Icons.star,
                            ),
                            Container(
                              width: 1,
                              height: 80,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            _buildEnhancedStatItem(
                              averageRating,
                              "Rating",
                              Icons.trending_up,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Account Settings ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section Header
                          _buildSectionHeader(
                            "Account Settings",
                            Icons.account_circle,
                          ),

                          _buildEnhancedSettingItem(
                            Icons.person_outline_rounded,
                            "Edit Profile",
                            "Manage your account info",
                            const Color(0xFFE0E7FF),
                            const Color(0xFF6366F1),
                            onTap: _navigateToEditProfile,
                          ),
                          _buildEnhancedSettingItem(
                            Icons.credit_card_rounded,
                            "Payment Methods",
                            "Manage your cards",
                            const Color(0xFFFFF7ED),
                            const Color(0xFFF59E0B),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CardManagementPage(),
                              ),
                            ),
                          ),
                          _buildEnhancedSettingItem(
                            Icons.shield_outlined,
                            "Security",
                            "Password and privacy",
                            const Color(0xFFF0FDF4),
                            const Color(0xFF10B981),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SecuritySettingsPage(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Preferences Header
                          _buildSectionHeader("Preferences", Icons.settings),

                          _buildEnhancedSettingItem(
                            Icons.notifications_none_rounded,
                            "Notifications",
                            "Manage your alerts",
                            const Color(0xFFFAF5FF),
                            const Color(0xFF8B5CF6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AllNotificationsScreen(),
                              ),
                            ),
                          ),
                          _buildEnhancedSettingItem(
                            Icons.language_rounded,
                            "Language",
                            "Choose your language",
                            const Color(0xFFF0FDFA),
                            const Color(0xFF14B8A6),
                            onTap: _showLanguageSelector,
                          ),
                          _buildEnhancedSettingItem(
                            Icons.help_outline_rounded,
                            "Help & Support",
                            "Get help when needed",
                            const Color(0xFFF0F4FF),
                            const Color(0xFF3B82F6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportPage(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Premium Logout Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.32),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showLogoutDialog(context),
                                borderRadius: BorderRadius.circular(20),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Log Out",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 18, top: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: title == "Account Settings"
                  ? const Color(0xFFE0E7FF)
                  : const Color(0xFFFAF5FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: title == "Account Settings"
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF8B5CF6),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSettingItem(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.08), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Log Out"),
        content: const Text(
          "Are you sure you want to log out? Your session will be ended.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              bool success = await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text(
              "Yes, Log Out",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
