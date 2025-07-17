import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_page.dart';
import 'settings.dart';
import 'inapp_webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'pumps_map_screen.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main.dart';
import 'notification_service.dart';
import 'package:flutter/material.dart';
import 'chatscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'inapp_webview_screen.dart'; // Import the file you created
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_history_screen.dart';// Import your screen here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  await initializeDateFormatting('en_IN', null);
// optional for debug
  runApp(const MyApp());
  await NotificationService.init();

}

/// Change these to suit your brand colours.
const Color kJioBpGreen   = Color(0xFF00993A);
const Color kTileBg       = Color(0xFFE7F9EB);
const Duration kSlideDur  = Duration(milliseconds: 1);
const Duration kAutoPlay  = Duration(seconds: 5);

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jio-BP Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Montserrat'),
      navigatorObservers: [routeObserver],
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // ───────────────────────────── Drawer / Icon animation
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _menuCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

  // ───────────────────────────── Hero-image carousel
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  late final Timer _timer;
  late AnimationController _chatController;
  late Animation<Offset> _chatOffsetAnimation;
  bool _isChatVisible = true;



  final List<String> _heroImages = [
    'assets/images/pump_1.jpg',
    'assets/images/pump_2.jpg',
    'assets/images/pump_3.jpg',
  ];

  final List<String> _heroTitles = [
    'Additivised Fuel',
    'Friendly Staff',
    'Eco-Friendly Recharge',
  ];

  final List<String> _heroSubtitles = [
    'Our Fuels are specially formulated to\nkeep your Engines Clean',
    'Always ready to assist you\nwith a smile and expert care',
    'Recharge your EV quickly and cleanly,\nwherever you are',
  ];


  @override
  void initState() {

    super.initState();
    _requestNotificationPermission();
    _startAutoPlay();
     initFirebaseMessaging();
    _checkSessionTimeout();
    _refreshLoginTime();
    _loadChatVisibility();


    _chatController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _chatOffsetAnimation = Tween<Offset>(
      begin: Offset(1.5, 0), // start off-screen to right
      end: Offset(0, 0),     // slide into position
    ).animate(CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOutBack,
    ));

// Start the chatbox animation after a small delay
    Future.delayed(Duration(milliseconds: 1000), () {
      _chatController.forward();
    });


    String userPhoneNumber = "8237703637";
    saveSessionToFirestore(userPhoneNumber);
    FirebaseMessaging.instance.getToken().then((token) {
      print("🔑 FCM Registration Token: $token");
    });

  }
  bool _isUserInteracting = false;

  Timer? countdownTimer;
  String countdownText = "";
  bool notified5MinLeft = false;

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> _refreshLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
    print("⏱️ loginTime updated from HomePage");
  }
// Optionally request notification permission (for Android 13+)
  void _requestNotificationPermission() async {
    await messaging.requestPermission();
  }

  void _loadChatVisibility() {
    setState(() {
      _isChatVisible = true; // Always show on app reopen
    });
  }



  void initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 🔑 Get FCM token
    String? token = await messaging.getToken();
    print("🔑 FCM Token: $token");

    // 🔔 Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Got a message in foreground!');
      if (message.notification != null) {
        print('🧾 Title: ${message.notification!.title}');
        print('💬 Body: ${message.notification!.body}');
      }
    });

    // 🔙 When app opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 App opened from notification!');
    });
  }




  void _checkSessionTimeout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? exitTimeStr = prefs.getString('ExitTime');
    if (exitTimeStr != null) {
      DateTime loginTime = DateTime.parse(exitTimeStr);
      DateTime now = DateTime.now();
      Duration diff = now.difference(loginTime);
      int remaining = 6 * 60 - diff.inSeconds; // remaining seconds

      if (remaining > 0) {
        Future.delayed(Duration(seconds: remaining), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    }
  }

  Future<void> saveSessionToFirestore(String phoneNumber) async {
    final firestore = FirebaseFirestore.instance;

    await firestore.collection('sessions').add({
      'phone': phoneNumber,
      'startTime': FieldValue.serverTimestamp(),
      'smsSent': false,
    });

    print("✅ Session saved to Firestore for $phoneNumber");
  }



  void _startAutoPlay() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!_isUserInteracting && mounted) {
        int nextpage = (_currentPage + 1) % _heroImages.length;
        if (_pageCtrl.hasClients) {
          _pageCtrl.animateToPage(
            nextpage,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
        _currentPage = nextpage;
      }
    }
  }
  @override
  void dispose() {
    _timer.cancel();
    _menuCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
    _chatController.dispose();

  }

  // ───────────────────────────── Helpers
  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8F5E9),
            ),
            child: Icon(icon, size: 32, color: Color(0xFF00993A)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
               // 👈 This makes it bold
            ),
          ),

        ],
      ),
    );
  }




  Widget _priceTile(String fuel, String price) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: kTileBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
            children: [
            Text(fuel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: 150,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 0),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),

              child: Column(
                children: [
                  const Text('Current Prices',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(price,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: kJioBpGreen)),
                      const SizedBox(width: 2),
                      Icon(Icons.currency_rupee, size: 22, color: kJioBpGreen),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ───────────────────────────── Build
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Exit App"),
            content: const Text(
              "Do you really want to exit?",
              style: TextStyle(fontSize: 18), // 🔼 Increase font size here
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  DateTime now = DateTime.now();
                  await prefs.setString('exitTime', now.toIso8601String());

                  await NotificationService.cancelReminderNotification();
                  await NotificationService.scheduleReminderNotification(now);

                  print("🚪 User exited via back — scheduling notification at $now");

                  if (Platform.isAndroid) {
                    SystemNavigator.pop(); // ✅ exit app
                  } else if (Platform.isIOS) {
                    exit(0); // ✅ exit iOS
                  }
                },
                child: const Text("Yes"),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // ✅ exits app properly on Android
          } else if (Platform.isIOS) {
            exit(0); // ✅ exits app on iOS (not recommended for production)
          }
        }

        return false; // Don't pop manually; we're handling it
      },


      child:  Scaffold(
      key: _scaffoldKey,
        drawer: buildAppDrawer(),

        backgroundColor: Colors.white,

      // ✅ FIXED TOP APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Material(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    splashRadius: 26,
                    iconSize: 30,
                    icon: Icon(
                      Icons.menu,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (_scaffoldKey.currentState!.isDrawerOpen) {
                        Navigator.of(context).pop();
                        _menuCtrl.reverse();
                      } else {
                        _scaffoldKey.currentState!.openDrawer();
                        _menuCtrl.forward();
                      }
                    },
                  ),
                  const Spacer(),
                  Image.asset('assets/images/logo.png', height: 50),
                ],
              ),
            ),
          ),
        ),
      ),

      // ✅ SCROLLABLE BODY
        body: Stack(
            children: [SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Hero image carousel ───────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: GestureDetector(
                onHorizontalDragStart: (_) => _isUserInteracting = true,
                onHorizontalDragEnd: (_) => _isUserInteracting = false,
                onTapDown: (_) => _isUserInteracting = true,
                onTapUp: (_) => _isUserInteracting = false,
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _heroImages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (_, i) => Image.asset(
                    _heroImages[i],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ── Tagline ─────────────────────────────────
            Container(
              color: kTileBg,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(
                    _heroTitles[_currentPage],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _heroSubtitles[_currentPage],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // ── Quick actions ───────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickAction(Icons.local_gas_station, 'Book\nRefill', () {Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PumpsMapScreen(isRefillMode: true)),
                );
                }),
                _quickAction(
                  Icons.location_on,
                  'Pumps\nNear me',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PumpsMapScreen()),
                    );
                  },
                ),

                _quickAction(Icons.ev_station, 'Book\nRecharge', () {}),
              ],
            ),
          ),

            const SizedBox(height: 0),
            // ── Price tiles ─────────────────────────────
            Row(
              children: [
                _priceTile('Petrol', '105.87'),
                _priceTile('Diesel', '90.50'),
              ],
            ),
            const SizedBox(height: 30),



            // ── Section Subtitle ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Jio-bp Services",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // ── Fuel Cards ──────────────────────────────
              SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FuelCard(
                    title: "Fuels At Jio-bp",
                    content: "Designed to enhance Engine performance and keep it clean.",
                    iconData: Icons.local_gas_station,
                    link: "https://www.jiobp.com/products-and-services/fuels-at-jio-bp",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/fuels-at-jio-bp",
                            title: "Fuels At Jio-bp",
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "Castrol",
                    content: "High-performance fuels for premium cars.",
                    iconData: Icons.oil_barrel,
                    link: "https://www.jiobp.com/products-and-services/castrol",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/castrol",
                            title: "Castrol",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "CNG",
                    content: "Environmentally friendly Compressed Natural Gas.",
                    iconData: Icons.local_gas_station,
                    link: "https://www.jiobp.com/products-and-services/cng",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/cng",
                            title: "CNG",
                          ),
                        ),
                      );
                    },

                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "Flexipay",
                    content: "Pay flexibly with Jio-bp’s payment services.",
                    iconData: Icons.payment,
                    link: "https://www.jiobp.com/products-and-services/flexipay",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/flexipay",
                            title: "Flexipay",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "Wildbean Café",
                    content: "Grab a coffee and snacks while on the go.",
                    iconData: Icons.local_cafe,
                    link: "https://www.jiobp.com/products-and-services/wild-bean-cafe",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/wild-bean-cafe",
                            title: "wildbean Cafe",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "EV Charging",
                    content: "Fast electric vehicle charging across India.",
                    iconData: Icons.ev_station,
                    link: "https://www.jiobp.com/products-and-services/EV-charging",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/EV-charging",
                            title: "EV Charging",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "AIR BP-Jio",
                    content: "Jet fuel solutions from Jio-bp and Air BP.",
                    iconData: Icons.flight_takeoff,
                    link: "https://www.jiobp.com/products-and-services/airbp_aviation",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/airbp_aviation",
                            title: "AIR BP-JIO",
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  _FuelCard(
                    title: "Reward Meter",
                    content: "Earn and redeem loyalty points on every refill.",
                    iconData: Icons.card_giftcard,
                    link: "https://www.jiobp.com/products-and-services/RewardMeter-Program",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InAppWebViewScreen(
                            url: "https://www.jiobp.com/products-and-services/RewardMeter-Program",
                            title: "Reward Meter",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // ── Section Subtitle ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "Beyond Fuel at Jio-bp",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _CafeCard(
                logoPath: 'assets/images/wildbean.png',
                title: "Wild Bean Café",
                content:
                "Wild Bean Café is more than just a café – it’s part of our mission to redefine fuel station experiences in India.",
                link: "https://www.jiobp.com/products-and-services/wild-bean-cafe",
              ),

            ),



            const SizedBox(height: 80), // Space above bottom nav bar
          ],
        ),
      ),
              Positioned(
                bottom: 40,
                right: 20,
                child: SlideTransition(
                  position: _chatOffsetAnimation,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🔶 Show this only if _isChatVisible is true
                      if (_isChatVisible)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF00993A),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.support_agent, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              const Text("Chat with Tia", style: TextStyle(color: Colors.white)),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('isChatVisible', false);
                                  setState(() {
                                    _isChatVisible = false;
                                  });
                                },
                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(width: 10),

                      // 🟡 Always show the Tia avatar
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  ChatScreen()),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage("assets/images/tia.png"),
                        ),
                      ),

                    ],
                  ),
                ),
              ),


            ],
        ),



      // ✅ FIXED BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        color: kTileBg,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home, 'Home', onTap: () {
              // Your home navigation code
            }),


            _bottomItem(Icons.map, 'Map', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PumpsMapScreen()),
              );
            }),
            _bottomItem(Icons.settings, 'Settings', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // 🔁 No `const` if not needed
              );
            }),

            _bottomItem(Icons.person, 'Profile', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // 🔁 No `const` if not needed
              );
            }),
          ],
        ),
      ),


    ),
    );
  }





  Future<void> openPumpsNearMe() async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=jiobp+pumps+near+me');

    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }


  Widget _bottomItem(IconData icon, String label,
      {double iconSize = 30, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: label == 'Home' ? kJioBpGreen : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: label == 'Home' ? Colors.white : kJioBpGreen,
            ),
          ),

        ],
      ),
    );
  }
  Widget buildAppDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Text('Menu', style: TextStyle(fontSize: 24)),
          ),
          const ListTile(
              leading: Icon(Icons.settings), title: Text('Settings')),
          const ListTile(
              leading: Icon(Icons.info), title: Text('About')),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              countdownText,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }

}



class _FuelCard extends StatelessWidget {
  final String title, content, link;
  final IconData iconData;
  final VoidCallback onTap;

  const _FuelCard({
    required this.title,
    required this.content,
    required this.iconData,
    required this.link,
    required this.onTap,
    super.key,
  });

  void _launchURL(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(
          url: url,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 330,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: SizedBox(
        height: 140,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔵 Circular Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF00993A),
              child: Icon(
                iconData,
                size: 55,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            // 📝 Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 60),
                  GestureDetector(
                    onTap: onTap,
                    child: const Text(
                      "Know more --->",
                      style: TextStyle(
                        color: Color(0xFF00993A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}






class _CafeCard extends StatelessWidget {
  final String logoPath; // path to your logo image (PNG, SVG, etc.)
  final String title;
  final String content;
  final String link;

  const _CafeCard({
    required this.logoPath,
    required this.title,
    required this.content,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFFCFBEA),

        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🍩 Logo on the left
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(0),
            child: Image.asset(
              logoPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),

          // 📝 Text content on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00993A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () => _launchURL(context, link),
                  child: Text(
                    "Know more --->",
                    style: TextStyle(
                      color: Color(0xFF00993A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _launchURL(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(
          url: url,
          title: title, // Use `this.title` if needed
        ),
      ),
    );
  }


}




