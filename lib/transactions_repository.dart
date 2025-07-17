import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Transaction {
  final String pumpName;
  final double amount;
  final DateTime dateTime;
  final DateTime bookingDateTime;
  final String status;
  final String paymentMethod;  // <-- NEW
  final String mode;
  final String bookingId;
  String bookingStatus;
  final String vehicleNumber;
  final String fuelType;

  Transaction({
    required this.pumpName,
    required this.amount,
    required this.dateTime,
    required this.bookingDateTime,
    required this.status,
    required this.paymentMethod,
    required this.mode,// <-- NEW
    required this.bookingId,
    this.bookingStatus = "Upcoming",
    required this.vehicleNumber,
    required this.fuelType,
  });

  Map<String, dynamic> toJson() => {
    "pumpName": pumpName,
    "amount": amount,
    "dateTime": dateTime.toIso8601String(),
    "bookingDateTime": bookingDateTime.toIso8601String(),
    "status": status,
    "paymentMethod": paymentMethod,
    "mode": mode,
    "bookingId": bookingId,// <-- NEW
    "bookingStatus": bookingStatus,
    "vehicleNumber": vehicleNumber,
    "fuelType": fuelType,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      pumpName: json['pumpName'],
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      bookingDateTime: json['bookingDateTime'] != null
          ? DateTime.parse(json['bookingDateTime'])
          : DateTime.parse(json['dateTime']),
      status: json['status'],
      paymentMethod: json['paymentMethod'] ?? "Wallet",
      mode: json['mode'] ?? "Wallet",// default if old data
      bookingId: json['bookingId'] ?? "-",
      bookingStatus: json['bookingStatus'] ?? "Upcoming", // Default if old data
      vehicleNumber: json['vehicleNumber'] ?? "Unknown",
      fuelType: json['fuelType'] ?? "Petrol",
    );
  }
}


class TransactionsRepository {
  static List<Transaction> transactions = [];

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mobileNumber = prefs.getString('phone') ?? "";
    final data = prefs.getStringList('transactions_$mobileNumber') ?? [];
    print("📂 Loading transactions for phone: $mobileNumber");
    transactions = data.map((e) => Transaction.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> add(Transaction txn) async {
    transactions.insert(0, txn);
    print("✅ Transaction added: ${txn.toJson()}"); // Debug Print
    await save();
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final mobileNumber = prefs.getString('phone') ?? "";
    final data = transactions.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('transactions_$mobileNumber', data);
  }
}
