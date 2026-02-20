import 'package:flutter/material.dart';
import 'package:neak_booking_app/services/auth_service.dart';
import 'package:neak_booking_app/screens/login_screen.dart';
import 'package:neak_booking_app/EditProfilePage.dart'; 
import 'package:neak_booking_app/card_management_page.dart';
import 'package:neak_booking_app/security_settings_page.dart';
import 'package:neak_booking_app/all_notifications_screen.dart';
import 'package:neak_booking_app/screens/help_support_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? profileImageUrl; 
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
          setState(() {
            userName = data['name'] ?? "User Name";
            userEmail = data['email'] ?? "email@example.com";
            profileImageUrl = data['profile_photo_url']; 
            isLoading = false;
          });
        } else {
          setState(() {
            userName = "Guest";
            userEmail = "Not logged in";
            isLoading = false;
          });
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          currentName: userName,
          currentEmail: userEmail,
          profileImageUrl: profileImageUrl,
        ),
      ),
    );

    if (result == true) {
      setState(() => isLoading = true);
      _fetchUserData(); 
    }
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Slightly cooler background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : RefreshIndicator(
            onRefresh: _fetchUserData,
            color: Colors.blue,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // --- Modern Header Section ---
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                      boxShadow: [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 10))
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _navigateToEditProfile, 
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.red.shade300, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[100],
                                  backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                                      ? NetworkImage(profileImageUrl!) 
                                      : null,
                                  child: (profileImageUrl == null || profileImageUrl!.isEmpty)
                                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName, 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail, 
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Settings Sections ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Account Management"),
                        _buildSettingItem(
                          Icons.person_outline_rounded, "Edit Profile", const Color(0xFFE3F2FD), Colors.blue, 
                          onTap: _navigateToEditProfile
                        ),
                        _buildSettingItem(
                          Icons.credit_card_rounded, "Your Card", const Color(0xFFFFF3E0), Colors.orange, 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CardManagementPage()))
                        ),
                        _buildSettingItem(
                          Icons.shield_outlined, "Security", const Color(0xFFE8F5E9), Colors.green, 
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecuritySettingsPage()))
                        ),
                        
                        const SizedBox(height: 16),
                        _buildSectionHeader("General"),
                        _buildSettingItem(
                          Icons.notifications_none_rounded, "Notification", const Color(0xFFF3E5F5), Colors.purple,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AllNotificationsScreen())),
                        ),
                        _buildSettingItem(
                          Icons.language_rounded, "Languages", const Color(0xFFE0F2F1), Colors.teal,
                          onTap: _showLanguageSelector,
                        ),
                        _buildSettingItem(
                          Icons.help_outline_rounded, "Help and Support", const Color(0xFFE8EAF6), Colors.indigo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportPage())),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // --- Modern Logout Button ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => _showLogoutDialog(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFFEBEE), width: 2),
                          backgroundColor: const Color(0xFFFFFBFC),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "Log Out", 
                          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title, 
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade600, letterSpacing: 0.5)
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1A1C1E))),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 24),
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
        content: const Text("Are you sure you want to log out? Your session will be ended."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              bool success = await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                }
              }
            },
            child: const Text("Yes, Log Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}