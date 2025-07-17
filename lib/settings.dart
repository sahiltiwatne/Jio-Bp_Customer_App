import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_project/WalletScreen.dart';
import 'home.dart'; // Adjust path as needed
import 'main.dart'; // Adjust path as needed
import 'profile_page.dart';
import 'pumps_map_screen.dart';
import 'FavouritePumpsScreen.dart';
import 'inapp_webview_screen.dart';
import 'add_payment_method_screen.dart';
import 'profile.dart';
import 'reset_password.dart';
import 'bookings_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true; // switch state

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00993A),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(fontSize: 22, color: Colors.white)),
        leading: const Icon(Icons.settings, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Account Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              buildListTile(
                "Edit Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
              ),
          buildListTile(
            "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                );
              },
          ),

              buildListTile(
                "Add Payment Method",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddPaymentMethodScreen()),
                  );
                },
              ),

              buildSwitchTile("Push Notifications", _notificationsEnabled, (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              }),

              const SizedBox(height: 20),
              const Text('More',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),
              buildListTile("Manage My Bookings",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyBookingsScreen()));

              }),
              buildListTile("My Registered Vehicles"),
              buildListTile(
                "Favourite Fuel Stations",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FavouritePumpsScreen()),
                  );
                },
              ),

              buildListTile("Wallet Information",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WalletScreen()));

              }),
              buildListTile("Language Preferences"),
              buildListTile(
                "About Us",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InAppWebViewScreen(
                        url: "https://www.jiobp.com/who-we-are", // Replace with your actual URL
                        title: "About Us",
                      ),
                    ),
                  );
                },
              ),

              buildListTile("Terms and Conditions"),
              buildListTile("Privacy Policy"),
              buildListTile(
                "Contact Us",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InAppWebViewScreen(
                        url: "https://www.jiobp.com/connect-with-us", // Replace with your actual URL
                        title: "Contact Us",
                      ),
                    ),
                  );
                },
              ),
              buildListTile("Log Out", isLogout: true,  onTap: () => _showLogoutDialog(context),),
            ],
          ),
        ),
      ),
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
            _navItem(Icons.settings, true),
            _navItem(Icons.person, false, onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }),
          ],
        ),
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

          ),
        ],
      ),
    );
  }

  // Regular tile
  Widget buildListTile(String title, {bool isLogout = false, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isLogout ? Colors.red : Colors.grey,
      ),
      onTap: onTap, // ✅ Use the passed function here
    );
  }



  // Toggle switch tile
  Widget buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 0),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00993A),
      ),
      onTap: () {
        onChanged(!value); // toggles switch when tile is tapped
      },
    );
  }

  // Bottom nav item
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

  // Maps button
  Future<void> openPumpsNearMe() async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=jiobp+pumps+near+me');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Launch external link
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print("Could not launch $url");
    }
  }
}
