import 'package:flutter/material.dart';
import 'home.dart'; // Adjust the path if needed
import 'package:url_launcher/url_launcher.dart';
import 'main.dart'; // Adjust the path if needed
import 'settings.dart';
import 'pumps_map_screen.dart';
import 'add_payment_method_screen.dart';
import 'inapp_webview_screen.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final String userName = "Sahil Tiwatne";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _menuCtrl;

  @override
  void initState() {
    super.initState();
    _menuCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuCtrl.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Navigate back to HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          return false; // prevent default pop
        },
    child:  Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🟢 Curved green header with AppBar and avatar
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 260,
                decoration: const BoxDecoration(
                  color: Color(0xFF00993A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),

              // ✅ AppBar content
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          splashRadius: 26,
                          iconSize: 30,
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.menu_home,
                            progress: _menuCtrl,
                            color: Colors.white,
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

                      ],
                    ),
                  ),
                ),
              ),

              // 👤 Avatar and greeting
              Positioned(
                top: 105,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 43,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Hi ! $userName",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // List items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // padding on left and right
            child: Column(
              children: [
                _profileOption(
                  context,
                  Icons.person_outline,
                  "User Info & Settings",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),


                _profileOption(context, Icons.history, "History & Activity"),

                _profileOption(
                  context,
                  Icons.account_balance_wallet_outlined,
                  "Wallets & Payments",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
                    );
                  },
                ),


                _profileOption(
                  context,
                  Icons.card_giftcard,
                  "Rewards & Offers",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InAppWebViewScreen(
                          url: "https://www.jiobp.com/products-and-services/jio-bp-4ever", // 🟢 Replace with your actual link
                          title: "Rewards & Offers",
                        ),
                      ),
                    );
                  },
                ),

                _profileOption(context, Icons.power_settings_new, "Log Out", isLogout: true),
              ],
            ),
          )

        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        color: const Color(0xFFE7F9EB),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, false, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            }),
            _navItem(Icons.map, false, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PumpsMapScreen()),
              );
            },),

            _navItem(Icons.settings, false, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }),

            _navItem(Icons.person, true),
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

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch $url");
    }
  }

  // 🔹 Profile option tile
  Widget _profileOption(BuildContext context, IconData icon, String title, {
    bool isLogout = false,
    VoidCallback? onTap, // ✅ Add this
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.black,
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        if (isLogout) {
          _showLogoutDialog(context);
        } else {
          if (onTap != null) {
            onTap(); // ✅ Run the custom navigation
          }
        }
      },
    );
  }




  Widget _navItem(IconData icon, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00993A) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 30,
          color: isActive ? Colors.white : const Color(0xFF00993A),
        ),
      ),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Do you want to Log out?',style: TextStyle(
          fontSize: 18, // 👈 Increase this for bigger text
          fontWeight: FontWeight.w400,
        ),),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          // ❌ NO Button
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF00993A), // Jio-bp green
            ),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(), // Close dialog
          ),

          // ✅ YES Button
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await prefs.setBool('atLoginScreen', true); // Mark that user is now at login

              Navigator.of(context).pop(); // Close dialog first
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()), // Replace with main.dart if needed
              );
            },

          )
        ],
      ),
    );
  }

}
