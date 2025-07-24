import 'package:flutter/material.dart';
import '../services/pump_service.dart';
import '../models/petrol_pump_model.dart';
import 'package:dotted_line/dotted_line.dart';

class SearchAndFilterScreen extends StatefulWidget {
  const SearchAndFilterScreen({super.key});

  @override
  State<SearchAndFilterScreen> createState() => _SearchAndFilterScreenState();
}

class _SearchAndFilterScreenState extends State<SearchAndFilterScreen> {
  String _searchQuery = "";
  int _selectedFilterIndex = 0;
  int _selectedIndex = 0;


void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0:
      Navigator.pushReplacementNamed(context, '/home');
      break;
    case 1:
      Navigator.pushReplacementNamed(context, '/map');
      break;
    case 2:
      Navigator.pushReplacementNamed(context, '/saved');
      break;
    case 3:
      Navigator.pushReplacementNamed(context, '/profile');
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    final allPumps = PumpService().pumps;

    List<PetrolPump> filteredPumps = _searchQuery.isEmpty
        ? allPumps
        : allPumps.where((pump) => pump.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Apply selected filter
    if (_selectedFilterIndex == 0) {
      filteredPumps.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_selectedFilterIndex == 2) {
      filteredPumps.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/images/Brand.png', width: 230, height: 90),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD0C9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_pin, color: Color(0xFFAF0505), size: 16),
                      SizedBox(width: 6, height: 35),
                      Text("GPM, Bandra", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFAF0505))),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 5),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: const Icon(Icons.search),
                hintText: "Search...",
                filled: true,
                fillColor: const Color(0xFFE9E9E9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),

            const SizedBox(height: 22),

            // Filter Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButton(text: 'Nearest Pumps', isActive: _selectedFilterIndex == 0, onTap: () => setState(() => _selectedFilterIndex = 0)),
                FilterButton(text: 'Lowest Crowd', isActive: _selectedFilterIndex == 1, onTap: () => setState(() => _selectedFilterIndex = 1)),
                FilterButton(text: 'Highly Rated', isActive: _selectedFilterIndex == 2, onTap: () => setState(() => _selectedFilterIndex = 2)),
              ],
            ),

            const SizedBox(height: 15),
            const Divider(color: Color.fromARGB(255, 186, 186, 186), thickness: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 30),

            if (filteredPumps.isEmpty)
              const Center(child: Text("No stations found.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))
            else
              Column(
                children: filteredPumps.map((pump) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_gas_station_outlined, size: 28, color: Colors.black87),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, size: 18, color: Colors.black54),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pump.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              if (pump.rating != null)
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.orange, size: 16),
                                    const SizedBox(width: 2),
                                    Text("${pump.rating!.toStringAsFixed(1)}", style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Text(
                          pump.distance < 1000
                              ? "${pump.distance.toStringAsFixed(0)} m"
                              : "${(pump.distance / 1000).toStringAsFixed(1)} km",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.groups, color: Colors.deepOrangeAccent),
                      ],
                    ),
                  );
                }).toList(),
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
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({super.key, required this.text, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFE5E0) : const Color(0xFFE9E9E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFFAF0505) : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
