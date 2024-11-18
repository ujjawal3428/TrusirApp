import 'package:flutter/material.dart';

class FinalStudentHomepage extends StatelessWidget {
  const FinalStudentHomepage({super.key});

  void _goBack(BuildContext context) {
    Navigator.pop(context); // Handles back navigation
  }

  void _onEnquire() {
    print("Enquire button pressed");
    // Implement the Enquire action here
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView( // Add SingleChildScrollView here
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Back Button
              GestureDetector(
                onTap: () => _goBack(context),
                child: Image.asset(
                  "back_button.png",
                  width: 58, // Adjust based on your image dimensions
                  height: 58,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Student Enquiry Image
              Center(
                child: Image.asset(
                  'student_registration.png',
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Text Box with Image Background
              Stack(
                children: [
                  // Background Image
                  Image.asset(
                    'textfield.png', // Change this to your image file
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60, // Adjust the height based on your image dimensions
                  ),
                  // Text Field on top of the image
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start, // Align text to the start (left)
                      decoration: InputDecoration(
                        hintText: 'No. of Students',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20, // Add horizontal padding for left alignment
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Repeat for other fields if needed...
              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Student Name',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Father’s Name',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Mother’s Name',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
                  Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'School Name',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
                  Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Medium',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
                  Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Class',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
                  Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Subject',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
                  Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'State',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //
              
               Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'City / Town',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              
              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Mohalla/Area',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),


              Stack(
                children: [
                  Image.asset(
                    'textfield.png', 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Pincode',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

               Stack(
                children: [
                  Image.asset(
                    'textbox.png', 
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'Full Address',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins-SemiBold',
                          color: Color(0xFF7E7E7E),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              
              

              // Enquire Button
              Center(
                child: GestureDetector(
                  onTap: _onEnquire,
                  child: Image.asset(
                    'enquire.png',
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
}
