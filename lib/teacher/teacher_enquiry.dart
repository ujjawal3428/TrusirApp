import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/teacher_homepage.dart';

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

    if (widget.formData.gender == null) {
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
    final url = Uri.parse('$baseUrl/api/enquiry-teacher');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(widget.formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Teacherhomepage()),
        );

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text(
                'Teacher Enquiry',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/Teacher_Enquiry2.png',
                ),
              ),

              // Text Box with Image Background
              _buildTextFieldWithBackground(
                  hintText: 'Teacher Name',
                  controllers: widget._namecontroller),
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
              _buildPinFieldWithBackground(
                  hintText: 'Pincode', controllers: widget._pincodecontroller),
              const SizedBox(height: 10),

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
        buildCounter: (_,
                {required currentLength, required isFocused, maxLength}) =>
            null, // Hides counter
        onChanged: (value) {
          if (value.length == 6) {
            FocusScope.of(context).unfocus(); // Dismiss keyboard after 6 digits
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
}
