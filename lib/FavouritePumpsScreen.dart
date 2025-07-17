import 'package:flutter/material.dart';
import 'favourites_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class FavouritePumpsScreen extends StatefulWidget {
  const FavouritePumpsScreen({super.key});

  @override
  State<FavouritePumpsScreen> createState() => _FavouritePumpsScreenState();
}

class _FavouritePumpsScreenState extends State<FavouritePumpsScreen> {
  @override
  Widget build(BuildContext context) {
    final favoritePumps = FavouritesRepository.favourites;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Favourite Pumps", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00993A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoritePumps.isEmpty
          ? const Center(child: Text("No favourite pumps yet."))
          : ListView.builder(
        itemCount: favoritePumps.length,
        itemBuilder: (context, index) {
          final pump = favoritePumps[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🟢 Pump Info with Dustbin on Top Right
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(pump.subLocality),
                    subtitle: Text(pump.address),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          FavouritesRepository.remove(pump);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Removed from favourites")),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔽 Row with Order, Navigation, Amenities — scrollable to avoid overflow
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // 🛒 Order
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Order functionality coming soon!")),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart, color: Color(0xFF00993A)),
                          label: const Text("Order", style: TextStyle(color: Color(0xFF00993A))),
                        ),

                        const SizedBox(width: 0),

                        // 📍 Navigation
                        TextButton.icon(
                          onPressed: () {
                            final lat = pump.location.latitude;
                            final lng = pump.location.longitude;
                            final url = Uri.parse(
                              "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
                            );
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                          icon: const Icon(Icons.navigation, color: Color(0xFF00993A)),
                          label: const Text("Navigation", style: TextStyle(color: Color(0xFF00993A))),
                        ),

                        const SizedBox(width: 0),

                        // 🛠 Amenities
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Amenities coming soon!")),
                            );
                          },
                          icon: const Icon(Icons.local_gas_station, color: Color(0xFF00993A)),
                          label: const Text("Amenities", style: TextStyle(color: Color(0xFF00993A))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        },
      ),
    );
  }
}
