import 'package:flutter/material.dart';
import 'transactions_repository.dart';
import 'dart:async';

class MyBookingsScreen extends StatefulWidget {
  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {

  List<Transaction> upcomingBookings = [];

  @override
  void initState() {
    super.initState();
    _filterUpcomingBookings();
    _loadAndFilterBookings();
  }

  Future<void> _loadAndFilterBookings() async {
    await TransactionsRepository.load();  // ✅ Load saved transactions
    _filterUpcomingBookings();
  }
  void _filterUpcomingBookings() {
    final now = DateTime.now();

    upcomingBookings = [];

    for (var txn in TransactionsRepository.transactions) {
      print("🔍 Checking txn: ${txn.bookingId}, BookingDateTime: ${txn.bookingDateTime}, Status: ${txn.bookingStatus}");

      if (txn.bookingStatus == "Upcoming") {
        if (txn.bookingDateTime.isBefore(now)) {
          txn.bookingStatus = "Completed";
        } else {
          upcomingBookings.add(txn);
        }
      }
    }

    TransactionsRepository.save();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: Color(0xFF00993A),
        foregroundColor: Colors.white,
      ),
      body: upcomingBookings.isEmpty
          ? Center(
        child: Text(
          "No upcoming bookings found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: upcomingBookings.length,
        itemBuilder: (context, index) {
          final txn = upcomingBookings[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50, // Light green card
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Icon(Icons.local_gas_station, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        txn.pumpName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text("Booking ID: ${txn.bookingId}", style: TextStyle(fontSize: 13, color: Colors.grey)),
                SizedBox(height: 4),

                Text("Vehicle No: ${txn.vehicleNumber}", style: TextStyle(fontSize: 13)),
                // Replace with txn.vehicleNumber if you have it
                SizedBox(height: 4),
                Text("Fuel Type: ${txn.fuelType}", style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text("Booking of Date: ${txn.bookingDateTime.day}-${txn.bookingDateTime.month}-${txn.bookingDateTime.year}", style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text("Booking of Slot: ${txn.bookingDateTime.hour}:${txn.bookingDateTime.minute.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 13)),

                SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      txn.bookingStatus,
                      style: TextStyle(
                        fontSize: 13,
                        color: txn.bookingStatus == "Completed" ? Colors.green :
                        txn.bookingStatus == "Cancelled" ? Colors.red :
                        Colors.orange, // For Upcoming
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        _cancelBooking(txn);
                      },
                      child: Text("Cancel Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  void _cancelBooking(Transaction txn) {
    setState(() {
      txn.bookingStatus = "Cancelled";
      upcomingBookings.remove(txn);
      TransactionsRepository.save();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Booking cancelled successfully")),
    );
  }

}
