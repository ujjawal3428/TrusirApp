import 'package:flutter/material.dart';

class AssignedTeacher extends StatelessWidget {
  const AssignedTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF790EB0), Color(0xFFD61A92)], // Purple to pink gradient
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.15), // Space at the top

            // "Thanks for Registration!" text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Responsive horizontal padding
              child: Text(
                'Thanks for \nRegistration!',
                style: TextStyle(
                  fontSize: 32, // Responsive text size
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins', // Font from assets
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: screenHeight * 0.05), // Space between text and image

            // 3D character image
            Container(
              width: 1000, // Responsive image width
              child: Image.asset(
                'thanks_for_registration.png', // Corrected asset path
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: screenHeight * 0.05), // Space between image and text

            // Subtext: "We will be assigning you a student shortly"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Responsive horizontal padding
              child: Text(
                'We will be assigning you a \nteacher shortly',
                style: TextStyle(
                  fontSize: 20, // Responsive text size
                   fontWeight: FontWeight.w200,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: screenHeight * 0.15), 
          ],
        ),
      ),
    );
  }
}
