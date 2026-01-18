import 'package:flutter/material.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool isBookedSelected = true; // State for the toggle switch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {}, // Handle back navigation
        ),
        title: const Text(
          "My Booking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 1. Search Bar with Filter Icon
            _buildSearchBar(),
            const SizedBox(height: 20),
            // 2. Custom Toggle (Booked / History)
            _buildToggleSwitch(),
            const SizedBox(height: 20),
            // 3. Scrollable List of Bookings
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildBookingCard(
                    "The Aston Vill Hotel",
                    "Veum Point, Michikoton",
                    "\$120",
                    4.7,
                    "12 - 14 Nov 2024",
                    "2 Guests (1 Room)",
                    "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400",
                  ),
                  _buildBookingCard(
                    "Mystic Palms",
                    "Palm Springs, CA",
                    "\$230",
                    4.0,
                    "20 - 25 Nov 2024",
                    "1 Guests (1 Room)",
                    "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400",
                  ),
                  _buildBookingCard(
                    "Elysian Suites",
                    "San Diego, CA",
                    "\$320",
                    3.8,
                    "01 - 05 Dec 2024",
                    "2 Guests (1 Room)",
                    "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400",
                  ),
                  // Add more booking cards here
                  _buildBookingCard(
                    "Ocean Breeze Resort",
                    "Miami Beach, FL",
                    "\$450",
                    4.9,
                    "10 - 15 Dec 2024",
                    "3 Guests (2 Rooms)",
                    "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?w=400",
                  ),
                  _buildBookingCard(
                    "Mountain Escape Lodge",
                    "Aspen, CO",
                    "\$380",
                    4.5,
                    "18 - 22 Dec 2024",
                    "4 Guests (2 Rooms)",
                    "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=400",
                  ),
                  _buildBookingCard(
                    "City Lights Hotel",
                    "New York, NY",
                    "\$500",
                    4.8,
                    "25 - 30 Dec 2024",
                    "2 Guests (1 Room)",
                    "https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=400",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
          Icon(Icons.tune, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
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
                  boxShadow: isBookedSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
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
                  boxShadow: !isBookedSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
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
  }

  Widget _buildBookingCard(
    String name,
    String loc,
    String price,
    double rate,
    String dates,
    String guests,
    String img,
  ) {
    return Container(
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
            child: Image.network(
              img,
              width: 90,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          " $rate",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    Text(
                      loc,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: price,
                    style: const TextStyle(
                      color: Color(0xFF3056D3),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    children: const [
                      TextSpan(
                        text: " /night",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Dates",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      dates,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Guest",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      guests,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
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
}
