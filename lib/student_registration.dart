import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trusir/api.dart';
import 'package:trusir/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentRegistrationData {
  String? studentName;
  String? fathersName;
  String? mothersName;
  String? gender;
  DateTime? dob;
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
  String? aadharFrontPath;
  String? aadharBackPath;
  bool? agreetoterms;

  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'fathersName': fathersName,
      'mothersName': mothersName,
      'gender': gender,
      'dob': dob?.toIso8601String(),
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
      'aadharfrontPath': aadharFrontPath,
      'aadharbackPath': aadharBackPath,
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
  String? phoneNum;
  String? subject;
  DateTime? selectedDOB;
  bool agreeToTerms = false;

  Future<void> postStudentData({
    required List<StudentRegistrationData> studentFormsData,
  }) async {
    // Preparing the data to send to the server
    final Map<String, dynamic> payload = {
      "phone": phoneNum,
      "number_of_students": numberOfStudents,
      "role": "student",
      "data": studentForms.map((student) {
        return {
          "name": student.studentName,
          "father_name": student.fathersName,
          "mother_name": student.mothersName,
          "gender": student.gender,
          "DOB": student.dob?.toIso8601String(),
          "school_name": student.schoolName,
          "medium": student.medium,
          "class": student.studentClass,
          "subject": student.subject,
          "state": student.state,
          "city": student.city,
          "area": student.area,
          "pincode": student.pincode,
          "address": student.address,
          "time_slot": "6:00am-7:00am", // Update this dynamically if needed
          "profile": student.photoPath,
          "adhaar_front": student.aadharFrontPath,
          "adhaar_back": student.aadharBackPath,
          "agree_to_terms": agreeToTerms
        };
      }).toList(),
    };

    // Sending the POST request
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'), // Replace with your API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        print('Data posted successfully: ${response.body}');
        print(payload);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        print(payload);
      }
    } catch (e) {
      print('Error occurred while posting data: $e');
      print(payload);
    }
  }

  Future<String> uploadImage(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri);

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('photo', imageFile.path));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 201) {
      // Parse the response to extract the download URL
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (jsonResponse.containsKey('download_url')) {
        return jsonResponse['download_url'] as String;
      } else {
        print('Download URL not found in the response.');
        return 'null';
      }
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return 'null';
    }
  }

  Future<void> handleImageSelection(int index, String? path) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Upload the image and get the path
        final uploadedPath = await uploadImage(pickedFile);
        if (uploadedPath != 'null') {
          setState(() {
            // Example: Update the first student's photo path
            if (path == 'profilephoto') {
              studentForms[index].photoPath = uploadedPath;
            } else if (path == 'aadharfront') {
              studentForms[index].aadharFrontPath = uploadedPath;
            } else if (path == 'aadharback') {
              studentForms[index].aadharBackPath = uploadedPath;
            }
            //)
          });
          print('Image uploaded successfully: $uploadedPath');
        } else {
          print('Failed to upload the image.');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error during image selection: $e');
    }
  }

  List<StudentRegistrationData> studentForms = [];

  void updateStudentForms(int count) {
    setState(() {
      if (count > studentForms.length) {
        studentForms.addAll(List.generate(
          count - studentForms.length,
          (_) => StudentRegistrationData(),
        ));
      } else if (count < studentForms.length) {
        studentForms.removeRange(count, studentForms.length);
      }
    });
  }

  Future<void> _selectDOB(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != studentForms[index].dob) {
      setState(() {
        studentForms[index].dob = picked;
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
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Color(0xFF48116A),
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
              const SizedBox(height: 20),
              _buildTextField("Phone Number", onChanged: (value) {
                phoneNum = value;
              }),
              const SizedBox(
                height: 20,
              ),
              // Number of Students Dropdown
              _buildDropdownField(
                'No. of Students',
                selectedValue: numberOfStudents,
                onChanged: (value) {
                  setState(() {
                    numberOfStudents = value;
                    updateStudentForms(int.parse(value!));
                  });
                },
                items: List.generate(20, (index) => (index + 1).toString()),
              ),
              const SizedBox(height: 20),
              // Dynamically Generated Forms
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studentForms.length,
                itemBuilder: (context, index) {
                  return _buildStudentForm(index);
                },
              ),
              const SizedBox(height: 10),
              numberOfStudents == null
                  ? const SizedBox(
                      height: 10,
                    )
                  : Column(
                      children: [
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
                                'Terms and Conditions',
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
                                agreeToTerms == true
                                    ? postStudentData(
                                        studentFormsData: studentForms)
                                    : ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please Agree to Terms and Conditions'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );
                                print(
                                    "Student Data: ${studentForms.map((e) => e.toJson()).toList()}");
                                // submitForm();
                              },
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              // Submit Button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Text(
          'Student ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        _buildTextField('Student Name', onChanged: (value) {
          studentForms[index].studentName = value;
        }),
        const SizedBox(height: 10),
        _buildTextField("Father's Name", onChanged: (value) {
          studentForms[index].fathersName = value;
        }),
        const SizedBox(height: 10),
        _buildTextField("Mother's Name", onChanged: (value) {
          studentForms[index].mothersName = value;
        }),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'Gender',
                selectedValue:
                    studentForms[index].gender, // Use unique value per student
                onChanged: (value) {
                  setState(() {
                    studentForms[index].gender =
                        value; // Update only this student's gender
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
                onTap: () => _selectDOB(
                    context, index), // Pass the index to identify which student
                value: studentForms[index].dob != null
                    ? "${studentForms[index].dob!.day}/${studentForms[index].dob!.month}/${studentForms[index].dob!.year}"
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildTextField('School Name', onChanged: (value) {
          studentForms[index].schoolName = value;
        }),
        const SizedBox(height: 10),
        _buildDropdownField(
          'Medium',
          selectedValue: studentForms[index].medium,
          onChanged: (value) {
            setState(() {
              studentForms[index].medium = value;
            });
          },
          items: ['English', 'Hindi'],
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          'Class',
          selectedValue: studentForms[index].studentClass,
          onChanged: (value) {
            setState(() {
              studentForms[index].studentClass = value;
            });
          },
          items: ['10th', '11th', '12th'],
        ),
        const SizedBox(height: 10),
        _buildDropdownField(
          'Subject',
          selectedValue: studentForms[index].subject,
          onChanged: (value) {
            setState(() {
              studentForms[index].subject = value;
            });
          },
          items: ['Science', 'Arts'],
        ),
        const SizedBox(height: 10),
        _buildTextField('State', onChanged: (value) {
          studentForms[index].state = value;
        }),
        const SizedBox(height: 10),
        _buildDropdownField(
          'City/Town',
          selectedValue: studentForms[index].city,
          onChanged: (value) {
            setState(() {
              studentForms[index].city = value;
            });
          },
          items: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'],
        ),
        const SizedBox(height: 10),
        _buildTextField('Mohalla/Area', onChanged: (value) {
          studentForms[index].area = value;
        }),
        const SizedBox(height: 10),
        _buildTextField('Pincode', onChanged: (value) {
          studentForms[index].pincode = value;
        }),
        const SizedBox(height: 10),
        // Full address
        _buildTextField('Full Address', height: 126, onChanged: (value) {
          studentForms[index].address = value;
        }),
        const SizedBox(height: 20),

        // Photo Upload Section
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 60),
              child: Text(
                'Profile Photo',
                style: TextStyle(fontSize: 14),
              ),
            ),
            _buildFileUploadField('Upload Image',
                width: 200,
                index: index,
                path: 'profilephoto',
                displayPath: studentForms[index].photoPath),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 30),
              child: Text(
                'Aadhar Card Front',
                style: TextStyle(fontSize: 14),
              ),
            ),
            _buildFileUploadField('Upload Image',
                width: 200,
                index: index,
                path: 'aadharfront',
                displayPath: studentForms[index].aadharFrontPath),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 31),
              child: Text(
                'Aadhar Card Back',
                style: TextStyle(fontSize: 14),
              ),
            ),
            _buildFileUploadField('Upload Image',
                width: 200,
                index: index,
                path: 'aadharback',
                displayPath: studentForms[index].aadharBackPath),
          ],
        ),
        const SizedBox(height: 10),
        // Add more fields as needed
      ],
    );
  }

  Widget _buildTextField(String hintText,
      {double height = 58, required ValueChanged<String> onChanged}) {
    return Container(
      height: height,
      width: double.infinity,
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
          label: Text(hintText),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
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

  Widget _buildFileUploadField(String placeholder,
      {required int index,
      required String path,
      double width = 200,
      required displayPath}) {
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
            child: displayPath == null
                ? Text(placeholder, style: const TextStyle(color: Colors.grey))
                : Image.network(
                    displayPath,
                    fit: BoxFit.fill,
                  ),
          ),
          IconButton(
            onPressed: () {
              handleImageSelection(index, path);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image Uploaded Successfully'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
    );
  }
}
