import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trusir/api.dart';
import 'package:trusir/teacher_homepage.dart';
import 'package:trusir/teacher_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherEnquiry {
  String? name;
  String? qualification;
  String? city;
  String? pincode;
  String? gender;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qualification': qualification,
      'city': city,
      'pincode': pincode,
      'gender': gender
    };
  }
}

class TeacherEnquiryPage extends StatefulWidget {
  TeacherEnquiryPage({super.key});

  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _qualificationcontroller =
      TextEditingController();
  final TextEditingController _citycontroller = TextEditingController();
  final TextEditingController _pincodecontroller = TextEditingController();

  final TeacherEnquiry formData = TeacherEnquiry();

  @override
  State<TeacherEnquiryPage> createState() => _TeacherEnquiryPageState();
}

class _TeacherEnquiryPageState extends State<TeacherEnquiryPage> {
  bool isMaleSelected = false;
  bool isFemaleSelected = false;

  void _onEnquire() {
    setState(() {
      widget.formData.name = widget._namecontroller.text;
      widget.formData.qualification = widget._qualificationcontroller.text;
      widget.formData.city = widget._citycontroller.text;
      widget.formData.pincode = widget._pincodecontroller.text;
    });
    submitForm(context);
  }

  Future<void> submitForm(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final newuser = prefs.getBool('new_user');
    final url = Uri.parse('$baseUrl/api/submit/enqiry/teacher');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(widget.formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted
        if (newuser == true) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Teacherhomepage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherMainScreen()),
          );
        }

        print(body);
      } else {
        // Handle error
        print('Failed to submit form: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
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
                  controllers: widget._namecontroller),
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
                        if (value) {
                          isFemaleSelected = false;
                          widget.formData.gender = 'Male';
                        }
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
                        if (value) {
                          isMaleSelected = false;
                          widget.formData.gender = 'Female';
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Qualification Field
              _buildTextFieldWithBackground(
                  hintText: 'Qualification',
                  controllers: widget._qualificationcontroller),
              const SizedBox(height: 10),

              // City / Town Field
              _buildTextFieldWithBackground(
                  hintText: 'City / Town', controllers: widget._citycontroller),
              const SizedBox(height: 10),

              // Pincode Field
              _buildTextFieldWithBackground(
                  hintText: 'Pincode', controllers: widget._pincodecontroller),
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

  Widget _buildTextFieldWithBackground(
      {required String hintText, required TextEditingController controllers}) {
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
            controller: controllers,
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
