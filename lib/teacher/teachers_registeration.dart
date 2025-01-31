import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/image_uploading.dart';
import 'package:trusir/common/login_page.dart';
import 'package:trusir/common/otp_screen.dart';
import 'package:trusir/common/registration_splash_screen.dart';
import 'package:trusir/common/terms_and_conditions.dart';

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
  Map<String, bool>? timeslot;
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
      ...?timeslot,
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

class TeacherRegistrationPage extends StatefulWidget {
  const TeacherRegistrationPage({super.key});

  @override
  TeacherRegistrationPageState createState() => TeacherRegistrationPageState();
}

class TeacherRegistrationPageState extends State<TeacherRegistrationPage> {
  String? gender;
  DateTime? selectedDOB;
  bool agreeToTerms = false;

  final TeacherRegistrationData formData = TeacherRegistrationData();

  final TextEditingController _phoneController = TextEditingController();

  List<Location> locations = [];

  // Selected values
  String? selectedState;
  String? selectedCity;
  String? selectedPincode;

  // Filtered lists
  List<String> states = [];
  List<String> cities = [];
  List<String> pincodes = [];
  List<String> _courses = [];
  List<String> _classes = [];
  bool userSkipped = false;
  List<String> selectedSubjects = [];
  List<String> selectedClass = [];
  List<String> selectedMedium = [];
  List<String> selectedBoard = [];
  bool isLoading = true;
  bool isprofileuploading = false;
  bool isadhaarfuploading = false;
  bool isadhaarbuploading = false;
  bool issignuploading = false;
  bool isAdditionalLoading = true;
  dynamic additionals;
  Set<String> selectedSlots = {}; // Store selected time slots
  String? uploadedPath;

  Future<Map<String, List<String>>> fetchAndOrganizeAdditionals() async {
    setState(() {
      isAdditionalLoading = true;
    });
    const String apiUrl = "$baseUrl/get-additionals";
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        Map<String, List<String>> organizedData = {};

        for (var item in responseData) {
          String type = item['type'];
          String value = item['value'];

          if (!organizedData.containsKey(type)) {
            organizedData[type] = [];
          }
          organizedData[type]!.add(value);
        }

        return organizedData;
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {};
    }
  }

  void organizeAdditionals() async {
    additionals = await fetchAndOrganizeAdditionals();
    setState(() {
      isAdditionalLoading = false;
    });
    print(additionals);
  }

  Future<void> handleUploadFromCamera(String? path) async {
    final String result = await ImageUploadUtils.uploadSingleImageFromCamera();

    if (result != 'null') {
      setState(() {
        setState(() {
          if (path == 'photo') {
            formData.photoPath = result;
            isprofileuploading = false;
          } else if (path == 'adhaarFront') {
            formData.aadharFrontPath = result;
            isadhaarfuploading = false;
          } else if (path == 'adhaarBack') {
            formData.aadharBackPath = result;
            isadhaarbuploading = false;
          } else if (path == 'sign') {
            formData.signaturePath = result;
            issignuploading = false;
          }
        });
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {
        if (path == 'photo') {
          isprofileuploading = false;
        } else if (path == 'adhaarFront') {
          isadhaarfuploading = false;
        } else if (path == 'adhaarBack') {
          isadhaarbuploading = false;
        } else if (path == 'sign') {
          issignuploading = false;
        }
      });
    }
  }

  Future<void> handleUploadFromGallery(String? path) async {
    final String result = await ImageUploadUtils.uploadSingleImageFromGallery();

    if (result != 'null') {
      setState(() {
        setState(() {
          if (path == 'photo') {
            formData.photoPath = result;
            isprofileuploading = false;
          } else if (path == 'adhaarFront') {
            formData.aadharFrontPath = result;
            isadhaarfuploading = false;
          } else if (path == 'adhaarBack') {
            formData.aadharBackPath = result;
            isadhaarbuploading = false;
          } else if (path == 'sign') {
            formData.signaturePath = result;
            issignuploading = false;
          }
        });
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {
        if (path == 'photo') {
          isprofileuploading = false;
        } else if (path == 'adhaarFront') {
          isadhaarfuploading = false;
        } else if (path == 'adhaarBack') {
          isadhaarbuploading = false;
        } else if (path == 'sign') {
          issignuploading = false;
        }
      });
    }
  }

  Future<void> fetchAllCourses() async {
    final url = Uri.parse('$baseUrl/get-courses');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      if (mounted) {
        setState(() {
          // Use a Set to ensure unique values
          final Set<String> uniqueCourses = {};
          final Set<String> uniqueClasses = {};

          for (var course in data) {
            // Extract the subject and class
            final subject = course['subject'] as String;
            final courseClass =
                course['class'] as String; // Adjust based on API response

            // Add unique combinations to the sets
            uniqueCourses.add('$subject $courseClass');
            uniqueClasses.add(courseClass);
          }

          // Convert sets back to lists
          _courses = uniqueCourses.toList();
          _classes = uniqueClasses.toList();
        });
      }
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<void> _loadPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhoneNumber =
        prefs.getString('phone_number'); // Replace with your key
    if (savedPhoneNumber != null) {
      setState(() {
        _phoneController.text = savedPhoneNumber;
        userSkipped = false;
      });
      // Set the text field value
    } else {
      setState(() {
        userSkipped = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    fetchAllCourses();
    fetchLocations();
    organizeAdditionals();
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

  void onStateChanged(String? value) {
    setState(() {
      selectedState = value;
      formData.state = selectedState;
      selectedCity = null;
      selectedPincode = null;

      // Filter cities by state
      cities = locations
          .where((loc) => loc.state == value)
          .map((loc) => loc.name)
          .toSet()
          .toList();

      // Clear pincodes
      pincodes = [];
    });
  }

  void onCityChanged(String? value) {
    setState(() {
      selectedCity = value;
      formData.city = selectedCity;
      selectedPincode = null;

      // Filter pincodes by city
      pincodes = locations
          .where((loc) => loc.name == value)
          .map((loc) => loc.pincode)
          .toSet()
          .toList();
    });
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
      "phone": _phoneController.text,
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
          ...teacher.timeslot!,
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful'),
            duration: Duration(seconds: 1),
          ),
        );
        userSkipped
            ? sendOTP(_phoneController.text)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SplashScreen(phone: _phoneController.text),
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

  Future<void> sendOTP(String phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumber);
    final url = Uri.parse(
      '$otpapi/SMS/+91$phoneNumber/AUTOGEN3/TRUSIR_OTP',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('OTP sent successfully: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Sent Successfully'),
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(
                      phonenum: phoneNumber,
                    )));
      } else {
        print('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('Error sending OTP: $e');
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
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isAdditionalLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : isWeb
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/groupregister.png',
                              width: 400,
                            ),
                          ),
                          // Teacher's basic information
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTextField('Teacher Name',
                                  onChanged: (value) {
                                formData.teacherName = value;
                              }),
                              const SizedBox(width: 50),
                              _buildTextField("Father's Name",
                                  onChanged: (value) {
                                formData.fathersName = value;
                              }),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTextField("Mother's Name",
                                  onChanged: (value) {
                                formData.mothersName = value;
                              }),
                              const SizedBox(width: 50),
                              _buildPhoneField('Phone Number'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Gender and DOB Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 1,
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
                                flex: 2,
                                child: _buildDropdownField(
                                  'Qualification',
                                  selectedValue: formData.qualification,
                                  onChanged: (value) {
                                    setState(() {
                                      formData.qualification = value;
                                    });
                                  },
                                  items: additionals['qualification'],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 2,
                                child: _buildDropdownField(
                                  'Experience',
                                  selectedValue: formData.experience,
                                  onChanged: (value) {
                                    setState(() {
                                      formData.experience = value;
                                    });
                                  },
                                  items: additionals['experience'],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 1,
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
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildMultiSelectDropdownField(
                                'Preferred Board',
                                selectedValues: selectedBoard,
                                onChanged: (List<String> values) {
                                  setState(() {
                                    selectedBoard = values;
                                    formData.board = selectedBoard.join(',');
                                  });
                                },
                                items: additionals['board'],
                              ),
                              const SizedBox(width: 50),
                              _buildTextField('School Name',
                                  onChanged: (value) {
                                formData.school = value;
                              }),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: _buildMultiSelectDropdownField(
                                  'Preferred Class',
                                  selectedValues: selectedClass,
                                  onChanged: (List<String> values) {
                                    setState(() {
                                      selectedClass = values;
                                      formData.preferredclass =
                                          selectedClass.join(',');
                                    });
                                  },
                                  items: _classes,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildMultiSelectDropdownField(
                                  'Preferred Medium',
                                  selectedValues: selectedMedium,
                                  onChanged: (List<String> values) {
                                    setState(() {
                                      selectedMedium = values;
                                      formData.medium =
                                          selectedMedium.join(',');
                                    });
                                  },
                                  items: additionals['mediums'],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildMultiSelectDropdownField(
                                  'Subject',
                                  selectedValues: selectedSubjects,
                                  onChanged: (List<String> values) {
                                    setState(() {
                                      selectedSubjects = values;
                                      formData.subject =
                                          selectedSubjects.join(',');
                                    });
                                  },
                                  items: _courses,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  'State',
                                  selectedValue: selectedState,
                                  onChanged: (value) {
                                    onStateChanged(value);
                                  },
                                  items: states,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedState == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please select a state first.'),
                                        duration: Duration(seconds: 2),
                                      ));
                                    } else {
                                      null;
                                    }
                                  },
                                  child: _buildDropdownField(
                                    'City/Town',
                                    selectedValue: selectedCity,
                                    onChanged: (value) {
                                      onCityChanged(value);
                                    },
                                    items: cities,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildTextField('Mohalla/Area',
                                    onChanged: (value) {
                                  formData.area = value;
                                }),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedState == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Please select a state first.'),
                                        duration: Duration(seconds: 2),
                                      ));
                                    } else if (selectedCity == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content:
                                            Text('Please select a city first.'),
                                        duration: Duration(seconds: 2),
                                      ));
                                    } else {
                                      null;
                                    }
                                  },
                                  child: _buildDropdownField(
                                    'Pincode',
                                    selectedValue: selectedPincode,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPincode = value;
                                        formData.pincode = selectedPincode;
                                      });
                                    },
                                    items: pincodes,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Address fields
                          Row(
                            children: [
                              Expanded(
                                child: _buildAddressField(
                                    'Current Full Address', onChanged: (value) {
                                  formData.caddress = value;
                                }),
                              ),
                              const SizedBox(width: 50),
                              Expanded(
                                child:
                                    _buildAddressField('Permanent Full Address',
                                        onChanged: (value) {
                                  formData.paddress = value;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Upload Sections
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      'Profile Photo',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  isprofileuploading
                                      ? const CircularProgressIndicator()
                                      : _buildFileUploadField('Upload Image',
                                          width: 220, onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black
                                                .withValues(alpha: 0.3),
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .lightBlue
                                                              .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromCamera(
                                                                'photo');
                                                          },
                                                          child: const Text(
                                                            "Camera",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      // Button for "I'm a Teacher"
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromGallery(
                                                                'photo');
                                                          },
                                                          child: const Text(
                                                            "Upload File",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }, displayPath: formData.photoPath),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      'Aadhar Card Front',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  isadhaarfuploading
                                      ? const CircularProgressIndicator()
                                      : _buildFileUploadField('Upload File',
                                          width: 220, onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black
                                                .withValues(alpha: 0.3),
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .lightBlue
                                                              .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromCamera(
                                                                'adhaarFront');
                                                          },
                                                          child: const Text(
                                                            "Camera",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      // Button for "I'm a Teacher"
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromGallery(
                                                                'adhaarFront');
                                                          },
                                                          child: const Text(
                                                            "Upload File",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                          displayPath:
                                              formData.aadharFrontPath),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      'Aadhar Card Back',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  isadhaarbuploading
                                      ? const CircularProgressIndicator()
                                      : _buildFileUploadField('Upload File',
                                          width: 220, onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black
                                                .withValues(alpha: 0.3),
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .lightBlue
                                                              .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromCamera(
                                                                'adhaarBack');
                                                          },
                                                          child: const Text(
                                                            "Camera",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      // Button for "I'm a Teacher"
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromGallery(
                                                                'adhaarBack');
                                                          },
                                                          child: const Text(
                                                            "Upload File",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                          displayPath: formData.aadharBackPath),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(
                                      'Signature',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  issignuploading
                                      ? const CircularProgressIndicator()
                                      : _buildFileUploadField('Upload Image',
                                          onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.black
                                                .withValues(alpha: 0.3),
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .lightBlue
                                                              .shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromCamera(
                                                                'sign');
                                                          },
                                                          child: const Text(
                                                            "Camera",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 16),
                                                      // Button for "I'm a Teacher"
                                                      Container(
                                                        width: 200,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(22),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            handleUploadFromGallery(
                                                                'sign');
                                                          },
                                                          child: const Text(
                                                            "Upload File",
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                color: Colors
                                                                    .black,
                                                                fontFamily:
                                                                    'Poppins'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                          width: 220,
                                          displayPath: formData.signaturePath),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          TimeSlotField(formData: formData, isWeb: isWeb),
                          const SizedBox(height: 50),

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
                              const Text('I agree with the ',
                                  style: TextStyle(fontSize: 20)),
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
                                    fontSize: 20,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Registration Fee
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                child: Text(
                                  'Free',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 20.0,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Center(
                                child: Text(
                                  '299 ',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Colors.grey.shade700,
                                    fontFamily: 'Poppins',
                                    fontSize: 18,
                                    color: Colors.grey.shade700,
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
                          // Register Button
                          _buildRegisterButton(context),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        const SizedBox(height: 20),
                        _buildTextField("Father's Name", onChanged: (value) {
                          formData.fathersName = value;
                        }),
                        const SizedBox(height: 20),
                        _buildTextField("Mother's Name", onChanged: (value) {
                          formData.mothersName = value;
                        }),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        _buildPhoneField('Phone Number'),
                        const SizedBox(height: 15),
                        _buildDropdownField(
                          'Qualification',
                          selectedValue: formData.qualification,
                          onChanged: (value) {
                            setState(() {
                              formData.qualification = value;
                            });
                          },
                          items: additionals['qualification'],
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownField(
                          'Experience',
                          selectedValue: formData.experience,
                          onChanged: (value) {
                            setState(() {
                              formData.experience = value;
                            });
                          },
                          items: additionals['experience'],
                        ),
                        const SizedBox(height: 15),
                        _buildMultiSelectDropdownField(
                          'Preferred Board',
                          selectedValues: selectedBoard,
                          onChanged: (List<String> values) {
                            setState(() {
                              selectedBoard = values;
                              formData.board = selectedBoard.join(',');
                            });
                          },
                          items: additionals['board'],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField('School Name', onChanged: (value) {
                          formData.school = value;
                        }),
                        const SizedBox(height: 15),
                        // Dropdowns
                        _buildMultiSelectDropdownField(
                          'Preferred Class',
                          selectedValues: selectedClass,
                          onChanged: (List<String> values) {
                            setState(() {
                              selectedClass = values;
                              formData.preferredclass = selectedClass.join(',');
                            });
                          },
                          items: _classes,
                        ),
                        const SizedBox(height: 15),
                        _buildMultiSelectDropdownField(
                          'Preferred Medium',
                          selectedValues: selectedMedium,
                          onChanged: (List<String> values) {
                            setState(() {
                              selectedMedium = values;
                              formData.medium = selectedMedium.join(',');
                            });
                          },
                          items: additionals['mediums'],
                        ),
                        const SizedBox(height: 15),
                        _buildMultiSelectDropdownField(
                          'Subject',
                          selectedValues: selectedSubjects,
                          onChanged: (List<String> values) {
                            setState(() {
                              selectedSubjects = values;
                              formData.subject = selectedSubjects.join(',');
                            });
                          },
                          items: _courses,
                        ),
                        const SizedBox(height: 15),
                        _buildDropdownField(
                          'State',
                          selectedValue: selectedState,
                          onChanged: (value) {
                            onStateChanged(value);
                          },
                          items: states,
                        ),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (selectedState == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Please select a state first.'),
                                duration: Duration(seconds: 2),
                              ));
                            } else {
                              null;
                            }
                          },
                          child: _buildDropdownField(
                            'City/Town',
                            selectedValue: selectedCity,
                            onChanged: (value) {
                              onCityChanged(value);
                            },
                            items: cities,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField('Mohalla/Area', onChanged: (value) {
                          formData.area = value;
                        }),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () {
                            if (selectedState == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Please select a state first.'),
                                duration: Duration(seconds: 2),
                              ));
                            } else if (selectedCity == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Please select a city first.'),
                                duration: Duration(seconds: 2),
                              ));
                            } else {
                              null;
                            }
                          },
                          child: _buildDropdownField(
                            'Pincode',
                            selectedValue: selectedPincode,
                            onChanged: (value) {
                              setState(() {
                                selectedPincode = value;
                                formData.pincode = selectedPincode;
                              });
                            },
                            items: pincodes,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Address fields
                        _buildAddressField('Current Full Address',
                            onChanged: (value) {
                          formData.caddress = value;
                        }),
                        const SizedBox(height: 20),
                        _buildAddressField('Permanent Full Address',
                            onChanged: (value) {
                          formData.paddress = value;
                        }),
                        const SizedBox(height: 20),

                        // Upload Sections
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 58),
                              child: Text(
                                'Profile Photo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isprofileuploading
                                ? const CircularProgressIndicator()
                                : _buildFileUploadField('Upload Image',
                                    width: 171, onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .lightBlue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromCamera(
                                                          'photo');
                                                    },
                                                    child: const Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Button for "I'm a Teacher"
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.orange.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromGallery(
                                                          'photo');
                                                    },
                                                    child: const Text(
                                                      "Upload File",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isadhaarfuploading
                                ? const CircularProgressIndicator()
                                : _buildFileUploadField('Upload File',
                                    width: 170, onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .lightBlue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromCamera(
                                                          'adhaarFront');
                                                    },
                                                    child: const Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Button for "I'm a Teacher"
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.orange.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromGallery(
                                                          'adhaarFront');
                                                    },
                                                    child: const Text(
                                                      "Upload File",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
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
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isadhaarbuploading
                                ? const CircularProgressIndicator()
                                : _buildFileUploadField('Upload File',
                                    width: 170, onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .lightBlue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromCamera(
                                                          'adhaarBack');
                                                    },
                                                    child: const Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Button for "I'm a Teacher"
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.orange.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromGallery(
                                                          'adhaarBack');
                                                    },
                                                    child: const Text(
                                                      "Upload File",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }, displayPath: formData.aadharBackPath),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 79),
                              child: Text(
                                'Signature',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            issignuploading
                                ? const CircularProgressIndicator()
                                : _buildFileUploadField('Upload Image',
                                    onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withValues(alpha: 0.3),
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.all(16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors
                                                        .lightBlue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromCamera(
                                                          'sign');
                                                    },
                                                    child: const Text(
                                                      "Camera",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                // Button for "I'm a Teacher"
                                                Container(
                                                  width: 200,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.orange.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            22),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      handleUploadFromGallery(
                                                          'sign');
                                                    },
                                                    child: const Text(
                                                      "Upload File",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Poppins'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                    width: 171,
                                    displayPath: formData.signaturePath),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TimeSlotField(formData: formData, isWeb: isWeb),
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
                            const Center(
                              child: Text(
                                'Free',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Center(
                              child: Text(
                                '299 ',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey.shade700,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
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
                        // Register Button
                        _buildRegisterButton(context),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          formData.agreetoterms == true
              ? postTeacherData(teacherFormsData: [formData])
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

  Widget _buildAddressField(
    String hintText, {
    required ValueChanged<String> onChanged,
  }) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      width: isWeb ? 700 : double.infinity,
      height: 150, // Set a fixed height for the container
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
        expands: true, // Makes the TextField expand to fit its parent container
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

  Widget _buildTextField(
    String hintText, {
    double height = 48,
    required ValueChanged<String> onChanged,
  }) {
    bool isWeb = MediaQuery.of(context).size.width > 500;
    return Container(
      height: height,
      width: isWeb ? 500 : 700,
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
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildPhoneField(
    String hintText,
  ) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      height: 48,
      width: isWeb ? 700 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: TextField(
        enabled: userSkipped,
        controller: _phoneController,
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
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildMultiSelectDropdownField(
    String hintText, {
    required List<String> selectedValues,
    required ValueChanged<List<String>> onChanged,
    required List<String> items,
  }) {
    String selectedText = selectedValues.join(', ');

    return StatefulBuilder(
      builder: (context, setState) {
        bool isWeb = MediaQuery.of(context).size.width > 600;
        return Container(
          height: 48,
          width: isWeb ? 700 : double.infinity,
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
          child: DropdownButtonFormField<String>(
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
              isDense: true,
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: StatefulBuilder(
                      builder: (context, setStateInner) {
                        return CheckboxListTile(
                          title: Text(
                            item,
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                          value: selectedValues.contains(item),
                          onChanged: (bool? isChecked) {
                            if (isChecked == true) {
                              if (!selectedValues.contains(item)) {
                                selectedValues.add(item);
                              }
                            } else {
                              selectedValues.remove(item);
                            }
                            // Update the concatenated text
                            selectedText = selectedValues.join(', ');

                            // Pass the updated list to the parent
                            onChanged(selectedValues);
                            setStateInner(() {}); // Update the UI for this item
                            setState(() {}); // Update the display string
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                )
                .toList(),
            onChanged: (_) {
              // No need for action here since selection happens in the checkbox
            },
            isExpanded: true,
            value: null,
            hint: selectedText.isNotEmpty
                ? Text(
                    selectedText,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w400),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(
    String hintText, {
    String? selectedValue,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      height: 48,
      width: isWeb ? 700 : double.infinity,
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
          isDense: true,
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
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
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      height: 48,
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
              EdgeInsets.symmetric(horizontal: 16, vertical: isWeb ? 21 : 23),
          suffixIcon: Icon(icon),
          isDense: true,
        ),
        controller: TextEditingController(text: value ?? ''),
      ),
    );
  }

  Widget _buildFileUploadField(String placeholder,
      {required displayPath,
      required VoidCallback? onTap,
      required int width}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 170,
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
  final dynamic formData;
  final bool isWeb; // Assuming you have a FormData class with timeslot field

  const TimeSlotField({super.key, required this.formData, required this.isWeb});

  @override
  TimeSlotFieldState createState() => TimeSlotFieldState();
}

class TimeSlotFieldState extends State<TimeSlotField> {
  final Map<String, String> slotToApiKey = {
    '6-7 AM': 't6am_7am',
    '7-8 AM': 't7am_8am',
    '8-9 AM': 't8am_9am',
    '9-10 AM': 't9am_10am',
    '10-11 AM': 't10am_11am',
    '11-12 PM': 't11am_12pm',
    '12-1 PM': 't12pm_1pm',
    '1-2 PM': 't1pm_2pm',
    '2-3 PM': 't2pm_3pm',
    '3-4 PM': 't3pm_4pm',
    '4-5 PM': 't4pm_5pm',
    '5-6 PM': 't5pm_6pm',
    '6-7 PM': 't6pm_7pm',
    '7-8 PM': 't7pm_8pm',
  };

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
    '4-5 PM'
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

      // Update the timeslot field in the form data
      widget.formData.timeslot = slotToApiKey.map((key, apiKey) {
        return MapEntry(apiKey, selectedSlots.contains(key));
      });
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
      child: widget.isWeb
          ? Column(
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Morning Hours',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: morningSlots.map(buildSlot).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Afternoon Hours',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8.0),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: afternoonSlots.map(buildSlot).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evening Hours',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w600),
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
                  ],
                ),
              ],
            )
          : Column(
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
