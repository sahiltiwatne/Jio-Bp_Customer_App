import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';






void main() {
  runApp(MaterialApp(
    home: ProfileScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMale = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String? selectedState;
  String? selectedCity;
  String? email, phone, dob;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      phone = prefs.getString('phone') ?? '';
      dob = prefs.getString('dob') ?? '';
      emailController.text = email ?? '';
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          addressController.text = data['address'] ?? '';
          pinCodeController.text = data['pinCode'] ?? '';
          selectedState = data['state'];
          selectedCity = data['city'];
          emailController.text = data['email'] ?? '';
        });
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF00993A), // Green background
        iconTheme: IconThemeData(color: Colors.white), // 👈 Makes back arrow white
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white), // 👈 Makes title text white
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ⬅️ Make sure this pops back to the previous screen
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : AssetImage('assets/images/avatar.png') as ImageProvider,
              ),
            ),

            SizedBox(height: 10),
            Text(
              'Sahil Tiwatne',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Member',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            buildLabel("Email"),
            // Email
            buildInput(
              controller: emailController,
              hint: "Enter Email",
            ),




            SizedBox(height: 20),

            // Full Name
            buildLabel("Full Name"),
            Row(
              children: [
                Expanded(child: buildInput(controller: firstNameController, hint: "First Name")
                ),
                SizedBox(width: 10),
                Expanded(child: buildInput(controller: lastNameController,hint: "Last Name")),
              ],
            ),

            SizedBox(height: 20),

            // Mobile Number
            buildLabel("Mobile Number"),
            buildInput(
              value: phone,
              readOnly: true,
              textColor: Colors.grey,
              focusedBorderColor: Colors.red, // 🔥 red border on tap
            ),


            SizedBox(height: 20),

            // Gender
            buildLabel("Gender"),
            Row(
              children: [
                genderOption("Male", isMale),
                SizedBox(width: 20),
                genderOption("Female", !isMale),
              ],
            ),

            SizedBox(height: 30),

            // Address section
            buildLabel("Address"),
            buildInput(controller: addressController,hint: "Enter Address"),
            SizedBox(height: 10),
            Row(
              children: [
                // 🔻 State Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedState,
                    hint: Text("Select State", style: TextStyle(fontSize: 14)), // Smaller hint text
                    style: TextStyle(fontSize: 13, color: Colors.black), // Smaller selected text
                    items: stateCityMap.keys.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state, style: TextStyle(fontSize: 13)), // Smaller dropdown item text
                      );
                    }).toList(),
                    onChanged: (newState) {
                      setState(() {
                        selectedState = newState;
                        selectedCity = null; // Reset city
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true, // 👈 Reduce vertical height
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Smaller padding
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.8, color: Colors.grey), // Thinner border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.8, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 1, color: Color(0xFF00993A)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),

                // 🔻 City Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCity,
                    hint: Text("Select City", style: TextStyle(fontSize: 14)),
                    style: TextStyle(fontSize: 13, color: Colors.black),
                    items: selectedState == null
                        ? []
                        : stateCityMap[selectedState]!.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city, style: TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (newCity) {
                      setState(() {
                        selectedCity = newCity;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.8, color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 0.8, color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(width: 1, color: Color(0xFF00993A)),
                      ),
                    ),
                  ),
                ),
              ],
            ),


            SizedBox(height: 10),
            buildInput(controller: pinCodeController,hint: "Pin Code"),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await saveProfileData();

              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00993A),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style:
        TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
      ),
    );
  }

  Widget buildInput({
    String hint = "",
    String? value,
    TextEditingController? controller,
    bool readOnly = false,
    Color textColor = Colors.black,
    Color focusedBorderColor = const Color(0xFF00993A),
  }) {
    return TextField(
      controller: controller ?? TextEditingController(text: value),
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 14,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }


  Future<void> saveProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'address': addressController.text.trim(),
          'pinCode': pinCodeController.text.trim(),
          'state': selectedState,
          'city': selectedCity,
          'email': emailController.text.trim(),
          'phone': phone,
          'dob': dob,
        }, SetOptions(merge: true));

        // ✅ Show popup after successful save
        showSuccessPopup(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }




  Widget genderOption(String gender, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMale = gender == "Male";
        });
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF00993A), width: 2),
              color: selected ? Color(0xFF00993A) : Colors.white,
            ),
            padding: EdgeInsets.all(5),
            child: selected
                ? Icon(Icons.check, color: Colors.white, size: 15)
                : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
          ),
          SizedBox(width: 8),
          Text(
            gender,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
  Map<String, List<String>> stateCityMap = {
    "Maharashtra": ["Mumbai", "Pune", "Nagpur"],
    "Karnataka": ["Bengaluru", "Mysuru", "Mangalore"],
    "Delhi": ["New Delhi", "Dwarka", "Rohini"],
    "Uttar Pradesh": ["Lucknow", "Kanpur", "Varanasi"],
    "Gujarat": ["Ahmedabad", "Surat", "Rajkot"],
    // Add more states & cities as needed
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent tapping outside to close
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the dialog
          Navigator.of(context).pop(); // Go back to previous page
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100), // ✅ Tick mark
              const SizedBox(height: 14),
              const Text(
                "Details saved successfully :)",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

}
