import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/student_homepage.dart';

class StudentEnquiry {
  String? name;
  String? studentclass;
  String? city;
  String? pincode;
  String? gender;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'class': studentclass,
      'city': city,
      'pincode': pincode,
      'gender': gender
    };
  }
}

class StudentEnquiryPage extends StatefulWidget {
  const StudentEnquiryPage({super.key});

  @override
  State<StudentEnquiryPage> createState() => _StudentEnquiryPageState();
}

class _StudentEnquiryPageState extends State<StudentEnquiryPage> {
  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _classcontroller = TextEditingController();
  final TextEditingController _citycontroller = TextEditingController();
  final TextEditingController _pincodecontroller = TextEditingController();
  final StudentEnquiry formData = StudentEnquiry();
  bool isMaleSelected = false;
  bool isFemaleSelected = false;

  void _onEnquire(BuildContext context) {
    setState(() {
      formData.name = _namecontroller.text;
      formData.studentclass = _classcontroller.text;
      formData.city = _citycontroller.text;
      formData.pincode = _pincodecontroller.text;
    });
    if (formData.gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a Gender'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    submitForm(context);
  }

  Future<void> submitForm(BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/enquiry-student');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const StudentHomepage(
                    enablephone: true,
                  )),
        );
        print(body);
      } else {
        print('Failed to submit form: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 50,
                    maxWidth: 50,
                  ),
                  child: Image.asset(
                    'assets/back_button.png',
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'Student Enquiry',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
        toolbarHeight: 50,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.8,
                    maxHeight: screenHeight * 0.3,
                  ),
                  child: Image.asset(
                    'assets/studentenquiry2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextFieldWithBackground(
                  hintText: 'Student Name', controllers: _namecontroller),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'Class',
                  controllers: _classcontroller,
                  isClass: true),
              const SizedBox(height: 10),

              // Gender Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildGenderCheckbox(
                    label: "Male",
                    value: isMaleSelected,
                    onChanged: (value) {
                      setState(() {
                        isMaleSelected = value!;
                        if (value) {
                          isFemaleSelected = false;
                          formData.gender = 'Male';
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
                          formData.gender = 'Female';
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextFieldWithBackground(
                  hintText: 'City / Town', controllers: _citycontroller),
              const SizedBox(height: 10),
              _buildPinFieldWithBackground(
                  hintText: 'Pincode', controllers: _pincodecontroller),
              SizedBox(height: screenHeight * 0.02),

              // Enquire Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    _onEnquire(context);
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.4,
                      maxHeight: 60,
                    ),
                    child: Image.asset(
                      'assets/enquire.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.3,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins-SemiBold',
            fontSize: 16,
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }

  Widget _buildPinFieldWithBackground({
    required String hintText,
    required TextEditingController controllers,
  }) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required Field';
          }
          return null;
        },
        textCapitalization: TextCapitalization.words,
        controller: controllers,
        keyboardType: TextInputType.number,
        maxLength: 6,
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
            null,
        onChanged: (value) {
          if (value.length == 6) {
            FocusScope.of(context).unfocus();
          }
        },
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTextFieldWithBackground({
    required String hintText,
    required TextEditingController controllers,
    bool isClass = false,
  }) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required Field';
          }
          return null;
        },
        textCapitalization: TextCapitalization.words,
        keyboardType: isClass ? TextInputType.number : TextInputType.text,
        controller: controllers,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          isDense: true,
        ),
      ),
    );
  }
}