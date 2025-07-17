import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'favourites_repository.dart';
import 'AmenitiesScreen.dart';
import 'book_refill_screen.dart';

class PumpInfo {
  final LatLng location;
  final String address;
  final String subLocality;
  final double distance;
  final List<String> amenities;

  PumpInfo({
    required this.location,
    required this.address,
    required this.subLocality,
    required this.distance,
    required this.amenities,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PumpInfo &&
              runtimeType == other.runtimeType &&
              location.latitude == other.location.latitude &&
              location.longitude == other.location.longitude &&
              address == other.address;

  @override
  int get hashCode =>
      location.latitude.hashCode ^
      location.longitude.hashCode ^
      address.hashCode;
}


class PumpsMapScreen extends StatefulWidget {
  final bool isRefillMode;
  const PumpsMapScreen({super.key, this.isRefillMode = false});

  @override
  State<PumpsMapScreen> createState() => _PumpsMapScreenState();
}

class _PumpsMapScreenState extends State<PumpsMapScreen> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final TextEditingController _searchController = TextEditingController();


  Set<Marker> pumpMarkers = {};
  List<PumpInfo> sortedPumpList = [];
  List<PumpInfo> favoritePumps = [];


  List<LatLng> pumpLocations = [];
  Map<String, List<LatLng>> cityPumps = {
    "Mumbai": [LatLng(19.123928053110916, 73.0066363506427),
      LatLng(19.103462073261465, 73.0157605628816),
      LatLng(19.123628203564877, 73.00655700966671),
      LatLng(19.12602698469732, 73.00822317016251),

      LatLng(19.059999114942414, 73.00540043959498),
      LatLng(19.069821578837736, 72.92861139802159),
      LatLng(19.125471205313023, 72.937849177459),

      LatLng(19.052873920179604, 72.87808700004909),
      LatLng(19.038289449053828, 72.86078773969064),
      LatLng(19.258245684819176, 72.9776746340044),

      LatLng(19.055948341060606, 72.87537118473924),
      LatLng(19.048176209448876, 72.85820072591672),
      LatLng(19.0125256202577, 72.83934488486143),

      LatLng(18.946155567368148, 72.82153659053144),
      LatLng(18.96597029132836, 72.82886941760849),
      LatLng(19.151123744402824, 72.81315621672908),


      LatLng(19.145186205757796, 72.81839395035556),
      LatLng(19.108566665847405, 72.84039243158672),
      LatLng(19.1494258217451, 72.86280726242848),

      LatLng(19.00461361667763, 73.10941955166938),
      LatLng(19.30287869174684, 72.86539895364363),

      LatLng(19.395835130616103, 72.90749914499777),
      LatLng(19.476250797126063, 72.88065324800272),],


    "Delhi": [LatLng(28.848424044338984, 77.09121647739748),
      LatLng(28.81878717796074, 77.14242032203254),
      LatLng(28.75628182681775, 77.1332767783477),
      LatLng(28.74185219595808, 77.1863093317197),
      LatLng(28.718600264934256, 77.18173755987729),
      LatLng(28.685718022076344, 77.05464230265817),
      LatLng(28.646406183958383, 77.0692719725539),
      LatLng(28.59936836003868, 77.05714308775963),
      LatLng(28.60298549785225, 76.99809157979072),
      LatLng(28.56319013589245, 77.12718092279252),


      LatLng(28.700853633033287, 77.41985647772677),
      LatLng(28.91077072197815, 76.92032329619413),
      LatLng(28.57545545856687, 76.80752548100935),
      LatLng(28.45179666804441, 77.03419537628544),],

    "Chennai" : [LatLng(13.055903392562033, 80.27950851336936),
      LatLng(13.061852061141517, 80.24694000937527),
      LatLng(13.025166324579587, 80.09427514690287),
      LatLng(13.249161461285112, 80.29070393661735),
      LatLng(13.200613522471473, 80.29681053111625),
      LatLng(13.155029123354272, 80.22454916287931),
      LatLng(13.149082706559948, 80.1736608753885),
      LatLng(13.134216033939534, 80.08918631815379),
      LatLng(12.780125700362623, 80.01692494991686),
      LatLng(12.850587034119268, 80.23269128887785),],

    "Kolkata" : [LatLng(22.672577292095657, 88.3260912829141),
      LatLng(22.737187559566813, 88.34531735527607),
      LatLng(22.689049470366655, 88.4496874623839),
      LatLng(22.628219288819782, 88.47028682562886),
      LatLng(22.602865427792135, 88.4579272076819),
      LatLng(22.59779409485592, 88.5210985882998),
      LatLng(22.534386679700376, 88.40436886324498),
      LatLng(22.522970249659075, 88.61585565922663),
      LatLng(22.430335491231716, 88.27390622936018),
      LatLng(23.000379333683764, 88.15580321342237),],

    "Bangalore": [
      LatLng(13.003862980992254, 77.6615333442934),
      LatLng(13.004532016489495, 77.50978470172214),
      LatLng(13.057380112266708, 77.51596451069562),
      LatLng(13.09817913874063, 77.4081611763803),
      LatLng(13.12559763849548, 77.603168481766),
      LatLng(13.181094010726289, 77.63132094486745),
      LatLng(13.136296711312449, 77.74049757006577),
      LatLng(13.090153634127764, 77.7885627509707),
      LatLng(12.954349353491278, 77.68762587107035),

      LatLng(12.811106020115014, 77.4143409853538),
      LatLng(12.937619550153046, 77.6594734079689),
      LatLng(12.859978599688041, 77.6663398623839),
      LatLng(12.806419109654934, 77.7247047249113),
      LatLng(13.088816024607556, 77.79336926906119),
    ],
    // Add more as needed
  };

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(position.latitude, position.longitude);

    String defaultCity = "Mumbai";
    if (cityPumps.containsKey(defaultCity)) {
      pumpLocations = cityPumps[defaultCity]!;
    }
    _loadPumpMarkers();
  }

  Future<Marker> createMarkerWithAddress(LatLng position, String markerId, String address) async {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: address),
    );
  }

  Future<void> _loadPumpMarkers() async {
    if (_currentPosition == null) return;

    List<PumpInfo> pumpList = [];
    Set<Marker> markers = {};

    for (int i = 0; i < pumpLocations.length; i++) {
      LatLng pos = pumpLocations[i];
      double dist = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );

      String address = "Jio-bp Pump";
      String subLocality = "Jio-bp Pump";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;

          subLocality = (p.subLocality != null && p.subLocality!.isNotEmpty)
              ? p.subLocality!
              : "Jio-bp Pump";

          address =
          "${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}, ${p.postalCode ?? ''}";
        }
      } catch (e) {
        print("Address fetch error: $e");
      }

      markers.add(await createMarkerWithAddress(pos, 'pump$i', address));
      pumpList.add(PumpInfo(location: pos, address: address,subLocality: subLocality, distance: dist, amenities: ["Drinking Water","Air Service", "Washroom", "Wi-Fi","Cafe", "Repair", "Store" ],));
    }

    pumpList.sort((a, b) => a.distance.compareTo(b.distance));

    setState(() {
      pumpMarkers = markers;
      sortedPumpList = pumpList;
    });
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );
    }
  }

  Future<LatLng?> _getCoordinatesFromAddress(String address) async {
    final apiKey = 'AIzaSyAAQXXshtdQ29ZomdR4uioiaBPFRmnXPUg'; // 🔑 Replace with your API key
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      final location = data['results'][0]['geometry']['location'];
      return LatLng(location['lat'], location['lng']);
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isRefillMode ? "Select Pump for Refill" : "Jio-bp Pumps Near Me",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00993A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: pumpMarkers,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: "Search city or location...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
                onSubmitted: (value) async {
                  // First check if it's a known city
                  if (cityPumps.containsKey(value)) {
                    setState(() {
                      pumpLocations = cityPumps[value]!;
                    });
                    _loadPumpMarkers(); // reload markers
                    mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(pumpLocations.first, 13),
                    );
                  } else {
                    // Use Geocoding API to get LatLng from locality
                    final coords = await _getCoordinatesFromAddress(value);
                    if (coords != null) {
                      // Now filter pumps nearby (within 10 km radius)
                      List<LatLng> nearby = [];

                      cityPumps.forEach((city, pumps) {
                        for (var loc in pumps) {
                          double distance = Geolocator.distanceBetween(
                              coords.latitude, coords.longitude,
                              loc.latitude, loc.longitude);
                          if (distance < 10000) { // 10 km radius
                            nearby.add(loc);
                          }
                        }
                      });

                      if (nearby.isNotEmpty) {
                        setState(() {
                          pumpLocations = nearby;
                        });
                        _loadPumpMarkers();
                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(coords, 13),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No pumps found near $value')),
                        );
                      }
                    }
                  }
                },

              ),
            ),
          ),
          Positioned(
            bottom: 110,
            right: 10,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: const Color(0xFF00993A),
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sortedPumpList.length,
              itemBuilder: (context, index) {
                final pump = sortedPumpList[index];

                return StatefulBuilder(
                  builder: (context, setCardState) {
                    bool isFavorite = FavouritesRepository.contains(pump); // ✅ Moved inside builder

                    return GestureDetector(
                      onTap: () => mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(pump.location, 16),
                      ),
                      child: Container(
                        width: 300,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
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
                            // 🧡 Row with subLocality and heart icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pump.subLocality,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setCardState(() {
                                      if (FavouritesRepository.contains(pump)) {
                                        FavouritesRepository.remove(pump);
                                      } else {
                                        FavouritesRepository.add(pump);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    FavouritesRepository.contains(pump)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: FavouritesRepository.contains(pump)
                                        ? Colors.red
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),

                            // 🏠 Address, distance, etc. (unchanged)
                            const SizedBox(height: 4),
                            Text(
                              pump.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.route, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${(pump.distance / 1000).toStringAsFixed(1)} km away",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: widget.isRefillMode
                                    ? [
                                  // Refill Mode: Order, Amenities, Navigate
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookRefillScreen(pump: pump),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.local_gas_station, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Order", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AmenitiesScreen(pump: pump),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.local_gas_station, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Amenities", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      final lat = pump.location.latitude;
                                      final lng = pump.location.longitude;
                                      final url = Uri.parse(
                                          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
                                      launchUrl(url, mode: LaunchMode.externalApplication);
                                    },
                                    icon: Icon(Icons.navigation, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Navigate", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                ]
                                    : [
                                  // Normal Mode: Amenities, Navigate, Order
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AmenitiesScreen(pump: pump),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.local_gas_station, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Amenities", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      final lat = pump.location.latitude;
                                      final lng = pump.location.longitude;
                                      final url = Uri.parse(
                                          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
                                      launchUrl(url, mode: LaunchMode.externalApplication);
                                    },
                                    icon: Icon(Icons.navigation, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Navigate", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookRefillScreen(pump: pump),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.local_gas_station, size: 18, color: Color(0xFF00993A)),
                                    label: Text("Order", style: TextStyle(color: Color(0xFF00993A))),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
