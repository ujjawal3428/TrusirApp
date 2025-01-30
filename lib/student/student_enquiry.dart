import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/student_homepage.dart';
import 'package:trusir/student/student_registration.dart';
import 'package:trusir/common/service_unavailable_page.dart';

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
  List<Location> locations = [];
  bool isLocationServicable = false;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  void _onEnquire(BuildContext context) {
    setState(() {
      formData.name = _namecontroller.text;
      formData.studentclass = _classcontroller.text;
      formData.city = _citycontroller.text;
      formData.pincode = _pincodecontroller.text;
    });

    // Validate gender
    if (formData.gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a Gender'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    // Search for the pincode in the locations list
    isLocationServicable =
        locations.any((location) => location.pincode == formData.pincode);

    // If pincode is available, proceed with form submission
    submitForm(context, isLocationServicable);
  }

  Future<void> fetchLocations() async {
    const String apiUrl = "$baseUrl/api/city";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Parse the data into a list of Location objects
        locations = data.map((json) => Location.fromJson(json)).toList();

        // Populate states list
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> submitForm(BuildContext context, bool serviceable) async {
    final url = Uri.parse('$baseUrl/api/enquiry-student');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (!serviceable) {
        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const ServiceUnavailablePage()),
            (Route<dynamic> route) => false,
          );
          Fluttertoast.showToast(msg: 'Form Submitted Successfully');
        } else {
          Fluttertoast.showToast(
              msg: 'Failed to submit form: ${response.body}');
        }
      } else if (serviceable) {
        if (response.statusCode == 200) {
          _showThankYouPopup(context);
          Fluttertoast.showToast(msg: 'Form Submitted Successfully');
        } else {
          Fluttertoast.showToast(
              msg: 'Failed to submit form: ${response.body}');
        }
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _showThankYouPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/check.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your enquiry has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StudentHomepage(
                          enablephone: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentHomepage(
            enablephone: true,
          ),
        ),
      );
    });
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
        padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9,
                    maxHeight: screenHeight * 0.4,
                  ),
                  child: Image.asset(
                    'assets/studentenquiry2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'Student Name', controllers: _namecontroller),
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
                  hintText: 'Class',
                  controllers: _classcontroller,
                  isClass: true),

              const SizedBox(height: 10),
              _buildTextFieldWithBackground(
                  hintText: 'City / Town', controllers: _citycontroller),
              const SizedBox(height: 10),
              _buildPinFieldWithBackground(
                  hintText: 'Pincode', controllers: _pincodecontroller),
              SizedBox(height: screenHeight * 0.03),
              // Enquire Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    _onEnquire(context);
                  },
                  child: SizedBox(
                    width: kIsWeb ? 300.0 : 300.0,
                    height: kIsWeb ? 80.0 : 70.0,
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
        buildCounter: (_,
                {required currentLength, required isFocused, maxLength}) =>
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          isDense: true,
        ),
      ),
    );
  }
}
