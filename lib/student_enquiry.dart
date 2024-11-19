import 'package:flutter/material.dart';

class StudentEnquiryPage extends StatelessWidget {
  const StudentEnquiryPage({super.key});

  void _onEnquire() {
    // Implement the Enquire action here
    print("Enquire button pressed");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  "assets/back_button.png",
                  width: 58, // Adjust based on your image dimensions
                  height: 58,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Student Enquiry Image
              Center(
                child: Image.asset(
                  'assets/studentenquiry2.png',
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Text Boxes with Background Images
              _buildTextFieldWithBackground(
                hintText: 'Student Name',
              ),
              const SizedBox(height: 10),

              _buildTextFieldWithBackground(
                hintText: 'Class',
              ),
              const SizedBox(height: 10),

              _buildTextFieldWithBackground(
                hintText: 'City / Town',
              ),
              const SizedBox(height: 10),

              _buildTextFieldWithBackground(
                hintText: 'Pincode',
              ),
              SizedBox(height: screenHeight * 0.05),

              // Enquire Button
              Center(
                child: GestureDetector(
                  onTap: _onEnquire,
                  child: Image.asset(
                    'assets/enquire.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithBackground({required String hintText}) {
    return Stack(
      children: [
        Image.asset(
          'assets/textfield.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: 60,
        ),
        Positioned.fill(
          child: TextField(
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontFamily: 'Poppins-SemiBold',
                color: Color(0xFF7E7E7E),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
