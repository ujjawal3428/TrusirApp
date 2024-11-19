import 'package:flutter/material.dart';

class TeacherEnquiryPage extends StatefulWidget {
  const TeacherEnquiryPage({super.key});

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
      backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
  backgroundColor: Colors.grey[50],
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Padding(
    padding: const EdgeInsets.only(left: 1.0), 
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
          'Teacher Enquiry',
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 15),

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
                  const SizedBox(width: 20),
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
              const SizedBox(height: 15),

              // Qualification Field
              _buildTextFieldWithBackground(
                hintText: 'Qualification',
              ),
              const SizedBox(height: 10),

              // City / Town Field
              _buildTextFieldWithBackground(
                hintText: 'City / Town',
              ),
              const SizedBox(height: 10),

              // Pincode Field
              _buildTextFieldWithBackground(
                hintText: 'Pincode',
              ),
              const SizedBox(height: 15),

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
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins-SemiBold',
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }
}
