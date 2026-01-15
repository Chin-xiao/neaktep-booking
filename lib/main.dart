import 'package:flutter/material.dart';
import 'profile_screen.dart'; // Ensure this matches your file name

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainNavigation(),
      ),
    );

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
      const MessageScreen(), // This now correctly points to massage_screen.dart
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3056D3),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "My Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
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
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  ),
                ),
                title: const Text("Chhorm Bunthai", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
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
              _buildRecommendedItem("Serenity Sands", "Honolulu, HI", "\$270", 4.0, "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400"),
              const SizedBox(height: 24),
              _sectionHeaderWithAction("Hotel Near You", "Open Map"),
              const SizedBox(height: 16),
              _buildMapPlaceholder(),
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
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200)),
      child: Icon(icon, size: 20));

  Widget _sectionHeader(String title) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Text("See All", style: TextStyle(color: Colors.blue))]);

  Widget _sectionHeaderWithAction(String title, String action) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(action, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))]);

  Widget _buildLocationBanner() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.blue.withValues(alpha:  0.05), borderRadius: BorderRadius.circular(16)),
        child: const Row(children: [
          Icon(Icons.location_pin, color: Color(0xFF0D47A1)),
          SizedBox(width: 12),
          Expanded(child: Text("Change Location for nearby villas")),
          Icon(Icons.arrow_forward_ios, size: 16),
        ]),
      );

  Widget _buildPopularList() => SizedBox(
        height: 280,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildPopularCard("The Horizon Retreat", "\$480", "Los Angeles, CA", "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500"),
            _buildPopularCard("Opal Grove Inn", "\$190", "San Diego, CA", "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500"),
          ],
        ),
      );

  Widget _buildPopularCard(String name, String price, String location, String imgUrl) => Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
      child: Stack(children: [
        Image.network(imgUrl, height: double.infinity, width: double.infinity, fit: BoxFit.cover),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues( alpha: .8)]))),
        const Positioned(top: 12, right: 12, child: CircleAvatar(backgroundColor: Colors.white, radius: 15, child: Icon(Icons.favorite, color: Colors.red, size: 16))),
        Positioned(bottom: 15, left: 15, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(location, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Row(children: [Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const Text("/night", style: TextStyle(color: Colors.white70, fontSize: 10))])]))
      ]));

  Widget _buildCategoryRow() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _buildCategoryItem("All", Icons.apps, true),
          _buildCategoryItem("Villas", Icons.villa, false),
          _buildCategoryItem("Hotels", Icons.hotel, false),
        ]),
      );

  Widget _buildCategoryItem(String title, IconData icon, bool isSelected) => Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isSelected ? const Color(0xFF3056D3) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Row(children: [Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey), const SizedBox(width: 8), Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w500))]));

  Widget _buildRecommendedItem(String name, String location, String price, double rating, String imgUrl) => Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(imgUrl, width: 80, height: 80, fit: BoxFit.cover)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Row(children: [const Icon(Icons.location_on, size: 14, color: Colors.grey), Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12))]), const SizedBox(height: 4), Text("$price /night", style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold))])),
        Row(children: [const Icon(Icons.star, color: Colors.amber, size: 18), Text(" $rating", style: const TextStyle(fontWeight: FontWeight.bold))])
      ]));

  Widget _buildMapPlaceholder() => Container(
      height: 180, width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: const DecorationImage(image: NetworkImage('https://i.stack.imgur.com/HILXv.png'), fit: BoxFit.cover)));

  Widget _buildBestTodayList(BuildContext context) => SizedBox(
      height: 120,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildBestTodayCard(context, "Phnom Penh 51 Hotel", "Daun Penh, PP", "\$150", "\$200", "https://images.unsplash.com/photo-1551882547-ff43c63faf7c?w=400"),
          ]));

  Widget _buildBestTodayCard(BuildContext context, String name, String loc, String price, String old, String img) => Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(img, width: 70, height: 70, fit: BoxFit.cover)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(loc, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Row(children: [Text(price, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Text(old, style: const TextStyle(color: Colors.red, fontSize: 10, decoration: TextDecoration.lineThrough))])
        ]))
      ]));
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
        title: const Text("My Booking", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15)),
              child: const Row(children: [Icon(Icons.search, color: Colors.grey), Expanded(child: TextField(decoration: InputDecoration(hintText: "Search...", border: InputBorder.none, contentPadding: EdgeInsets.only(left: 10))))]),
            ),
            const SizedBox(height: 20),
            _buildToggleButton(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildBookingCard("Aston Vill Hotel", "Michikoton", "\$120", 4.7, "12-14 Nov", "2 Guests", "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400"),
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
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
        child: Row(children: [
          Expanded(child: GestureDetector(onTap: () => setState(() => isBookedSelected = true), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: isBookedSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(25)), child: Text("Booked", style: TextStyle(fontWeight: FontWeight.bold, color: isBookedSelected ? Colors.black : Colors.grey))))),
          Expanded(child: GestureDetector(onTap: () => setState(() => isBookedSelected = false), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: !isBookedSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(25)), child: Text("History", style: TextStyle(fontWeight: FontWeight.bold, color: !isBookedSelected ? Colors.black : Colors.grey))))),
        ]),
      );

  Widget _buildBookingCard(String n, String l, String p, double r, String d, String g, String img) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(img, width: 80, height: 100, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold)), Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(" $r")])]),
            Text(l, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            Text(p, style: const TextStyle(color: Color(0xFF3056D3), fontWeight: FontWeight.bold)),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Dates: $d", style: const TextStyle(fontSize: 11)), Text("Guests: $g", style: const TextStyle(fontSize: 11))]),
          ])),
        ]),
      );
}

// --- SEARCH SCREEN ---
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  RangeValues _priceRange = const RangeValues(0, 80);
  bool _instantBook = false;
  String _selectedLocation = "Sen Sok";
  int _selectedRating = 4;
  final Map<String, bool> _facilities = {"Wifi": false, "Pool": true, "Tv": false, "Laundry": true};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)), title: const Text("Search", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), centerTitle: true),
      body: Column(children: [
        _buildSearchBar(context),
        const SizedBox(height: 10),
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          _buildLargeSearchCard("Citadines Flatiron", "Street 102, PP", "\$290", 4.9, "3 bed", "2 bath", "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=600"),
        ])),
      ]),
    );
  }

  Widget _buildSearchBar(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)), child: Row(children: [const Icon(Icons.search, color: Colors.grey), const Expanded(child: TextField(decoration: InputDecoration(hintText: "Search...", border: InputBorder.none))), IconButton(icon: const Icon(Icons.tune, color: Color(0xFF3056D3)), onPressed: () => _showFilterModal(context))])),
      );

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Center(child: Text("Filter By", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
              RangeSlider(values: _priceRange, max: 1000, activeColor: const Color(0xFF3056D3), onChanged: (v) => setModalState(() => _priceRange = v)),
              SwitchListTile(title: const Text("Instant Book"), value: _instantBook, activeThumbColor: const Color(0xFF3056D3), onChanged: (v) => setModalState(() => _instantBook = v)),
              const Text("Location", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(spacing: 10, children: ["Sen Sok", "Daun Penh", "Phnom Penh"].map((l) => ChoiceChip(label: Text(l), selected: _selectedLocation == l, onSelected: (s) => setModalState(() => _selectedLocation = l), selectedColor: const Color(0xFF3056D3))).toList()),
              const SizedBox(height: 20),
              const Text("Facilities", style: TextStyle(fontWeight: FontWeight.bold)),
              ..._facilities.keys.map((f) => CheckboxListTile(title: Text(f), value: _facilities[f], activeColor: const Color(0xFF3056D3), onChanged: (v) => setModalState(() => _facilities[f] = v!))),
              const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [5, 4, 3, 2, 1].map((r) => FilterChip(label: Text("$r ⭐"), selected: _selectedRating == r, onSelected: (s) => setModalState(() => _selectedRating = r))).toList()),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3056D3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: () => Navigator.pop(context), child: const Text("Apply Filter", style: TextStyle(color: Colors.white)))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeSearchCard(String n, String l, String p, double r, String bd, String bt, String img) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.network(img, height: 200, width: double.infinity, fit: BoxFit.cover)), Positioned(top: 15, left: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), Text(" $r", style: const TextStyle(color: Colors.white, fontSize: 12))])))]),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(n, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(p, style: const TextStyle(color: Color(0xFF3056D3), fontSize: 18, fontWeight: FontWeight.bold))]),
        Text(l, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Row(children: [const Icon(Icons.king_bed_outlined, color: Colors.grey, size: 18), Text(" $bd • "), const Icon(Icons.bathtub_outlined, color: Colors.grey, size: 18), Text(" $bt")]),
        const SizedBox(height: 24),
      ]);
}

// --- MESSAGE SCREEN ---
class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of chat data
    final List<Map<String, String>> chatData = [
      {
        "name": "Phin ChanSophal",
        "message": "Thank you! 😊",
        "time": "7:12 Am",
        "unread": "3",
        "image": "https://i.pravatar.cc/150?img=11"
      },
      {
        "name": "Ms. Sokry",
        "message": "Yes! please take a order",
        "time": "9:28 Am",
        "unread": "0",
        "image": "https://i.pravatar.cc/150?img=5"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Message", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.separated(
        itemCount: chatData.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F1F1)),
        itemBuilder: (context, index) {
          final chat = chatData[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(chat['image']!),
            ),
            title: Text(chat['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(chat['message']!, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(chat['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 5),
                if (chat['unread'] != "0")
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(chat['unread']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}