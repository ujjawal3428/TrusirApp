import 'package:flutter/material.dart';
import 'Student%20Enquiry.dart';
import 'Teacher%20Enquiry.dart';

class EnquiryPage extends StatelessWidget {
  const EnquiryPage({Key? key}) : super(key: key);

  void _openWhatsApp() {
    print("WhatsApp tapped");
    // Add WhatsApp implementation here, such as using url_launcher to open WhatsApp
  }

  void _call() {
    print("Call tapped");
    // Add call functionality here, such as using url_launcher to initiate a phone call
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Student Enquiry Image
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentEnquiryPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/studentenquiry.png", // Ensure asset path is correct
                    width: 350,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),

                // Teacher Enquiry Image
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherEnquiryPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/teacherenquiry.png", // Ensure asset path is correct
                    width: 350,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 40),

                // "Or Enquire On" Text
                const Text(
                  'Or Enquire On',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C4C92),
                    fontFamily: 'Poppins', // Ensure Poppins font is added in pubspec.yaml
                  ),
                ),
                const SizedBox(height: 20),

                // WhatsApp and Call Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // WhatsApp Button
                    GestureDetector(
                      onTap: _openWhatsApp,
                      child: Image.asset(
                        'assets/whatsapp.png', // Ensure asset path is correct
                        width: 100, // Adjust dimensions as needed
                        height: 100,
                      ),
                    ),
                    const SizedBox(width: 70), // Adjust spacing as needed

                    // Call Button
                    GestureDetector(
                      onTap: _call,
                      child: Image.asset(
                        'assets/call.png', // Ensure asset path is correct
                        width: 115, // Adjust dimensions as needed
                        height: 115,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
