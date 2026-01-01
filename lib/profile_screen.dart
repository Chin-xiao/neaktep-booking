import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Info Section
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
            const SizedBox(height: 15),
            const Text("UserAccount", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("@user", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // Settings List
            _buildSettingItem(Icons.credit_card, "Your Card"),
            _buildSettingItem(Icons.security, "Security"),
            _buildSettingItem(Icons.notifications_none, "Notification"),
            _buildSettingItem(Icons.language, "Languages"),
            _buildSettingItem(Icons.help_outline, "Help and Support"),

            const SizedBox(height: 40),
            TextButton(
              onPressed: () {},
              child: const Text("Logout", style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}