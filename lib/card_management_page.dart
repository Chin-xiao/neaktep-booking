import 'package:flutter/material.dart';

class CardManagementPage extends StatelessWidget {
  const CardManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment Methods")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No saved cards found", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {}, 
              child: const Text("Add New Card"),
            )
          ],
        ),
      ),
    );
  }
}