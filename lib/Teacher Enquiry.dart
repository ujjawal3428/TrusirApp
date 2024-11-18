import 'package:flutter/material.dart';

class TeacherEnquiryPage extends StatefulWidget {
  const TeacherEnquiryPage({Key? key}) : super(key: key);

  @override
  State<TeacherEnquiryPage> createState() => _TeacherEnquiryPageState();
}

class _TeacherEnquiryPageState extends State<TeacherEnquiryPage> {
  bool isMaleSelected = false;
  bool isFemaleSelected = false;

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
                  width: 58,
                  height: 58,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Teacher Enquiry Image
              Center(
                child: Image.asset(
                  'assets/Teacher_Enquiry2.png',
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Text Box with Image Background
              _buildTextFieldWithBackground(
                hintText: 'Teacher Name',
              ),
              SizedBox(height: 15),

              // Gender Selection
              Row(
                children: [
                  _buildGenderCheckbox(
                    label: "Male",
                    value: isMaleSelected,
                    onChanged: (value) {
                      setState(() {
                        isMaleSelected = value!;
                        if (value) isFemaleSelected = false;
                      });
                    },
                  ),
                  SizedBox(width: 20),
                  _buildGenderCheckbox(
                    label: "Female",
                    value: isFemaleSelected,
                    onChanged: (value) {
                      setState(() {
                        isFemaleSelected = value!;
                        if (value) isMaleSelected = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Qualification Field
              _buildTextFieldWithBackground(
                hintText: 'Qualification',
              ),
              SizedBox(height: 10),

              // City / Town Field
              _buildTextFieldWithBackground(
                hintText: 'City / Town',
              ),
              SizedBox(height: 10),

              // Pincode Field
              _buildTextFieldWithBackground(
                hintText: 'Pincode',
              ),
              SizedBox(height: 15),

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
    );
  }

  Widget _buildGenderCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Stack(
          children: [
            Image.asset(
              'assets/checkbox.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: Checkbox(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins-SemiBold',
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }
}
