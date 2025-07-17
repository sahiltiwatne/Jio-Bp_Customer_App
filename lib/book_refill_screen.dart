import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pumps_map_screen.dart'; // PumpInfo import
import 'package:first_project/PaymentScreen.dart';

class BookRefillScreen extends StatefulWidget {
  final PumpInfo pump;

  BookRefillScreen({required this.pump});

  @override
  _BookRefillScreenState createState() => _BookRefillScreenState();
}

class _BookRefillScreenState extends State<BookRefillScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedFuelType;
  TextEditingController quantityController = TextEditingController();
  TextEditingController timeSlotController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  String selectedDay = 'Today';
  String? selectedPaymentMode;


  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Color(0xFF00993A), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Refill", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF00993A),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(    // Only this one Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Image banner
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/amenities.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 16),

              // White Card Container starts here
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Selected Pump:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(widget.pump.address, style: TextStyle(color: Colors.grey[800])),
                      ),

                      SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              final lat = widget.pump.location.latitude;
                              final lng = widget.pump.location.longitude;
                              final url = Uri.parse(
                                  "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
                              launchUrl(url, mode: LaunchMode.externalApplication);
                            },
                            icon: Icon(Icons.navigation, color: Color(0xFF00993A)),
                            label: Text("Navigate", style: TextStyle(color: Color(0xFF00993A))),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to Amenities screen if needed
                            },
                            icon: Icon(Icons.local_gas_station, color: Color(0xFF00993A)),
                            label: Text("Amenities", style: TextStyle(color: Color(0xFF00993A))),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Fuel Type Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedFuelType,
                        items: ["Petrol", "Diesel", "CNG"].map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedFuelType = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select Fuel Type",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14), // Rounded corners ✅
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade100), // Grey border ✅
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.green, width: 2), // Optional focus color
                          ),
                        ),
                        validator: (value) => value == null ? "Select fuel type" : null,
                      ),


                      SizedBox(height: 16),

                      // Quantity
                      TextFormField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: customInputDecoration("Quantity (Litres / Kg)"),
                        validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                      ),


                      SizedBox(height: 16),

                      // Time Slot
                      TextFormField(
                        controller: timeSlotController,
                        readOnly: true,
                        decoration: customInputDecoration("Select Refill Time Slot"),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            timeSlotController.text = "${picked.hour}:${picked.minute.toString().padLeft(2, '0')}";
                          }
                        },
                        validator: (value) => value!.isEmpty ? "Select time slot" : null,
                      ),


                      SizedBox(height: 16),

                      _buildDateSelector(),
                      // Date


                      SizedBox(height: 16),

                      // Vehicle Number
                      TextFormField(
                        controller: vehicleNumberController,
                        textCapitalization: TextCapitalization.characters, // ✅ Makes input UPPERCASE
                        decoration: customInputDecoration("Enter Vehicle Number"),
                      ),



                      SizedBox(height: 24),

                      // Check Slot Button

                      // Payment Mode Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedPaymentMode,
                        items: ["Wallet", "Cash On Delivery"].map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(mode),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMode = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Select Payment Mode",
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade100),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.green, width: 2),
                          ),
                        ),
                        validator: (value) => value == null ? "Select payment mode" : null,
                      ),

                    ],
                  ),
                ),
              SizedBox(height: 20,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _checkAvailability,
                  child: Text("Check for Available Slot"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00993A),
                    foregroundColor: Colors.white, // ✅ White text color
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            ],
          ),

        ),
      ),
    );

  }


  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Refill Date", style: TextStyle(fontWeight: FontWeight.bold)),

        SizedBox(height: 10),

        Row(
          children: [
            ChoiceChip(
              label: Text("Today"),
              selected: selectedDay == 'Today',
              onSelected: (val) {
                setState(() {
                  selectedDay = 'Today';
                  DateTime now = DateTime.now();
                  final formattedDate = DateFormat('dd-MM-yyyy').format(now);
                  dateController.text = formattedDate;


                });
              },
              selectedColor: Color(0xFF00993A),
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selectedDay == 'Today' ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 10),
            ChoiceChip(
              label: Text("Tomorrow"),
              selected: selectedDay == 'Tomorrow',
              onSelected: (val) {
                setState(() {
                  selectedDay = 'Tomorrow';
                  DateTime tomorrow = DateTime.now().add(Duration(days: 1));
                  final formattedDate = DateFormat('dd-MM-yyyy').format(tomorrow);
                  dateController.text = formattedDate;


                });
              },
              selectedColor: Color(0xFF00993A),
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selectedDay == 'Tomorrow' ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),

        SizedBox(height: 16),

        TextFormField(
          controller: dateController,
          readOnly: true,
          decoration: customInputDecoration("Selected Date"),
          validator: (value) => value!.isEmpty ? "Select date" : null,
        ),
      ],
    );
  }

  void _checkAvailability() {
    if (_formKey.currentState!.validate()) {

      if (selectedPaymentMode == "Cash On Delivery") {
        // COD Not available ❌
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("COD Not Available ❌"),
            content: Text("No Cash On Delivery option available for this pump."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
        return; // Stop further execution
      }

      // Proceed only for Wallet Payment
      bool isAvailable = _mockCheckDatabase();

      if (isAvailable) {
        // Navigate to Payment Screen ✅
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              pump: widget.pump,
              fuelType: selectedFuelType!,
              date: dateController.text,
              time: timeSlotController.text,
              quantity: quantityController.text,
              vehicleNumber: vehicleNumberController.text,
            ),
          ),
        );
      } else {
        // Show Not Available Alert ❌
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Not Available ❌"),
            content: Text("Fuel not available for the selected date & time at this pump."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              )
            ],
          ),
        );
      }
    }
  }



  bool _mockCheckDatabase() {
    // In real use: Call API / check DB for availability
    // For demo: Random availability
    DateTime now = DateTime.now();
    return now.second % 2 == 0; // Random availability check
  }
}


