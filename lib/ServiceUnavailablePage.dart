import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ServiceUnavailablePage(),
    );
  }
}

class ServiceUnavailablePage extends StatelessWidget {
  void _onButtonPressed() {
    print("Button Pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Use Scaffold as the base widget
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Optional padding at the top

            // Title Text
            Text(
              'Service Unavailable',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C4C92),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),

            // Image
            Image.asset(
              'assets/sad_girl.png',
              errorBuilder: (context, error, stackTrace) {
                return Text("Image not found");
              },
            ),
            SizedBox(height: 20),

            // Description Text
            Text(
              'Our service is not available in \nyour area. We will notify you \nwhen we are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 188, 0, 63),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),

            // Thank You Text
            Text(
              'Thank you for your Enquiry',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 188, 0, 63),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 30),

            // Go Back Button as Image
            InkWell(
              onTap: _onButtonPressed,
              child: Image.asset(
                'assets/back.png',
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Text("Back image not found");
                },
              ),
            ),
            SizedBox(height: 50), // Optional padding at the bottom
          ],
        ),
      ),
    );
  }
}
