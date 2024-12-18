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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'studentclass': studentclass,
      'city': city,
      'pincode': pincode,
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

  void _onEnquire(BuildContext context) {
    setState(() {
      formData.name = _namecontroller.text;
      formData.studentclass = _classcontroller.text;
      formData.city = _citycontroller.text;
      formData.pincode = _pincodecontroller.text;
    });
    submitForm(context);
  }

  Future<void> submitForm(BuildContext context) async {
    final url = Uri.parse('$baseUrl/api/submit/enqiry/student');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const StudentHomepage(
                    enablephone: true,
                  )),
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
    double screenHeight = MediaQuery.of(context).size.height;

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
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF48116A),
                  size: 25,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 5),
              const Text(
                'Student Enquiry',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 20,
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/studentenquiry2.png',
                ),
              ),

              // Text Boxes with Background Images
              _buildTextFieldWithBackground(
                  hintText: 'Student Name', controllers: _namecontroller),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'Class', controllers: _classcontroller),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'City / Town', controllers: _citycontroller),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'Pincode', controllers: _pincodecontroller),
              SizedBox(height: screenHeight * 0.05),

              // Enquire Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    _onEnquire(context);
                  },
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
      child: TextField(
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
