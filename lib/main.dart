import 'package:flutter/material.dart';

void main() => runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HotelHomeScreen(),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER SECTION
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
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
                      _buildHeaderIcon(Icons.search),
                      const SizedBox(width: 8),
                      _buildHeaderIcon(Icons.notifications_none),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. LOCATION BANNER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_pin, color: Color(0xFF0D47A1)),
                      SizedBox(width: 12),
                      Expanded(child: Text("You Can Change Your Location to show nearby villas")),
                      Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionHeader("Most Popular"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 280,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPopularCard("The Horizon Retreat", "\$480", "Los Angeles, CA", "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500"),
                      _buildPopularCard("Opal Grove Inn", "\$190", "San Diego, CA", "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=500"),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionHeader("Recommended for you"),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryItem("All", Icons.apps, true),
                      _buildCategoryItem("Villas", Icons.villa, false),
                      _buildCategoryItem("Hotels", Icons.hotel, false),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildRecommendedItem("Serenity Sands", "Honolulu, HI", "\$270", 4.0, "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400"),
                _buildRecommendedItem("Elysian Suites", "San Diego, CA", "\$320", 3.8, "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400"),

                const SizedBox(height: 24),
                _sectionHeaderWithAction("Hotel Near You", "Open Map"),
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.stack.imgur.com/HILXv.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                _sectionHeader("Best Today 🔥"),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Pass context here!
                      _buildBestTodayCard(context, "Phnom Penh 51 Hotel", "Daun Penh, Phnom Penh", "\$150", "\$200", "https://images.unsplash.com/photo-1551882547-ff43c63faf7c?w=400"),
                      _buildBestTodayCard(context, "Sun & Moon Hotel", "Riverside, Phnom Penh", "\$120", "\$180", "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400"),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3056D3),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: "My Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Message"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildBestTodayCard(BuildContext context, String name, String location, String price, String oldPrice, String imgUrl) {
    return Container(
      // context works now because we passed it in!
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
            child: Image.network(imgUrl, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(price, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Text(oldPrice, style: const TextStyle(color: Colors.red, fontSize: 10, decoration: TextDecoration.lineThrough)),
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
