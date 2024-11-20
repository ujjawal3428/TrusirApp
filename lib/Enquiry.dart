import 'package:flutter/material.dart';
import 'student_enquiry.dart';
import 'teacher_enquiry.dart';

class EnquiryPage extends StatelessWidget {
  const EnquiryPage({super.key});

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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF48116A),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 5),
              const Text(
                'Enquiry',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
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

                // Teacher Enquiry Image
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeacherEnquiryPage(),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/teacherenquiry.png", // Ensure asset path is correct
                    width: 350,
                    height: 250,
                  ),
                ),
                const SizedBox(height: 20),

                // "Or Enquire On" Text
                const Text(
                  'Or Enquire On',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8C4C92),
                    fontFamily:
                        'Poppins', // Ensure Poppins font is added in pubspec.yaml
                  ),
                ),
                const SizedBox(height: 10),

                // WhatsApp and Call Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // WhatsApp Button
                    GestureDetector(
                      onTap: _openWhatsApp,
                      child: Image.asset(
                        'assets/whatsapp@3x.png', // Ensure asset path is correct
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
