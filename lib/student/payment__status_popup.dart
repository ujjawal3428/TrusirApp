import 'package:flutter/material.dart';

class PaymentPopUpPage extends StatelessWidget {
  final bool isSuccess;
  final double adjustedAmount;
  final String transactionType;

  const PaymentPopUpPage({
    super.key,
    required this.adjustedAmount,
    required this.isSuccess,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSuccess ? "Payment Successful" : "Payment Failed"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isSuccess
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/success.png', // Replace with your success image path
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your payment of ₹$adjustedAmount was successful via $transactionType.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/failure.png', // Replace with your failure image path
                      height: 100,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Payment failed. Please try again.",
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
