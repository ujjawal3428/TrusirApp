import 'package:flutter/material.dart';

class PaymentPopUpPage extends StatelessWidget {
  final bool isSuccess;
  final double adjustedAmount;
  final String transactionID;
  final String transactionType;

  const PaymentPopUpPage({
    super.key,
    required this.adjustedAmount,
    required this.isSuccess,
    required this.transactionID,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSuccess
                    ? [
                        const Color(0xFF4CAF50),
                        const Color(0xFF81C784)
                      ] // Success gradient
                    : [
                        const Color(0xFFD32F2F),
                        const Color(0xFFEF5350)
                      ], // Success gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Back button at the top
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.only(top: 200, left: 10, right: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success or failure image
                  Image.asset(
                    isSuccess ? 'assets/success.png' : 'assets/failure.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  // Status message
                  Text(
                    isSuccess ? "Payment Successful!" : "Payment Failed!",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: isSuccess
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Additional info
                  Text(
                    isSuccess
                        ? "Your payment of ₹$adjustedAmount was successful via $transactionType."
                        : "Something went wrong. Please try again.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins"),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Transaction ID : ', // Black text
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black, // Black color for the label
                      ),
                      children: [
                        TextSpan(
                          text: transactionID, // Grey text
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
