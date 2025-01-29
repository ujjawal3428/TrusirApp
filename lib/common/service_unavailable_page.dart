import 'package:flutter/material.dart';
import 'package:trusir/common/login_page.dart';

class ServiceUnavailablePage extends StatelessWidget {
  const ServiceUnavailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use Scaffold as the base widget
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50), // Optional padding at the top
                // Title Text
                // Image
                Image.asset(
                  'assets/oops.png',
                  height: 90,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("Image not found");
                  },
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/service_unavailable.png',
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("Image not found");
                  },
                ),

                // Optional padding at the bottom
              ],
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 20,
              child: InkWell(
                onTap: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TrusirLoginPage()),
                  (Route<dynamic> route) => false,
                ),
                child: Image.asset(
                  'assets/back.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text("Back image not found");
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
