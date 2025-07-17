import 'package:flutter/material.dart';
import 'pumps_map_screen.dart';
import 'favourites_repository.dart';
import 'package:url_launcher/url_launcher.dart';

// Replace this with your actual Pump model
class Pump {
  final String subLocality;
  final String address;
  final double distance;
  final List<String> amenities;

  Pump({
    required this.subLocality,
    required this.address,
    required this.distance,
    required this.amenities,
  });
}

bool isPumpOpenNow() {
  final now = TimeOfDay.now();
  const openTime = TimeOfDay(hour: 4, minute: 0);  // 4 AM
  const closeTime = TimeOfDay(hour: 2, minute: 0);// 2 AM (next day)

  // If it's after 4 AM or before 2 AM, pump is open
  return now.hour >= openTime.hour || now.hour < closeTime.hour;
}


class AmenitiesScreen extends StatelessWidget {
  final PumpInfo pump;




  const AmenitiesScreen({super.key, required this.pump});

  @override
  Widget build(BuildContext context) {
    const petrolPrice = 105.83;
    const dieselPrice = 90.83;
    final bool isOpen = isPumpOpenNow();



    final Map<String, IconData> amenityIcons = {
      "Drinking Water": Icons.water_drop,
      "Air Service": Icons.tire_repair,
      "Lubricants": Icons.oil_barrel,
      "Washroom": Icons.wc,
      "EV Charging": Icons.ev_station,
      "Cafe": Icons.local_cafe,
      "Repair": Icons.car_repair,
      "Store": Icons.store,
      "Wi-Fi": Icons.wifi,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Amenities",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF00993A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔼 Top image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.asset(
                    'assets/images/amenities.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 🔽 White card container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏷 Sublocality & Open badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pump.subLocality,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              if (FavouritesRepository.contains(pump)) {
                                FavouritesRepository.remove(pump);
                              } else {
                                FavouritesRepository.add(pump);
                              }
                              // Trigger rebuild
                              (context as Element).markNeedsBuild();
                            },
                            child: Icon(
                              FavouritesRepository.contains(pump)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 4),

                    // 📍 Distance
                    Row(
                      children: [
                        Text(
                          "${(pump.distance / 1000).toStringAsFixed(1)} km away",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isOpen ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isOpen ? Color(0xFF00993A) : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOpen ? "Open" : "Closed",
                          style: TextStyle(
                            color: isOpen ? Color(0xFF00993A) : Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      ],
                    ),


                    const SizedBox(height: 14),

                    // 💰 Fuel Prices
                    const Text(
                      "Current fuel Price",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_gas_station, color: Colors.green),
                            const SizedBox(width: 6),
                            Text("Petrol: ₹${petrolPrice.toStringAsFixed(2)}"),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.local_gas_station_outlined, color: Colors.green),
                            const SizedBox(width: 6),
                            Text("Diesel: ₹${dieselPrice.toStringAsFixed(2)}"),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            final lat = pump.location.latitude;
                            final lng = pump.location.longitude;
                            final url = Uri.parse(
                              "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
                            );
                            launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                          icon: const Icon(Icons.navigation, size: 25, color: Color(0xFF00993A)),
                          label: const Text(
                            "Navigate",
                            style: TextStyle(color: Color(0xFF00993A)),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Order functionality coming soon!")),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart, size: 25, color: Color(0xFF00993A)),
                          label: const Text(
                            "Order",
                            style: TextStyle(color: Color(0xFF00993A)),
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 20),

                    // 🛠️ Amenities Section
                    const Text(
                      "Discover the amenities at our Mobility Station",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic amenities
                    GridView.count(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: pump.amenities.map((amenityName) {
                        final icon = amenityIcons[amenityName] ?? Icons.help_outline;
                        return AmenityTile(icon: icon, label: amenityName);
                      }).toList(),
                    ),

                    const SizedBox(height: 20), // ✅ Prevents bottom clipping
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ⭐️ "Rate this Pump" Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: RateCard(),
              ),
            ),

            const SizedBox(height: 24), // Bottom space for full scroll
          ],
        ),
      ),
    );
  }

}

class AmenityTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const AmenityTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: Colors.green),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class RateCard extends StatefulWidget {
  @override
  _RateCardState createState() => _RateCardState();
}

class _RateCardState extends State<RateCard> {
  int _selectedStars = 0;

  void _submitRating() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thanks for rating us!"),
        content: const Row(
          children: [
            Icon(Icons.emoji_emotions, color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Text("Your feedback means a lot."),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    setState(() {
      _selectedStars = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rate this Pump",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return IconButton(
              icon: Icon(
                starIndex <= _selectedStars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _selectedStars = starIndex;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedStars > 0) {
                _submitRating();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a rating before submitting.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00993A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "Rate",
              style: TextStyle(
                color: _selectedStars > 0 ? Colors.white : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )


      ],
    );
  }
}

