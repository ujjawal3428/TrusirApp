import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:trusir/common/otp_screen.dart';
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
  String? board;
  String? studentClass;
  String? subject;
  String? state;
  String? city;
  List<String> cities = [];
  List<String> pins = [];
  String? area;
  String? pincode;
  String? address;
  Map<String, bool>? timeslot; // Changed to Map
  String? photoPath;
  String? aadharFrontPath;
  String? aadharBackPath;
  bool? agreetoterms;

  Map<String, dynamic> toJson() {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    return {
      'name': studentName,
      'father_name': fathersName,
      'mother_name': mothersName,
      'gender': gender,
      'DOB': dob != null ? dateFormatter.format(dob!) : null,
      'school': schoolName,
      'medium': medium,
      'class': studentClass,
      'board': board,
      'subject': subject,
      'state': state,
      'city': city,
      'area': area,
      'pincode': pincode,
      'address': address,
      ...?timeslot, // Merge timeslot map directly into the payload
      'profile': photoPath,
      'adhaar_front': aadharFrontPath,
      'adhaar_back': aadharBackPath,
      'agree_to_terms': agreetoterms,
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
  dynamic additionals;
  String? subject;
  DateTime? selectedDOB;
  bool agreeToTerms = false;
  final TextEditingController _phoneController = TextEditingController();
  bool userSkipped = false;
  List<Location> locations = [];
  List<String> selectedSubjects = [];
  bool isimageUploading = false;
  bool isadhaarBUploading = false;
  bool isadhaarFUploading = false;
  List<String> _classes = [];

  // Filtered lists
  List<String> states = [];
  List<String> _courses = [];
  bool isAdditionalsLoading = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    updateStudentForms(1);
    fetchAllCourses();
    numberOfStudents = '1';
    fetchLocations();
    selectedSubjectsPerForm = List.generate(
      studentForms.length,
      (_) => [],
    );
    organizeAdditionals();
  }

  List<List<String>> selectedSubjectsPerForm = [];

  Future<String> uploadImage(int index, String path) async {
    setState(() {
      // Example: Update the first student's photo path
      if (path == 'photo') {
        isimageUploading = true;
      } else if (path == 'aadharBack') {
        isadhaarBUploading = true;
      } else if (path == 'aadharFront') {
        isadhaarFUploading = true;
      }
    });
    await _requestPermissions();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      Fluttertoast.showToast(msg: 'No image selected.');
      return 'null';
    }

    // Compress the image
    final compressedImage = await compressImage(File(image.path));

    if (compressedImage == null) {
      Fluttertoast.showToast(msg: 'Failed to compress image.');
      return 'null';
    }

    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri);

    // Add the compressed image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('photo', compressedImage.path));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 201) {
      // Parse the response to extract the download URL
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (jsonResponse.containsKey('download_url')) {
        setState(() {
          if (path == 'photo') {
            studentForms[index].photoPath = jsonResponse['download_url'];
            isimageUploading = false;
          } else if (path == 'adhaarFront') {
            studentForms[index].aadharFrontPath = jsonResponse['download_url'];
            isadhaarFUploading = false;
          } else if (path == 'adhaarBack') {
            studentForms[index].aadharBackPath = jsonResponse['download_url'];
            isadhaarBUploading = false;
          }
        });

        return jsonResponse['download_url'] as String;
      } else {
        Fluttertoast.showToast(msg: 'Download URL not found in the response.');
        setState(() {
          isimageUploading = false;
          isadhaarFUploading = false;
          isadhaarBUploading = false;
        });
        return 'null';
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to upload image: ${response.statusCode}');
      setState(() {
        isimageUploading = false;
        isadhaarFUploading = false;
        isadhaarBUploading = false;
      });
      return 'null';
    }
  }

// Function to compress image
  Future<XFile?> compressImage(File file) async {
    final String targetPath =
        '${file.parent.path}/compressed_${file.uri.pathSegments.last}';

    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85, // Adjust quality to achieve ~2MB size
        minWidth: 1920, // Adjust resolution as needed
        minHeight: 1080, // Adjust resolution as needed
      );

      return compressedFile;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error compressing image: $e');
      return null;
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isGranted &&
        await Permission.camera.isGranted) {
      return;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

      // Skip permissions for Android versions below API 30
      if (androidInfo.version.sdkInt < 30) {
        return;
      }

      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.camera.isGranted) {
        return;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.camera
      ].request();

      if (statuses.values.any((status) => !status.isGranted)) {
        openAppSettings();
      }
    }
  }

  // Load the phone number from SharedPreferences
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

  Future<Map<String, List<String>>> fetchAndOrganizeAdditionals() async {
    setState(() {
      isAdditionalsLoading = true;
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
      isAdditionalsLoading = false;
    });
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

  String? uploadedPath;

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
        print(studentFormsData[0].timeslot);
        print(studentFormsData[1].timeslot);
        return; // Stop execution if any field is invalid
      }
    }

    final Map<String, dynamic> payload = {
      "phone": _phoneController.text,
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
          "board": student.board,
          "area": student.area,
          "pincode": student.pincode,
          ...student.timeslot!,
          "address": student.address,
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
            content: Text('User Already Exists! Proceed to Login'),
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

  Future<String> uploadImageSelective(XFile imageFile) async {
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
    setState(() {
      // Example: Update the first student's photo path
      if (path == 'profilephoto') {
        isimageUploading = true;
      } else if (path == 'aadharBackPath') {
        isadhaarBUploading = true;
      } else if (path == 'aadharFrontPath') {
        isadhaarFUploading = true;
      }
    });
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      setState(() {
        isimageUploading = true;
      });

      if (pickedFile != null) {
        final fileSize =
            await pickedFile.length(); // Get the file size in bytes

        // Check if file size exceeds 2MB (2 * 1024 * 1024 bytes)
        if (fileSize > 2 * 1024 * 1024) {
          Fluttertoast.showToast(
              msg: 'File size exceeds 2MB. Please select a smaller image.');
          return;
        }
      }

      if (pickedFile != null) {
        // Upload the image and get the path
        final newuploadedPath = await uploadImageSelective(pickedFile);
        if (newuploadedPath != 'null') {
          setState(() {
            // Example: Update the first student's photo path
            if (path == 'profilephoto') {
              studentForms[index].photoPath = newuploadedPath;
              isimageUploading = false;
            } else if (path == 'aadharBackPath') {
              studentForms[index].aadharBackPath = newuploadedPath;
              isadhaarBUploading = false;
            } else if (path == 'aadharFrontPath') {
              studentForms[index].aadharFrontPath = newuploadedPath;
              isadhaarFUploading = false;
            }
          });

          Fluttertoast.showToast(
              msg: 'Image uploaded successfully: $uploadedPath');
        } else {
          Fluttertoast.showToast(msg: 'Failed to upload the image.');
          setState(() {
            isimageUploading = false;
            isadhaarFUploading = false;
            isadhaarBUploading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'No image selected.');
        setState(() {
          isimageUploading = false;
          isadhaarFUploading = false;
          isadhaarBUploading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error during image selection: $e');
      setState(() {
        isimageUploading = false;
        isadhaarFUploading = false;
        isadhaarBUploading = false;
      });
    }
  }

  List<StudentRegistrationData> studentForms = [];

  void updateStudentForms(int count) {
    setState(() {
      if (count > studentForms.length) {
        // Add new StudentRegistrationData entries
        studentForms.addAll(List.generate(
          count - studentForms.length,
          (_) => StudentRegistrationData(),
        ));

        // Add empty lists for the new forms in selectedSubjectsPerForm
        selectedSubjectsPerForm.addAll(
          List.generate(count - selectedSubjectsPerForm.length, (_) => []),
        );
      } else if (count < studentForms.length) {
        // Remove extra entries from studentForms
        studentForms.removeRange(count, studentForms.length);

        // Remove extra entries from selectedSubjectsPerForm
        selectedSubjectsPerForm.removeRange(
            count, selectedSubjectsPerForm.length);
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
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Scaffold(
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
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image
              Center(
                child: Image.asset(
                  'assets/studentregisteration@4x.png',
                  width: isWeb ? 400 : 256,
                  height: isWeb ? null : 200,
                ),
              ),
              isWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPhoneField("Phone Number"),
                        const SizedBox(
                          width: 50,
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
                          items: List.generate(
                              3, (index) => (index + 1).toString()),
                        ),
                      ],
                    )
                  : Column(
                      children: [
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
                          items: List.generate(
                              3, (index) => (index + 1).toString()),
                        ),
                      ],
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
              SizedBox(height: isWeb ? 50 : 20),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              agreeToTerms = value!;
                            });
                          },
                        ),
                        Text('I agree with the ',
                            style: TextStyle(
                              fontSize: isWeb ? 20 : null,
                            )),
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
                          child: Text(
                            'Terms and Conditions',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: isWeb ? 20 : null,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isWeb ? 50 : 20),
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
                      const Center(
                        child: Text(
                          '299/-',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.0,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
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
                  const SizedBox(height: 20),
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
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return isAdditionalsLoading
        ? const Center(child: CircularProgressIndicator())
        : isWeb
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      'Student ${index + 1}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField('Student Name', onChanged: (value) {
                          studentForms[index].studentName = value;
                        }),
                        const SizedBox(width: 50),
                        _buildTextField("Father's Name", onChanged: (value) {
                          studentForms[index].fathersName = value;
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTextField("Mother's Name", onChanged: (value) {
                          studentForms[index].mothersName = value;
                        }),
                        const SizedBox(width: 50),
                        _buildTextField('School Name', onChanged: (value) {
                          studentForms[index].schoolName = value;
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildDropdownField(
                            'Gender',
                            selectedValue: studentForms[index]
                                .gender, // Use unique value per student
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
                          flex: 1,
                          child: _buildTextFieldWithIcon(
                            'DOB',
                            Icons.calendar_today,
                            onTap: () => _selectDOB(context,
                                index), // Pass the index to identify which student
                            value: studentForms[index].dob != null
                                ? "${studentForms[index].dob!.day}/${studentForms[index].dob!.month}/${studentForms[index].dob!.year}"
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: _buildDropdownField(
                            'Class',
                            selectedValue: studentForms[index].studentClass,
                            onChanged: (value) {
                              setState(() {
                                studentForms[index].studentClass = value;
                              });
                            },
                            items: _classes,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            'Medium',
                            selectedValue: studentForms[index].medium,
                            onChanged: (value) {
                              setState(() {
                                studentForms[index].medium = value;
                              });
                            },
                            items: additionals['mediums'] ?? ['-Select-'],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDropdownField(
                            'Board',
                            selectedValue: studentForms[index].board,
                            onChanged: (value) {
                              setState(() {
                                studentForms[index].board = value;
                              });
                            },
                            items: additionals['board'] ?? ['-Select-'],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildMultiSelectDropdownField('Subject',
                              selectedValues: selectedSubjectsPerForm[index],
                              onChanged: (List<String> values) {
                            setState(() {
                              selectedSubjects = values;
                              studentForms[index].subject =
                                  selectedSubjects.join(',');
                            });
                          },
                              items: _courses,
                              selectedText:
                                  studentForms[index].subject ?? 'Select'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
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
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (studentForms[index].state == null) {
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
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildTextField('Mohalla/Area',
                              onChanged: (value) {
                            studentForms[index].area = value;
                          }),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (studentForms[index].state == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Please select a state first.'),
                                  duration: Duration(seconds: 2),
                                ));
                              } else if (studentForms[index].city == null) {
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
                              selectedValue: studentForms[index].pincode,
                              onChanged: (value) {
                                setState(() {
                                  studentForms[index].pincode = value;
                                });
                              },
                              items: studentForms[index].pins,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildAddressField('Full Address', onChanged: (value) {
                      studentForms[index].address = value;
                    }),
                    const SizedBox(height: 50),

                    // Photo Upload Section
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isimageUploading
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
                                                      uploadImage(
                                                          index, 'photo');
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
                                                      handleImageSelection(
                                                          'profilephoto',
                                                          index);
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
                                    width: 250,
                                    displayPath: studentForms[index].photoPath),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'Aadhar Card Front',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isadhaarFUploading
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
                                                      uploadImage(
                                                          index, 'adhaarFront');
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
                                                      handleImageSelection(
                                                          'aadharFrontPath',
                                                          index);
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
                                    width: 250,
                                    displayPath:
                                        studentForms[index].aadharFrontPath),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                'Aadhar Card Back',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            isadhaarBUploading
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
                                                      uploadImage(
                                                          index, 'adhaarBack');
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
                                                      handleImageSelection(
                                                          'aadharBackPath',
                                                          index);
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
                                    width: 250,
                                    displayPath:
                                        studentForms[index].aadharBackPath),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    TimeSlotField(
                      formData: studentForms[index],
                      isWeb: isWeb,
                    ), // Pass index to handle each form's state
                    const SizedBox(height: 10),
                    // Add more fields as needed
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 10),
                  Text(
                    'Student ${index + 1}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
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
                          selectedValue: studentForms[index]
                              .gender, // Use unique value per student
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
                          onTap: () => _selectDOB(context,
                              index), // Pass the index to identify which student
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
                    items: additionals['mediums'],
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
                    items: _classes,
                  ),
                  const SizedBox(height: 10),
                  _buildDropdownField(
                    'Board',
                    selectedValue: studentForms[index].board,
                    onChanged: (value) {
                      setState(() {
                        studentForms[index].board = value;
                      });
                    },
                    items: additionals['board'],
                  ),
                  const SizedBox(height: 10),
                  _buildMultiSelectDropdownField('Subject',
                      selectedValues: selectedSubjectsPerForm[index],
                      onChanged: (List<String> values) {
                    setState(() {
                      selectedSubjects = values;
                      studentForms[index].subject = selectedSubjects.join(',');
                    });
                  },
                      items: _courses,
                      selectedText: studentForms[index].subject ?? 'Select'),
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Please select a state first.'),
                          duration: Duration(seconds: 2),
                        ));
                      } else if (studentForms[index].city == null) {
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      isimageUploading
                          ? const CircularProgressIndicator()
                          : _buildFileUploadField('Upload Image', onTap: () {
                              showDialog(
                                context: context,
                                barrierColor:
                                    Colors.black.withValues(alpha: 0.3),
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                uploadImage(index, 'photo');
                                              },
                                              child: const Text(
                                                "Camera",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Button for "I'm a Teacher"
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                handleImageSelection(
                                                    'profilephoto', index);
                                              },
                                              child: const Text(
                                                "Upload File",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
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
                              displayPath: studentForms[index].photoPath),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      isadhaarFUploading
                          ? const CircularProgressIndicator()
                          : _buildFileUploadField('Upload Image', onTap: () {
                              showDialog(
                                context: context,
                                barrierColor:
                                    Colors.black.withValues(alpha: 0.3),
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                uploadImage(
                                                    index, 'adhaarFront');
                                              },
                                              child: const Text(
                                                "Camera",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Button for "I'm a Teacher"
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                handleImageSelection(
                                                    'aadharFrontPath', index);
                                              },
                                              child: const Text(
                                                "Upload File",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
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
                              width: 170,
                              displayPath: studentForms[index].aadharFrontPath),
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
                      isadhaarBUploading
                          ? const CircularProgressIndicator()
                          : _buildFileUploadField('Upload Image', onTap: () {
                              showDialog(
                                context: context,
                                barrierColor:
                                    Colors.black.withValues(alpha: 0.3),
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                uploadImage(
                                                    index, 'adhaarBack');
                                              },
                                              child: const Text(
                                                "Camera",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Button for "I'm a Teacher"
                                          Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                handleImageSelection(
                                                    'aadharBackPath', index);
                                              },
                                              child: const Text(
                                                "Upload Image",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                    fontFamily: 'Poppins'),
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
                              width: 170,
                              displayPath: studentForms[index].aadharBackPath),
                    ],
                  ),
                  const SizedBox(height: 30),
                  TimeSlotField(
                    formData: studentForms[index],
                    isWeb: isWeb,
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
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
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
              horizontal: 16,
              vertical: isWeb
                  ? height == 126
                      ? 50
                      : 21
                  : height == 126
                      ? 50
                      : 23),
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
      height: 150,
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

  Widget _buildPhoneField(
    String hintText,
  ) {
    bool isWeb = MediaQuery.of(context).size.width > 500;
    return Container(
      height: 58,
      width: isWeb ? 500 : 700,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
        controller: _phoneController,
        enabled: userSkipped,
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
              EdgeInsets.symmetric(horizontal: 16, vertical: isWeb ? 21 : 23),
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
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Container(
      height: 58,
      width: isWeb ? 500 : double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
        ],
      ),
      child: DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
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
              EdgeInsets.symmetric(horizontal: 16, vertical: isWeb ? 21 : 17),
          isDense: true,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildMultiSelectDropdownField(
    String hintText, {
    required List<String> selectedValues,
    required ValueChanged<List<String>> onChanged,
    required List<String> items,
    required String selectedText,
  }) {
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 58,
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
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isWeb ? 21 : 17,
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
                          title: Text(item),
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
                    style: const TextStyle(color: Colors.black),
                  )
                : null,
          ),
        );
      },
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

  Widget _buildFileUploadField(
    String placeholder, {
    required VoidCallback onTap,
    double width = 200,
    required displayPath,
  }) {
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
              child: isLoading
                  ? const CircularProgressIndicator()
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
