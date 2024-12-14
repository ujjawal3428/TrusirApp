import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/login_page.dart';
import 'package:trusir/common/registration_splash_screen.dart';

class TeacherRegistrationData {
  String? teacherName;
  String? fathersName;
  String? mothersName;
  String? gender;
  DateTime? dob;
  String? phoneNumber;
  String? qualification;
  String? experience;
  String? preferredclass;
  String? medium;
  String? subject;
  String? state;
  String? city;
  String? area;
  String? pincode;
  String? timeslot;
  String? school;
  String? caddress;
  String? board;
  String? paddress;
  String? photoPath;
  String? aadharFrontPath;
  String? aadharBackPath;
  String? signaturePath;
  bool? agreetoterms;

  Map<String, dynamic> toJson() {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return {
      'teacherName': teacherName,
      'fathersName': fathersName,
      'mothersName': mothersName,
      'gender': gender,
      'dob': dob != null ? dateFormatter.format(dob!) : null,
      'phoneNumber': phoneNumber,
      'qualification': qualification,
      'experience': experience,
      'preferredclass': preferredclass,
      'medium': medium,
      'subject': subject,
      'school': school,
      'board': board,
      'timeslot': timeslot,
      'state': state,
      'city': city,
      'area': area,
      'pincode': pincode,
      'caddress': caddress,
      'paddress': paddress,
      'photoPath': photoPath,
      'aadharFrontPath': aadharFrontPath,
      'aadharBackPath': aadharBackPath,
      'signaturePath': signaturePath,
      'agreetoterms': agreetoterms,
    };
  }
}

class TeacherRegistrationPage extends StatefulWidget {
  const TeacherRegistrationPage({super.key});

  @override
  TeacherRegistrationPageState createState() => TeacherRegistrationPageState();
}

class TeacherRegistrationPageState extends State<TeacherRegistrationPage> {
  String? gender;
  String? city;
  String? medium;
  String? preferredClass;
  String? subject;
  DateTime? selectedDOB;
  bool agreeToTerms = false;

  final TeacherRegistrationData formData = TeacherRegistrationData();

  final TextEditingController _phoneController = TextEditingController();
  String? phoneNum;

  Set<String> selectedSlots = {}; // Store selected time slots
  String? uploadedPath;
  Future<String> uploadFile(String filePath, String fileType) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri); // Correct HTTP method

    // Add the file to the request with the correct field name
    request.files.add(await http.MultipartFile.fromPath(
        'photo', filePath)); // Field name is 'photo'

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
      print('Failed to upload file: ${response.statusCode}');
      return 'null';
    }
  }

  Future<String?> handleFileSelection(BuildContext context) async {
    try {
      // Use FilePicker to select a file
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        // Determine file type (use "document" for docx/pdf, "photo" for images)
        final fileType = fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png')
            ? 'photo'
            : 'document';

        // Upload the file and get the path
        uploadedPath = await uploadFile(filePath, fileType);

        if (uploadedPath != 'null') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File Uploaded Successfully!'),
              duration: Duration(seconds: 1),
            ),
          );

          print('File uploaded successfully: $uploadedPath');
          return uploadedPath;
        } else {
          print('Failed to upload the file.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to upload the file.(Only upload pdf, docx and image)'),
              duration: Duration(seconds: 1),
            ),
          );
          return null;
        }
      } else {
        print('No file selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            duration: Duration(seconds: 1),
          ),
        );
        return null;
      }
    } catch (e) {
      print('Error during file selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Failed to Upload file.(Only upload pdf, docx and jpg, jpeg,png)'),
          duration: Duration(seconds: 1),
        ),
      );
      return null;
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

  Future<void> handleImageSelection(String? path) async {
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
              formData.photoPath = uploadedPath;
            } else if (path == 'aadharfront') {
              formData.aadharFrontPath = uploadedPath;
            } else if (path == 'aadharback') {
              formData.aadharBackPath = uploadedPath;
            } else if (path == 'signature') {
              formData.signaturePath = uploadedPath;
            }
            //')
            //)
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Images Uploaded Successfully!'),
              duration: Duration(seconds: 1),
            ),
          );
          print('Image uploaded successfully: $uploadedPath');
        } else {
          print('Failed to upload the image.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload Image'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        print('No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error during image selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during image selection: $e'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber =
        prefs.getString('phone_number'); // Replace with your key
    if (savedPhoneNumber != null) {
      _phoneController.text = savedPhoneNumber;
      phoneNum = savedPhoneNumber; // Set the text field value
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
  }

  Future<void> postTeacherData({
    required List<TeacherRegistrationData> teacherFormsData,
  }) async {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    for (final teacher in teacherFormsData) {
      if ([
        teacher.teacherName,
        teacher.fathersName,
        teacher.mothersName,
        teacher.gender,
        teacher.dob,
        teacher.school,
        teacher.medium,
        teacher.preferredclass,
        teacher.subject,
        teacher.state,
        teacher.city,
        teacher.area,
        teacher.pincode,
        teacher.caddress,
        teacher.timeslot,
        teacher.photoPath,
        teacher.aadharFrontPath,
        teacher.aadharBackPath,
      ].any((field) => field == null || field.toString().isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all the fields to proceed.'),
            duration: Duration(seconds: 2),
          ),
        );
        return; // Stop execution if any field is invalid
      }
    }

    final Map<String, dynamic> payload = {
      "phone": phoneNum ?? _phoneController.text,
      "role": "teacher",
      "data": teacherFormsData.map((teacher) {
        return {
          "name": teacher.teacherName,
          "father_name": teacher.fathersName,
          "mother_name": teacher.mothersName,
          "gender": teacher.gender,
          "DOB":
              teacher.dob != null ? dateFormatter.format(teacher.dob!) : null,
          "qualification": teacher.qualification,
          "experience": teacher.experience,
          "class": teacher.preferredclass,
          "medium": teacher.medium,
          "subject": teacher.subject,
          "school": teacher.school,
          "board": teacher.board,
          "state": teacher.state,
          "timeslot": teacher.timeslot,
          "city": teacher.city,
          "area": teacher.area,
          "pincode": teacher.pincode,
          "caddress": teacher.caddress,
          "paddress": teacher.paddress,
          "address": teacher.caddress, // Use common address field if needed
          "time_slot": teacher.signaturePath, // Update dynamically if needed
          "profile": teacher.photoPath,
          "adhaar_front": teacher.aadharFrontPath,
          "adhaar_back": teacher.aadharBackPath, // Adjust as needed
          "agree_to_terms": teacher.agreetoterms,
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
          MaterialPageRoute(
            builder: (context) =>
                SplashScreen(phone: phoneNum ?? _phoneController.text),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful'),
            duration: Duration(seconds: 1),
          ),
        );
      } else if (response.statusCode == 409) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrusirLoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User Already Exists!'),
            duration: Duration(seconds: 1),
          ),
        );
        print(payload);
      } else if (response.statusCode == 500) {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internal Server Error'),
            duration: Duration(seconds: 1),
          ),
        );
        print(payload);
      }
    } catch (e) {
      print('Error occurred while posting data: $e');
      print(payload);
    }
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button at top left
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
                  'assets/groupregister.png',
                  width: 386,
                  height: 261,
                ),
              ),
              // Teacher's basic information
              _buildTextField('Teacher Name', onChanged: (value) {
                formData.teacherName = value;
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
              _buildPhoneField('Phone Number'),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Qualification',
                selectedValue: formData.qualification,
                onChanged: (value) {
                  setState(() {
                    formData.qualification = value;
                  });
                },
                items: [
                  'Matric',
                  'Non-Matric',
                  'Under Graduate',
                  'Post Graduate',
                  'Diploma',
                  'Other'
                ],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Experience',
                selectedValue: formData.experience,
                onChanged: (value) {
                  setState(() {
                    formData.experience = value;
                  });
                },
                items: [
                  'Fresher',
                  '1 Year+',
                  '2 Years+',
                  '3 Years+',
                  '4 Years+',
                  '5 Years+'
                ],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Board Name',
                selectedValue: formData.board,
                onChanged: (value) {
                  setState(() {
                    formData.board = value;
                  });
                },
                items: ['BSEB', 'CBSE', 'ICSE'],
              ),
              const SizedBox(height: 10),
              _buildTextField('School Name', onChanged: (value) {
                formData.school = value;
              }),
              const SizedBox(height: 10),
              // Dropdowns
              _buildDropdownField(
                'Preferred Class',
                selectedValue: preferredClass,
                onChanged: (value) {
                  setState(() {
                    preferredClass = value;
                    formData.preferredclass = preferredClass;
                  });
                },
                items: ['10th', '11th', '12th'],
              ),
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
              _buildDropdownField(
                'State',
                selectedValue: formData.state,
                onChanged: (value) {
                  setState(() {
                    formData.state = value;
                  });
                },
                items: [
                  'UP',
                  'Bihar',
                  'Gujarat',
                  'Maharastra',
                  'Rajasthan',
                  'Delhi'
                ],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'City/Town',
                selectedValue: formData.city,
                onChanged: (value) {
                  setState(() {
                    formData.city = value;
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
              _buildDropdownField(
                'Mohalla/Area',
                selectedValue: formData.area,
                onChanged: (value) {
                  setState(() {
                    formData.area = value;
                  });
                },
                items: [
                  'Balua',
                  'Chandmari',
                  'Raja Bazar',
                  'Chhatauni',
                  'Lakshmipur'
                ],
              ),
              const SizedBox(height: 10),
              _buildDropdownField(
                'Pincode',
                selectedValue: formData.pincode,
                onChanged: (value) {
                  setState(() {
                    formData.pincode = value;
                  });
                },
                items: ['845401', '845437', '845456', '845422', '845435'],
              ),
              const SizedBox(height: 10),
              // Address fields
              _buildTextField('Current Full Address', height: 126,
                  onChanged: (value) {
                formData.caddress = value;
              }),
              const SizedBox(height: 10),
              _buildTextField('Permanent Full Address', height: 126,
                  onChanged: (value) {
                formData.paddress = value;
              }),
              const SizedBox(height: 20),

              // Upload Sections
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 50),
                    child: Text(
                      'Profile Photo',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField(
                      formData.photoPath == null
                          ? 'Upload Image'
                          : 'Update Image',
                      width: 200, onTap: () {
                    handleImageSelection('profilephoto');
                  }, displayPath: formData.photoPath),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      'Aadhar Card Front',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField(
                      formData.aadharFrontPath == null
                          ? 'Upload File'
                          : 'Update File',
                      width: 200, onTap: () {
                    setState(() async {
                      uploadedPath = await handleFileSelection(context);
                    });
                    if (uploadedPath != 'null') {
                      setState(() {
                        // Example: Update the first student's photo path
                        formData.aadharFrontPath = uploadedPath;
                        //)
                      });
                    }
                  }, displayPath: formData.aadharFrontPath),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      'Aadhar Card Back',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField(
                      formData.aadharBackPath == null
                          ? 'Upload File'
                          : 'Update File',
                      width: 200, onTap: () {
                    setState(() async {
                      uploadedPath = await handleFileSelection(context);
                    });
                    if (uploadedPath != 'null') {
                      setState(() {
                        // Example: Update the first student's photo path
                        formData.aadharBackPath = uploadedPath;
                        //)
                      });
                    }
                  }, displayPath: formData.aadharBackPath),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 80),
                    child: Text(
                      'Signature',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  _buildFileUploadField(
                      formData.signaturePath == null
                          ? 'Upload Image'
                          : 'Update Image', onTap: () {
                    handleImageSelection('signature');
                  }, width: 200, displayPath: formData.signaturePath),
                ],
              ),
              const SizedBox(height: 10),
              TimeSlotField(formData: formData),
              const SizedBox(height: 10),

              // Terms and Conditions Checkbox
              Row(
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        agreeToTerms = value!;
                        formData.agreetoterms = agreeToTerms;
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
              // Register Button
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF045C19), Color(0xFF77D317)],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      formData.agreetoterms == true
                          ? postTeacherData(teacherFormsData: [formData])
                          : ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please Agree to Terms and Conditions'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hintText, {
    double height = 58,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: height,
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
        onChanged: onChanged,
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
          contentPadding: EdgeInsets.symmetric(
              horizontal: 16, vertical: height == 126 ? 50 : 17),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPhoneField(
    String hintText,
  ) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
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
          labelText: hintText,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TextField(
        readOnly: true, // Ensures the field is not editable
        onTap: onTap,
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
          suffixIcon: Icon(icon),
          isDense: true,
        ),
        controller: TextEditingController(text: value ?? ''),
      ),
    );
  }

  Widget _buildFileUploadField(String placeholder,
      {double width = 200,
      required displayPath,
      required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  ? Text(placeholder,
                      style: const TextStyle(color: Colors.grey))
                  : Image.network(
                      displayPath,
                      fit: BoxFit.fill,
                    ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.upload_file),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSlotField extends StatefulWidget {
  final TeacherRegistrationData
      formData; // Assuming you have a FormData class with timeslot field

  const TimeSlotField({super.key, required this.formData});

  @override
  TimeSlotFieldState createState() => TimeSlotFieldState();
}

class TimeSlotFieldState extends State<TimeSlotField> {
  final List<String> morningSlots = [
    '8-9 AM',
    '9-10 AM',
    '10-11 AM',
    '11-12 PM'
  ];
  final List<String> afternoonSlots = [
    '12-1 PM',
    '1-2 PM',
    '2-3 PM',
    '3-4 PM',
    '4-5PM'
  ];
  final List<String> eveningSlots = ['5-6 PM', '6-7 PM', '7-8 PM'];

  final Set<String> selectedSlots = {};

  void toggleSelection(String slot) {
    setState(() {
      if (selectedSlots.contains(slot)) {
        selectedSlots.remove(slot);
      } else {
        selectedSlots.add(slot);
      }
      // Update the timeslot in the formData
      widget.formData.timeslot = selectedSlots.join(", ");
    });
  }

  Widget buildSlot(String slot) {
    return GestureDetector(
      onTap: () => toggleSelection(slot),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4.0),
        padding: const EdgeInsets.all(9.0),
        decoration: BoxDecoration(
          color: selectedSlots.contains(slot)
              ? const Color.fromARGB(255, 127, 0, 195)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text(
            slot,
            style: TextStyle(
              color: selectedSlots.contains(slot) ? Colors.white : Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hours of Availability',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20.0,
              color: Colors.purple.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Morning Hours',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: morningSlots.map(buildSlot).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Afternoon Hours',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: afternoonSlots.map(buildSlot).toList(),
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Evening Hours',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: eveningSlots.map(buildSlot).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
