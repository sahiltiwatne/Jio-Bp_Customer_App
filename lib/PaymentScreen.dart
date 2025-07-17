import 'package:flutter/material.dart';
import 'pumps_map_screen.dart'; // PumpInfo import
import 'notification_service.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transactions_repository.dart';
import 'package:intl/intl.dart';


class PaymentScreen extends StatelessWidget {
  final PumpInfo pump;
  final String fuelType;
  final String date;
  final String time;
  final String quantity;
  final String vehicleNumber;

  PaymentScreen({
    required this.pump,
    required this.fuelType,
    required this.date,
    required this.time,
    required this.quantity,
    required this.vehicleNumber,
  });

  // Sample prices per fuel type
  double _getPricePerUnit() {
    switch (fuelType) {
      case "Petrol":
        return 110.0; // ₹110 per litre
      case "Diesel":
        return 95.0; // ₹95 per litre
      case "CNG":
        return 85.0; // ₹85 per kg
      default:
        return 0.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    double pricePerUnit = _getPricePerUnit();
    double total = pricePerUnit * double.parse(quantity);

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: Color(0xFF00993A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Order Summary", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            SizedBox(height: 16),

            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _orderRow("Pump", pump.address),
                    _orderRow("Fuel Type", fuelType),
                    _orderRow("Quantity", "$quantity ${fuelType == 'CNG' ? 'Kg' : 'Litres'}"),
                    _orderRow("Date", date),
                    _orderRow("Time Slot", time),
                    _orderRow("Vehicle No.", vehicleNumber),
                    Divider(height: 30, thickness: 1),
                    _orderRow("Price per Unit", "₹$pricePerUnit"),
                    _orderRow("Total Amount", "₹${total.toStringAsFixed(2)}", isBold: true),

                  ],
                ),
              ),
            ),

            Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _startPayment(context);
                },
                child: Text("Pay Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00993A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _orderRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: label == "Pump"
                ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14,
                ),
              ),
            )
                : Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _startPayment(BuildContext context) async {
    double pricePerUnit = _getPricePerUnit();
    double total = pricePerUnit * double.parse(quantity);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    double currentBalance = prefs.getDouble('wallet_balance') ?? 0.0;

    if (currentBalance < total) {
      // Not enough balance ❌
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Insufficient Balance ❌"),
          content: Text("Your wallet balance is ₹${currentBalance.toStringAsFixed(2)}.\nPlease recharge to proceed."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    // Deduct balance 💸
    await prefs.setDouble('wallet_balance', currentBalance - total);

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF00993A)),
            SizedBox(width: 20),
            Text("Processing Payment..."),
          ],
        ),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(context); // Close loader
      _paymentSuccess(context);
    });
  }


  void _paymentSuccess(BuildContext context) {
    String bookingId = DateTime.now().millisecondsSinceEpoch.toString();


    double pricePerUnit = _getPricePerUnit();
    double total = pricePerUnit * double.parse(quantity);

    _saveTransaction(total, bookingId);  // Save the transaction
    NotificationService.showBookingNotification(
      fuelType: fuelType,
      vehicleNumber: vehicleNumber,
      pumpAddress: pump.address,
      bookingId: bookingId,
    );


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Successful ✅"),
        content: Text("Your fuel refill booking is confirmed.\nBooking ID: $bookingId"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              Navigator.pop(context); // Go back to home
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction(double totalAmount, String bookingId) async {
    try {
      print("DEBUG: Passing date = $date");
      print("DEBUG: Passing time = $time");

      // Fix the date format here as per your UI input!
      final bookingDateTime = DateFormat("dd-MM-yyyy HH:mm").parse("$date $time");

      final txn = Transaction(
        pumpName: pump.address,
        amount: totalAmount,
        dateTime: DateTime.now(), // Payment time
        bookingDateTime: bookingDateTime, // Actual Booking date+time
        status: "Completed",
        paymentMethod: "Wallet 💸",
        mode: "Wallet",
        bookingId: bookingId,
        bookingStatus: "Upcoming",
        vehicleNumber: vehicleNumber,
        fuelType: fuelType,
      );

      print("🚀 Saving Transaction: ${txn.toJson()}");
      await TransactionsRepository.add(txn);
    } catch (e) {
      print("❌ Error saving transaction: $e");
    }
  }





}
