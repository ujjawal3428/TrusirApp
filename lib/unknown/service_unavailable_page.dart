import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ServiceUnavailablePage(),
    );
  }
}

class ServiceUnavailablePage extends StatelessWidget {
  const ServiceUnavailablePage({super.key});

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
            const SizedBox(height: 50), // Optional padding at the top

            // Title Text
            const Text(
              'Service Unavailable',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C4C92),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),

            // Image
            Image.asset(
              'assets/sad_girl.png',
              errorBuilder: (context, error, stackTrace) {
                return const Text("Image not found");
              },
            ),
            const SizedBox(height: 20),

            // Description Text
            const Text(
              'Our service is not available in \nyour area. We will notify you \nwhen we are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 188, 0, 63),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Thank You Text
            const Text(
              'Thank you for your Enquiry',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 188, 0, 63),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 30),

            // Go Back Button as Image
            InkWell(
              onTap: _onButtonPressed,
              child: Image.asset(
                'assets/back.png',
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Text("Back image not found");
                },
              ),
            ),
            const SizedBox(height: 50), // Optional padding at the bottom
          ],
        ),
      ),
    );
  }
}
