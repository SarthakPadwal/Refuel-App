import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dotted_line/dotted_line.dart';
import 'dart:async';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  String userName = "Not provided";
  String userEmail = "Not provided";
  String userPhone = "Not provided";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        setState(() {
          userName = userData['name'] ?? 'No name provided';
          userEmail = userData['email'] ?? 'No email provided';
          userPhone = userData['phone'] ?? 'Not provided';
          isLoading = false;
        });
      } else {
        await _fetchUserProfile();
      }
    } catch (e) {
      setState(() {
        userName = 'Error loading data';
        userEmail = 'Please try again';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }
  Future<void> _fetchUserProfile() async {
    try {
      final response = await http
          .get(
        Uri.parse('${ApiService.baseUrl}/profile'),
        headers: await ApiService.getHeaders(),
      )
          .timeout(
        const Duration(seconds: 3), // ⏱ set your timeout here
        onTimeout: () {
          throw TimeoutException("Profile request timed out");
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(data));

        setState(() {
          userName = data['name'] ?? 'No name provided';
          userEmail = data['email'] ?? 'No email provided';
          userPhone = data['phone'] ?? 'Not provided';
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  Future<void> _logout() async {
    try {
      await ApiService.logout();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

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
        Navigator.pushReplacementNamed(context, '/saved');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.arrow_back, color: Colors.black),
                    Text(
                      "Profile",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(0xFFAF0505)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(userEmail),
                    Text(userPhone),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildIconText(Icons.favorite, "Favourite\nStations"),
                        buildIconText(Icons.navigation, "Direction\nHistory"),
                        buildIconText(Icons.lock_outline, "Privacy\nSettings"),
                        buildIconText(Icons.help_outline, "Help &\nSupport"),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, color: Color(0xFFAF0505)),
                          label: const Text("Edit Profile", style: TextStyle(color: Color(0xFFAF0505))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFAF0505)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAF0505),
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Icon(Icons.logout, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Settings",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    buildSettingTile(FontAwesomeIcons.user, "Personal Information"),
                    buildSettingTile(FontAwesomeIcons.shieldHalved, "Security Status"),
                    buildSettingTile(Icons.language, "Language Preference"),
                    buildSettingTile(Icons.notifications, "Notification Setting"),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
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

  Widget buildIconText(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Icon(icon, size: 20, color: const Color(0xFFAF0505)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }


  Widget buildSettingTile(IconData icon, String title) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD0C9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFAF0505)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }
}
