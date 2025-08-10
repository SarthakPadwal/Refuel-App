import 'package:flutter/material.dart';
import 'package:dotted_line/dotted_line.dart';
import '../models/petrol_pump_model.dart';

class EvStationDetailScreen extends StatelessWidget {
  final PetrolPump pump;

  const EvStationDetailScreen({super.key, required this.pump});

  Color getCrowdColor(CrowdLevel? level) {
    switch (level) {
      case CrowdLevel.green:
        return Colors.green;
      case CrowdLevel.yellow:
        return Colors.yellow;
      case CrowdLevel.orange:
        return Colors.orange;
      case CrowdLevel.red:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  int getCrowdPeopleCount(CrowdLevel? level) {
    switch (level) {
      case CrowdLevel.green:
        return 1;
      case CrowdLevel.yellow:
        return 2;
      case CrowdLevel.orange:
        return 3;
      case CrowdLevel.red:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DottedLine(
              dashLength: 7,
              dashGapLength: 4,
              lineThickness: 1.5,
              dashColor: Color(0xFFFF725E),
            ),
          ),
          BottomNavigationBar(
            currentIndex: 2,
            onTap: (index) {
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
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Color(0xFFFF725E),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
              BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  pump.imageUrl.startsWith('http')
                      ? Image.network(
                    pump.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/images/station.jpg',
                            width: double.infinity, height: 250, fit: BoxFit.cover),
                  )
                      : Image.asset(
                    pump.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  pump.name,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.bookmark_border, color: Colors.black54),
                      ],
                    ),


                    const SizedBox(height: 4),
                    Text(
                      pump.address,
                      style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 120, 120, 120)),
                    ),
                    const SizedBox(height: 14),

                    // Price Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("  EV ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(" "),
                              Text(
                                pump.status,
                                style: TextStyle(
                                  color: pump.status.toLowerCase().contains('open') ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, thickness: 0.8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pump.distance < 1000
                                    ? "Distance: ${pump.distance.toStringAsFixed(0)} metre"
                                    : "Distance: ${(pump.distance / 1000).toStringAsFixed(1)} km",
                                style: const TextStyle(fontSize: 15),
                              ),
                              Row(
                                children: List.generate(
                                  getCrowdPeopleCount(pump.crowd),
                                      (index) => Icon(Icons.people, color: getCrowdColor(pump.crowd), size: 25),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              const Text("Estimate Time : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text("${pump.estimatedTime.toStringAsFixed(0)} min", style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    const Text("Current Prices", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Container(

                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text("EV", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(""),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 150),

                      ],
                    ),

                    const SizedBox(height: 16),
                    const Text("Amenities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        amenityChip("24 Hours", Icons.access_time),
                        amenityChip("WIFI", Icons.wifi),
                        amenityChip("Restroom ", Icons.store),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text("Rating", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            const Icon(Icons.star, color: Color.fromARGB(255, 255, 213, 0), size: 20),
                            const SizedBox(width: 2),
                            Text(pump.rating?.toStringAsFixed(1) ?? "N/A", style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget amenityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
