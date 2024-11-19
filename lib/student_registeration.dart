import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';
import 'package:trusir/student_facilities.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentRegistrationData {
  String? studentName;
  String? fathersName;
  String? mothersName;
  String? gender;
  DateTime? dob;
  String? phoneNumber;
  String? schoolName;
  String? medium;
  String? studentClass;
  String? subject;
  String? state;
  String? city;
  String? area;
  String? pincode;
  String? address;
  String? photoPath;
  String? aadharCardPath;

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'fathersName': fathersName,
      'mothersName': mothersName,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'schoolName': schoolName,
      'medium': medium,
      'studentClass': studentClass,
      'subject': subject,
      'state': state,
      'city': city,
      'area': area,
      'pincode': pincode,
      'address': address,
      'photoPath': photoPath,
      'aadharCardPath': aadharCardPath,
    };
  }
}

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  StudentRegistrationPageState createState() => StudentRegistrationPageState();
}

class StudentRegistrationPageState extends State<StudentRegistrationPage> {
  String? gender;
  String? numberOfStudents;
  String? city;
  String? medium;
  String? studentClass;
  String? subject;
  DateTime? selectedDOB;
  bool agreeToTerms = false;
  final StudentRegistrationData formData = StudentRegistrationData();

  Future<void> submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    final url = Uri.parse('$baseUrl/register/$role');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Studentfacilities()),
        );
      } else {
        // Handle error
        print('Failed to submit form: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDOB) {
      setState(() {
        selectedDOB = picked;
        formData.dob = selectedDOB;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button at top left using image
              Padding(
                padding: const EdgeInsets.only(top: 35, left: 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/back_button.png',
                    width: 58,
                    height: 58,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Top image
              Center(
                child: Image.asset(
                  'assets/studentregisteration@4x.png',
                  width: 386,
                  height: 261,
                ),
              ),
              // No. of Students dropdown
              _buildDropdownField(
                'No. of Students',
                selectedValue: numberOfStudents,
                onChanged: (value) {
                  setState(() {
                    numberOfStudents = value;
                  });
                },
                items: List.generate(20, (index) => (index + 1).toString()),
              ),
              const SizedBox(height: 10),
              // Name fields
              _buildTextField('Student Name', onChanged: (value) {
                formData.studentName = value;
              }),
              const SizedBox(height: 10),
              _buildTextField("Father's Name", onChanged: (value) {
                formData.fathersName = value;
              }),
              const SizedBox(height: 10),
              _buildTextField("Mother's Name", onChanged: (value) {
                formData.mothersName = value;
              }),
              const SizedBox(height: 10),
              // Gender and DOB Row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      'Gender',
                      selectedValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value;
                          formData.gender = gender;
                        });
                      },
                      items: ['Male', 'Female', 'Other'],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextFieldWithIcon(
                      'DOB',
                      Icons.calendar_today,
                      onTap: () => _selectDOB(context),
                      value: selectedDOB != null
                          ? "${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}"
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Additional details
              _buildTextField('Phone Number', onChanged: (value) {
                formData.phoneNumber = value;
              }),
              const SizedBox(height: 10),
              _buildTextField('School Name', onChanged: (value) {
                formData.schoolName = value;
              }),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Medium',
                selectedValue: medium,
                onChanged: (value) {
                  setState(() {
                    medium = value;
                    formData.medium = medium;
                  });
                },
                items: ['English', 'Hindi'],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Class',
                selectedValue: studentClass,
                onChanged: (value) {
                  setState(() {
                    studentClass = value;
                    formData.studentClass = studentClass;
                  });
                },
                items: ['10th', '11th', '12th'],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Subject',
                selectedValue: subject,
                onChanged: (value) {
                  setState(() {
                    subject = value;
                    formData.subject = subject;
                  });
                },
                items: ['Science', 'Arts'],
              ),
              const SizedBox(height: 10),
              _buildTextField('State', onChanged: (value) {
                formData.state = value;
              }),
              const SizedBox(height: 10),
              _buildDropdownField(
                'City/Town',
                selectedValue: city,
                onChanged: (value) {
                  setState(() {
                    city = value;
                    formData.city = city;
                  });
                },
                items: [
                  'New York',
                  'Los Angeles',
                  'Chicago',
                  'Houston',
                  'Phoenix'
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField('Mohalla/Area', onChanged: (value) {
                formData.area = value;
              }),
              const SizedBox(height: 10),
              _buildTextField('Pincode', onChanged: (value) {
                formData.pincode = value;
              }),
              const SizedBox(height: 10),
              // Full address
              _buildTextField('Full Address', height: 126, onChanged: (value) {
                formData.address = value;
              }),
              const SizedBox(height: 20),

              // Photo Upload Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 80.0),
                    child: Text(
                      'Photo',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField('Upload Image', width: 200),
                ],
              ),
              const SizedBox(height: 10),

              // Aadhar Card Upload Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 80.0),
                    child: Text(
                      'Aadhar Card',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField('Upload Image', width: 200),
                ],
              ),
              const SizedBox(height: 10),

              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        agreeToTerms = value!;
                      });
                    },
                  ),
                  const Text('I agree with the '),
                  GestureDetector(
                    onTap: () {
                      // Handle terms and conditions navigation here
                    },
                    child: const Text(
                      'terms and conditions',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Registration Fee
              const Center(
                child: Text(
                  '299/- Registration Fee',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              // Register Button
              Center(
                child: Container(
                  width: 388,
                  height: 73,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(47),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF045C19), Color(0xFF77D317)],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      submitForm();
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 20),
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

  Widget _buildTextField(String hintText,
      {double height = 58, required ValueChanged<String> onChanged}) {
    return Container(
      height: height,
      width: 388,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String hintText, {
    String? selectedValue,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      height: 58,
      width: 388,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(hintText),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon(
    String hintText,
    IconData icon, {
    required VoidCallback onTap,
    String? value,
  }) {
    return Container(
      height: 58,
      width: 184,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(value ?? hintText),
              ),
            ),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Widget _buildFileUploadField(
    String placeholder, {
    double width = 200,
  }) {
    return Container(
      height: 58,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Text(placeholder, style: const TextStyle(color: Colors.grey)),
          ),
          IconButton(
            onPressed: () {
              // Handle file upload action
            },
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }
}
