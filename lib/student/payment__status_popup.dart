import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/student/wallet.dart';

class PaymentPopUpPage extends StatefulWidget {
  final bool isWallet;
  final bool isSuccess;
  final double adjustedAmount;
  final String transactionID;
  final String transactionType;
  // Add the next page parameter

  const PaymentPopUpPage({
    super.key,
    required this.isWallet,
    required this.adjustedAmount,
    required this.isSuccess,
    required this.transactionID,
    required this.transactionType,
    // Initialize the next page
  });

  @override
  State<PaymentPopUpPage> createState() => _PaymentPopUpPageState();
}

class _PaymentPopUpPageState extends State<PaymentPopUpPage> {
  late int _secondsRemaining;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = 3;

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        widget.isWallet
            ? Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WalletPage()),
                (route) => route.isFirst, // Removes only the last two pages
              )
            : widget.isSuccess
                ? Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainScreen(
                              index: 1,
                            )),
                    (Route<dynamic> route) => false,
                  )
                : Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isSuccess
                    ? [
                        const Color(0xFF4CAF50),
                        const Color(0xFF81C784)
                      ] // Success gradient
                    : [
                        const Color(0xFFD32F2F),
                        const Color(0xFFEF5350)
                      ], // Failure gradient
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
                    widget.isSuccess
                        ? 'assets/success.png'
                        : 'assets/failure.png',
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  // Status message
                  Text(
                    widget.isSuccess
                        ? "Payment Successful!"
                        : "Payment Failed!",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: widget.isSuccess
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Additional info
                  Text(
                    widget.isSuccess
                        ? "Your payment of ₹${widget.adjustedAmount} was successful via ${widget.transactionType}."
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
                          text: widget.transactionID, // Grey text
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Timer display
                  Text(
                    "Redirecting in $_secondsRemaining seconds...",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: widget.isWallet
                          ? () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WalletPage()),
                              );
                            }
                          : () {
                              widget.isSuccess
                                  ? Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen(
                                                index: 1,
                                              )),
                                      (Route<dynamic> route) => false,
                                    )
                                  : Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isSuccess
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      child: Text(
                        widget.isSuccess ? 'Go Back' : 'Retry',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 15),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
