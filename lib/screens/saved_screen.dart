import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        break; // Already on saved
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🔹 Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back, color: Colors.black),
                  Text(
                    'Saved Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Icon(Icons.settings, color: Colors.black),
                ],
              ),
            ),

            const Divider(
              color: Color.fromARGB(255, 186, 186, 186),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            const SizedBox(height: 16),

            // 🔹 Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  filled: true,
                  fillColor: const Color(0xFFE9E9E9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildFilterButton('All', isActive: true),
                const SizedBox(width: 15),
                buildFilterButton('By Fuel Type'),
                const SizedBox(width: 15),
                buildFilterButton('By Nearest'),
                const SizedBox(width: 15),
                const Icon(Icons.tune, color: Colors.black54, size: 27),
              ],
            ),

            const SizedBox(height: 24),

            const Divider(
              color: Color(0xFFDDDDDD),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),

            // You can add your saved items list here
            const Expanded(
              child: Center(
                child: Text(
                  'No saved items found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),

       bottomNavigationBar: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 1),
      child: DottedLine(
        dashLength: 7,
        dashGapLength: 4,
        lineThickness: 1.5,
        dashColor: Color(0xFFFF725E), // Your orange color
      ),
    ),
    BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    ),
  ],
),
    );
  }

  Widget buildFilterButton(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFFD0C9) : const Color(0xFFE9E9E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFFAF0505) : Colors.black,
        ),
      ),
    );
  }
}
