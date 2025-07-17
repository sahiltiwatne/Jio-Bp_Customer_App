import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_history_screen.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'transactions_repository.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';


class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getDouble('wallet_balance') ?? 0;
    });
  }

  Future<void> _rechargeWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('wallet_balance', 50000);
    setState(() {
      balance = 50000;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Wallet recharged successfully ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _optionItem(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.green[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF00993A),
        foregroundColor: Colors.white,
        title: Text("My Wallet"),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Text("My Wallet ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Image.asset('assets/images/wallet.png', height: 30), // Add wallet icon in assets
              ],
            ),

            SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Available Balance", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        balance.toStringAsFixed(2),
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.currency_rupee, size: 32, color: Colors.green[900]), // Rupee symbol at right
                    ],
                  ),
                ],
              ),
            ),


            SizedBox(height: 24),

            _optionItem("Recharge Wallet", Icons.flash_on, _rechargeWallet),
            _optionItem("Transaction History", Icons.receipt_long, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransactionHistoryScreen()),
              ); // Navigate to Transaction History screen
            }),
            _optionItem("Download Statement", Icons.download, () async {
              await downloadStatementAsPDF();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Transaction Statement downloaded to Downloads folder 📄")),
              );
            }),

            _optionItem("Reset Wallet Password", Icons.lock_reset, () {
              // Reset wallet password logic
            }),
          ],
        ),
      ),
    );
  }
  Future<void> downloadStatementAsPDF() async {
    await initializeDateFormatting();

    final pdf = pw.Document();

    final transactions = TransactionsRepository.transactions;

    if (transactions.isEmpty) {
      print("No transactions to export.");
      return;
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Transaction Statement", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ["Pump", "Amount", "Date/Time", "Status", "Mode"],
            data: transactions.map((txn) {
              return [
                txn.pumpName,
                "Rs. ${txn.amount.toStringAsFixed(2)}", // ✅ Use Rs. instead of ₹
                DateFormat('dd-MM-yyyy HH:mm').format(txn.dateTime),
                txn.status,
                txn.mode ?? "Wallet",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // 🔐 Storage Permission Handling
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.request();

      if (!status.isGranted) {
        print("Permission denied");
        return;
      }
    }

    // 📂 Save to Downloads or App Directory
    Directory? dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final fileName = "Transaction_Statement_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${dir.path}/$fileName");

    await file.writeAsBytes(await pdf.save());
    print("✅ PDF Saved at: ${file.path}");
  }


}
