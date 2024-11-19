import 'package:flutter/material.dart';

class StudentEnquiryPage extends StatelessWidget {
  const StudentEnquiryPage({super.key});

  void _onEnquire() {
    print("Enquire button pressed");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
       appBar: AppBar(
  backgroundColor: Colors.grey[50],
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Padding(
    padding: const EdgeInsets.only(left: 10.0), 
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
       const SizedBox(width: 20), 
        const Text(
          'Student Enquiry',
          style: TextStyle(
            color: Color(0xFF48116A),
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        )],
    ),
  ),
  toolbarHeight: 70,
),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Image.asset(
                  'assets/studentenquiry2.png',
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Text Boxes with Background Images
              _buildTextFieldWithBackground(hintText: 'Student Name'),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(hintText: 'Class'),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(hintText: 'City / Town'),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(hintText: 'Pincode'),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins-SemiBold',
                  color: Color(0xFF7E7E7E),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
