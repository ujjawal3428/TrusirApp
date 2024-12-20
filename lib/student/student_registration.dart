import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:trusir/common/registration_splash_screen.dart';
import 'package:trusir/common/terms_and_conditions.dart';

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
  String? timeslot;
  String? photoPath;
  String? aadharFrontPath;
  String? aadharBackPath;
  bool? agreetoterms;
  List<String> cities = [];
  List<String> pins = [];

  Map<String, dynamic> toJson() {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return {
      'studentName': studentName,
      'fathersName': fathersName,
      'mothersName': mothersName,
      'gender': gender,
      'dob': dob != null ? dateFormatter.format(dob!) : null,
      'schoolName': schoolName,
      'medium': medium,
      'studentClass': studentClass,
      'subject': subject,
      'state': state,
      'city': city,
      'area': area,
      'pincode': pincode,
      'address': address,
      'time_slot': timeslot,
      'photoPath': photoPath,
      'aadharfrontPath': aadharFrontPath,
      'aadharbackPath': aadharBackPath,
    };
  }
}

class Location {
  final String name; // City name
  final String state;
  final String pincode;

  Location({
    required this.name,
    required this.state,
    required this.pincode,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }
}

class StudentRegistrationPage extends StatefulWidget {
  final bool enablephonefield;
  const StudentRegistrationPage({super.key, required this.enablephonefield});

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
  final TextEditingController _phoneController = TextEditingController();

  List<Location> locations = [];

  // Filtered lists
  List<String> states = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    updateStudentForms(1);
    numberOfStudents = '1';
    fetchLocations();
  }

  // Load the phone number from SharedPreferences
  Future<void> _loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber =
        prefs.getString('phone_number'); // Replace with your key
    if (savedPhoneNumber != null) {
      _phoneController.text = savedPhoneNumber;
      phoneNum = savedPhoneNumber; // Set the text field value
    }
  }

  Future<void> fetchLocations() async {
    const String apiUrl = "https://admin.trusir.com/api/city";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Parse the data into a list of Location objects
        locations = data.map((json) => Location.fromJson(json)).toList();

        // Populate states list
        setState(() {
          states = locations.map((loc) => loc.state).toSet().toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load locations");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  final List<String> timeSlots = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM",
    "08:00 PM - 09:00 PM",
    "09:00 PM - 10:00 PM",
  ];

  // List to store selected slots for each student form
  final List<Set<String>> selectedSlots = [];
  String? uploadedPath;

  // List to store selected slot strings for each student form
  final List<String> selectedSlotsString = [];

  void updateSelectedSlots(int index) {
    setState(() {
      selectedSlotsString[index] = selectedSlots[index].join(", ");
      studentForms[index].timeslot =
          selectedSlotsString[index]; // Assuming this field exists
    });
  }

  Future<void> postStudentData({
    required List<StudentRegistrationData> studentFormsData,
  }) async {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    // Validation step to check if all required fields are filled
    for (final student in studentFormsData) {
      if ([
        student.studentName,
        student.fathersName,
        student.mothersName,
        student.gender,
        student.dob,
        student.schoolName,
        student.medium,
        student.studentClass,
        student.subject,
        student.state,
        student.city,
        student.area,
        student.pincode,
        student.address,
        student.timeslot,
        student.photoPath,
        student.aadharFrontPath,
        student.aadharBackPath,
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
      "number_of_students": numberOfStudents,
      "role": "student",
      "data": studentFormsData.map((student) {
        return {
          "name": student.studentName,
          "father_name": student.fathersName,
          "mother_name": student.mothersName,
          "gender": student.gender,
          "DOB":
              student.dob != null ? dateFormatter.format(student.dob!) : null,
          "school": student.schoolName,
          "medium": student.medium,
          "class": student.studentClass,
          "subject": student.subject,
          "state": student.state,
          "city": student.city,
          "area": student.area,
          "pincode": student.pincode,
          "address": student.address,
          "time_slot": student.timeslot,
          "profile": student.photoPath,
          "adhaar_front": student.aadharFrontPath,
          "adhaar_back": student.aadharBackPath,
          "agree_to_terms": agreeToTerms,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        print('Data posted successfully: ${response.body}');
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
      } else if (response.statusCode == 500) {
        print('Failed to post data: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internal Server Error'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error occurred while posting data: $e');
    }
  }

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

  Future<void> handleFileSelection(
      BuildContext context, int index, String path) async {
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
          if (path == 'aadharFrontPath') {
            setState(() {
              studentForms[index].aadharFrontPath = uploadedPath;
            });
          } else {
            setState(() {
              studentForms[index].aadharBackPath = uploadedPath;
            });
          }
          print('File uploaded successfully: $uploadedPath');
        } else {
          print('Failed to upload the file.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to upload the file.(Only upload pdf, docx and image)'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        print('No file selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error during file selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to Upload file.(Only upload pdf, docx and image)'),
          duration: Duration(seconds: 1),
        ),
      );
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

  Future<void> handleImageSelection(String? path, int index) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Upload the image and get the path
        final newuploadedPath = await uploadImage(pickedFile);
        if (newuploadedPath != 'null') {
          setState(() {
            // Example: Update the first student's photo path
            if (path == 'profilephoto') {
              studentForms[index].photoPath = newuploadedPath;
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
              content: Text('Failed to upload the image.'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        print('No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected.'),
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
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(height: 20), // Top image
              Center(
                child: Image.asset(
                  'assets/studentregisteration@4x.png',
                  width: 386,
                  height: 261,
                ),
              ),
              _buildPhoneField("Phone Number"),
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
                items: List.generate(3, (index) => (index + 1).toString()),
              ),

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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TermsAndConditionsPage(),
                                  ),
                                );
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                '299/-',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20.0,
                                  color: Colors.purple.shade900,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                ' Registration Fee',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20.0,
                                  color: Colors.purple.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildRegisterButton(context)
                      ],
                    ),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
        _buildDropdownField(
          'State',
          selectedValue: studentForms[index].state,
          onChanged: (value) {
            setState(() {
              studentForms[index].state = value;
              studentForms[index].city = null;
              studentForms[index].pincode = null;

              studentForms[index].cities = locations
                  .where((loc) => loc.state == value)
                  .map((loc) => loc.name)
                  .toSet()
                  .toList();
            });
          },
          items: states,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (studentForms[index].state == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please select a state first.'),
                duration: Duration(seconds: 2),
              ));
            } else {
              null;
            }
          },
          child: _buildDropdownField(
            'City/Town',
            selectedValue: studentForms[index].city,
            onChanged: (value) {
              setState(() {
                studentForms[index].city = value;
                studentForms[index].pincode = null;
                studentForms[index].pins = locations
                    .where((loc) => loc.name == value)
                    .map((loc) => loc.pincode)
                    .toSet()
                    .toList();
              });
            },
            items: studentForms[index].cities,
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField('Mohalla/Area', onChanged: (value) {
          studentForms[index].area = value;
        }),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            if (studentForms[index].state == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please select a state first.'),
                duration: Duration(seconds: 2),
              ));
            } else if (studentForms[index].city == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please select a city first.'),
                duration: Duration(seconds: 2),
              ));
            } else {
              null;
            }
          },
          child: _buildDropdownField(
            'Pincode',
            selectedValue: studentForms[index].pincode,
            onChanged: (value) {
              setState(() {
                studentForms[index].pincode = value;
              });
            },
            items: studentForms[index].pins,
          ),
        ),
        const SizedBox(height: 10),
        // Full address
        _buildAddressField('Full Address', onChanged: (value) {
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFileUploadField('Upload Image', isFile: false, onTap: () {
              handleImageSelection('profilephoto', index);
            }, width: 200, displayPath: studentForms[index].photoPath),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 19),
              child: Text(
                'Aadhar Card Front',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFileUploadField('Upload File', isFile: true, onTap: () {
              handleFileSelection(context, index, 'aadharFrontPath');
            }, width: 200, displayPath: studentForms[index].aadharFrontPath),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFileUploadField('Upload File', isFile: true, onTap: () {
              handleFileSelection(context, index, 'aadharBackPath');
            }, width: 200, displayPath: studentForms[index].aadharBackPath),
          ],
        ),
        const SizedBox(height: 30),
        TimeSlotField(
          formData: studentForms[index],
        ), // Pass index to handle each form's state
        const SizedBox(height: 10),
        // Add more fields as needed
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          agreeToTerms == true
              ? postStudentData(studentFormsData: studentForms)
              : ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please Agree to Terms and Conditions'),
                    duration: Duration(seconds: 1),
                  ),
                );
        },
        child: Image.asset(
          'assets/register.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.contain,
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
        textCapitalization: TextCapitalization.words,
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

  Widget _buildAddressField(
    String hintText, {
    required ValueChanged<String> onChanged,
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
      child: TextField(
        textCapitalization: TextCapitalization.words,
        onChanged: onChanged,
        maxLines: null, // Allows the text to wrap and grow vertically
        textAlignVertical:
            TextAlignVertical.top, // Ensures text starts from the top
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12, // Adjust vertical padding for better alignment
          ),
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
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        buildCounter: (_,
                {required currentLength, required isFocused, maxLength}) =>
            null, // Hides counter
        onChanged: (value) {
          if (value.length == 10) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
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
      {required VoidCallback onTap,
      double width = 200,
      required displayPath,
      required bool isFile}) {
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
              child: isFile
                  ? displayPath == null
                      ? Text(placeholder,
                          style: const TextStyle(color: Colors.grey))
                      : const Icon(Icons.picture_as_pdf, color: Colors.grey)
                  : displayPath == null
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
  final dynamic
      formData; // Assuming you have a FormData class with timeslot field

  const TimeSlotField({
    super.key,
    required this.formData,
  });

  @override
  TimeSlotFieldState createState() => TimeSlotFieldState();
}

class TimeSlotFieldState extends State<TimeSlotField> {
  final List<String> morningSlots = [
    '6-7 AM',
    '7-8 AM',
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
      padding: const EdgeInsets.all(5),
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
