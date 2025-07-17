import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart'; // for SystemNavigator.pop()
import 'notification_service.dart';
import 'package:first_project/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'permissions.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'chatscreen.dart';
import 'pumps_map_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📨 Background message: ${message.notification?.title}");
}



// Console Firebase : 'https://console.firebase.google.com'
void main() async {





  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  await requestExactAlarmPermission();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('en_IN', null);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? loginTimeStr = prefs.getString('loginTime');

  print("🟢 isLoggedIn: $isLoggedIn");
  print("📅 loginTimeStr: $loginTimeStr");

  Widget initialScreen = LoginPage(); // default

  if (isLoggedIn && loginTimeStr != null) {
    DateTime loginTime = DateTime.parse(loginTimeStr);
    DateTime now = DateTime.now();
    Duration diff = now.difference(loginTime);

    if (diff.inMinutes < 6) {
      print("✅ Session valid, going to HomePage");
      initialScreen = HomePage();

      // reschedule notification if needed
      final notifyAt = loginTime.add(const Duration(minutes: 5));
      await NotificationService.cancelReminderNotification();
      await NotificationService.scheduleReminderNotification(notifyAt);
    } else {
      print("⛔ Session expired, logging out");
      await prefs.setBool('isLoggedIn', false);
      initialScreen = LoginPage();
    }
  }

  WidgetsBinding.instance.addObserver(AppLifecycleHandler());

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: initialScreen,
  ));
}







void setupFirebaseNotificationListeners() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📲 Foreground message: ${message.notification?.title} - ${message.notification?.body}");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("👆 App opened from notification");
  });
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> with CodeAutoFill {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final _lifecycleHandler = AppLifecycleHandler();
  bool _isPasteChecked = false;



  String? code; // add this as a field in your class
  String _otpCode = "";


  @override
  void codeUpdated() {
    setState(() {
      _otpCode = code ?? '';
      _otpController.text = _otpCode;
    });
  }





  @override
  void dispose() {
    cancel();
    emailController.dispose();
    passwordController.dispose();
    _phoneFocusNode.dispose();
    _otpController.dispose();
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);

    SmsAutoFill().unregisterListener();

    super.dispose();
  }

  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneFocused = false;// default color
  bool isLoading = false;
  String verificationId = "";
  bool isOTPSent = false;



  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.notification!.title ?? 'Notification received')),
          );
        });
      }
    });



    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
    listenForCode();
    _loadPhoneNumber();
    getSignature();



    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
  }



  void getSignature() async {
    String? signature = await SmsAutoFill().getAppSignature;
    print("📱 App Signature: $signature");
  }

  void _loadPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final phone = data['phone'] ?? '';
        setState(() {
          emailController.text = phone;
        });
      }
    }
  }

  Future<void> rechargeWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', 50000.0);
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Exit the app
          SystemNavigator.pop();
          return false; // prevent default pop behavior
        },
    child:  Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              const SizedBox(height: 0),
              const Text(
                'Jio - BP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 70),
              const Text(
                'Welcome to Jio-BP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  controller: phoneController,

                  focusNode: _phoneFocusNode,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    if (phone.length == 10) {
                      sendOTP(phone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Enter a valid 10-digit phone number")),
                      );
                    }
                  },



                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00993A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send OTP',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40,),
              const Text(
                "Enter the verification code sent to above Email and Mobile Number",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),



              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AutofillGroup(
                  child: PinCodeTextField(
                    length: 6,
                    appContext: context,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autoFocus: true,
                    textStyle: const TextStyle(fontSize: 20),
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeColor: Color(0xFF00993A),
                      selectedColor: Color(0xFF00993A),
                      inactiveColor: Colors.grey.shade400,
                    ),
                    enableActiveFill: false,
                    onChanged: (value) {
                      _otpCode = value;
                    },
                    onCompleted: (value) {
                      _otpCode = value;
                    },
                  ),
                ),
              ),



              const SizedBox(height: 0),

              Row(
                mainAxisSize: MainAxisSize.min, // 🚨 This makes Row take only needed width
                children: [
                  Checkbox(
                    value: _isPasteChecked,
                    onChanged: (bool? newValue) async {
                      final clipboardData = await Clipboard.getData('text/plain');
                      final text = clipboardData?.text ?? '';
                      final otp = RegExp(r'\d{6}').firstMatch(text)?.group(0);

                      if (otp != null) {
                        setState(() {
                          _isPasteChecked = newValue ?? false;
                          _otpController.text = otp;
                          _otpCode = otp;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No OTP found in clipboard")),
                        );
                      }
                    },
                    activeColor: const Color(0xFF00993A), // ✅ Jio-BP Green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(width: 0), // 👈 Reduce spacing between box and text

                  const Text(
                    "Paste OTP",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),





              const SizedBox(height: 15),

              Row(
                children: [
                  const Text("Didn't receive the code? "),
                  GestureDetector(
                    onTap: () => sendOTP(phoneController.text.trim()),


                    child: const Text("Resend", style: TextStyle(color: Color(0xFF00993A), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00993A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: ()  => verifyOTP(),

                  child: const Text("Verify", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),


              const SizedBox(height: 15),


            ],
          ),
        ),
        ),
      ),
    ),
    );
  }
  void loginUser(String email, String password, BuildContext context) async {
    try {
      // 1. ✅ Sign in using Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. ✅ Fetch user data from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final userData = snapshot.data() as Map<String, dynamic>;

          // 3. ✅ Store locally for profile/reset page
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('loginTime', DateTime.now().toIso8601String());
          await prefs.setString('email', userData['email'] ?? '');
          await prefs.setString('phone', userData['phone'] ?? '');
          await prefs.setString('dob', userData['dob'] ?? '');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Login failed';

      if (e.code == 'user-not-found') {
        errorMsg = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }


  void sendOTP(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ✅ Auto sign-in when OTP is retrieved automatically
        try {
          UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          User? user = userCredential.user;

          if (user != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('loginTime', DateTime.now().toIso8601String());
            await prefs.setString('phone', phone);

            // 🔍 Check if user exists in Firestore
            QuerySnapshot snapshot = await FirebaseFirestore.instance
                .collection('users')
                .where('phone', isEqualTo: phone)
                .get();

            if (snapshot.docs.isNotEmpty) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
            } else {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set({'phone': phone});

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignupPage()));
            }
          }
        } catch (e) {
          print("❌ Auto-sign-in error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Auto sign-in failed: $e")),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          isOTPSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent successfully")),
        );
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
      timeout: const Duration(seconds: 60),
    );
  }





    Future<void> verifyOTP({bool autoFilled = false}) async {
      String otp = _otpController.text.trim();
      String phone = phoneController.text.trim();

      if (otp.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter complete OTP")),
        );
        return;
      }

      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );

        // 🔐 Sign in the user
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        User? user = userCredential.user;

        if (user != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          // ✅ Mark user as logged in
          await prefs.setBool('isLoggedIn', true);
          DateTime now = DateTime.now();
          await prefs.setString('loginTime', now.toIso8601String());
          await rechargeWallet(); // 🔋 Recharge wallet after OTP verification for testing
          print("✅ Wallet recharged with ₹50,000 for testing.");

          // ✅ 🔔 Schedule notification immediately after login
          await NotificationService
              .cancelReminderNotification(); // in case old ones exist
          await NotificationService.scheduleReminderNotification(now);
          print("✅ Login success — session started at $now");

          // ✅ 👂 Re-attach lifecycle handler
          WidgetsBinding.instance.addObserver(AppLifecycleHandler());

          // 🔍 Check if user already exists in Firestore
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('phone', isEqualTo: phone)
              .get();

          if (snapshot.docs.isNotEmpty) {
            // ✅ Existing user → go to HomePage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          } else {
            // 🆕 New user → store phone in Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({'phone': phone});

            await prefs.setString('phone', phone);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SignupPage()),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP: ${e.toString()}")),
        );
      }
    }
}

    class AppLifecycleHandler with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      print("🚫 User not logged in. Skipping notification.");
      return;
    }

    if (state == AppLifecycleState.paused) {
      print("📴 App paused. Scheduling notification...");
      final now = DateTime.now(); // ⏱️ actual exit time

      await prefs.setString('exitTime', now.toIso8601String());
      await NotificationService.cancelReminderNotification();
      await NotificationService.scheduleReminderNotification(now); // ✅ FIXED
    }

    if (state == AppLifecycleState.resumed) {
      print("📲 App resumed. Cancelling notification and resetting session timer...");

      final now = DateTime.now();
      await prefs.setString('loginTime', now.toIso8601String()); // ⏱️ reset session timer

      await NotificationService.cancelReminderNotification();
    }
  }
}




















