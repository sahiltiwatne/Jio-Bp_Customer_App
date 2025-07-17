import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transactions_repository.dart';
import 'package:first_project/transactions_repository.dart';
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();



class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> with RouteAware {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    await TransactionsRepository.load();
    setState(() {
      transactions = TransactionsRepository.transactions;

    });
  }

  String formatDate(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return "$day-$month-$year  $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00993A),
        foregroundColor: Colors.white,
        title: Text("Transaction History"),
      ),
      body: transactions.isEmpty
          ? Center(
        child: Text(
          "No transactions found.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final txn = transactions[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  txn.status == "Completed" ? Icons.check_circle : Icons.pending,
                  color: txn.status == "Completed" ? Colors.green : Colors.orange,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.pumpName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDate(txn.dateTime),
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Booking ID: ${txn.bookingId}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 16, color: Colors.blueAccent),
                          SizedBox(width: 4),
                          Text(
                            "Paid through Wallet",
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),



                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${txn.amount.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      txn.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: txn.status == "Completed" ? Colors.green : Colors.orange,
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
}
