import 'package:flutter/material.dart';

class WanaLogout extends StatelessWidget {
  const WanaLogout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with padding and scroll view
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Navigates back on tap
                    child: Image.asset(
                      "assets/back_button.png", // Ensure this path is correct
                      width: 58,
                      height: 58,
                    ),
                  ),
                  const SizedBox(height: 160),

                  // Online Payment Button
                  Center(
                    child: Image.asset(
                      'logout.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Logout Confirmation Text
                  const Center(
                    child: Text(
                      'Are you sure you want to Logout?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 190),

                  // Cancel Button
                  Center(
                    child: GestureDetector(
                      onTap: _onEnquire, // Calls _onEnquire on tap
                      child: Image.asset(
                        'cancelbutton.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Logout Button
                  Center(
                    child: GestureDetector(
                      onTap: _onEnquire, // Calls _onEnquire on tap
                      child: Image.asset(
                        'logoutbutton.png',
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

  // Define the function for handling actions
  void _onEnquire() {
    print("Enquiry action triggered");
    // Add your action for the button here
  }
}
