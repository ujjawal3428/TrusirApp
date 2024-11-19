import 'package:flutter/material.dart';

class TeacherPaymentPage extends StatelessWidget {
  const TeacherPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Top Image (Student Payment Info) touching the top of the screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'teachertopimage.png', // Ensure this path is correct
              fit: BoxFit.cover,
            ),
          ),

          // Main content with scroll functionality
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: SingleChildScrollView( // Wrap with SingleChildScrollView for scrolling
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => _goBack(context),
                    child: Image.asset(
                      "back_button.png", // Ensure this path is correct
                      width: 58, // Adjust based on your image dimensions
                      height: 58,
                    ),
                  ),
                  const SizedBox(height: 290), // Adjust height as needed

                  // Online Payment Button
                  Center(
                    child: GestureDetector(
                      onTap: _ononlinepayment,
                      child: Image.asset(
                        'onlinepayment.png', // Ensure this path is correct
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Offline Payment Button
                  Center(
                    child: GestureDetector(
                      onTap: _onofflinepayment,
                      child: Image.asset(
                        'offlinepayment.png', // Ensure this path is correct
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Go back function
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Define the functions for online and offline payment actions
  void _ononlinepayment() {
    print("Online Payment selected");
    // Add your action here for online payment
  }

  void _onofflinepayment() {
    print("Offline Payment selected");
    // Add your action here for offline payment
  }
}
