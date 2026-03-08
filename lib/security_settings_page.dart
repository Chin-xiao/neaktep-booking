import 'package:flutter/material.dart';

class SecuritySettingsPage extends StatelessWidget {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Security")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Add change password logic here
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Face ID / Biometrics"),
            value: true,
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
