import 'package:flutter/material.dart';

class StudentPaymentPage extends StatelessWidget {
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
              'studenttopimage.png', // Ensure this path is correct
              fit: BoxFit.cover,
            ),
          ),

          // Main content below the top image
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0), // Adjust padding to position content below the image
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
                SizedBox(height: 290),

                

              

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

                  SizedBox(height: 20),

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
