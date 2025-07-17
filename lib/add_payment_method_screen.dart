import 'package:flutter/material.dart';

class AddPaymentMethodScreen extends StatelessWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Payment Method", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00993A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOption(context, "assets/images/upi.png", "Add a UPI method", () {
            // TODO: Navigate to UPI page
          }),
          _buildOption(context, "assets/images/debit.png", "Add Debit / Credit Card", () {
            // TODO: Navigate to card input
          }),
          _buildOption(context, "assets/images/netbanking.png", "Netbanking", () {
            // TODO: Navigate to netbanking options
          }),
          _buildOption(context, "assets/images/wallet.png", "Create / Recharge Wallet", () {
            // TODO: Navigate to wallet page
          }),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String iconPath, String title, VoidCallback onTap) {

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              Image.asset(iconPath, width: 40, height: 40),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
