import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/editprofile_splash_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  File? _profileImage;
  String? name;
  String? dob;
  String? school;
  String? studentClass;
  String? subject;
  String? profile;
  String? userID;
  String? address;
  String? token;
  String? phone;
  DateTime? selectedDOB;
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

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
        dobController.text = dateFormatter.format(selectedDOB!);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      name = prefs.getString('name');
      token = prefs.getString('token');
      dob = prefs.getString('DOB');
      school = prefs.getString('school');
      studentClass = prefs.getString('class');
      subject = prefs.getString('subject');
      profile = prefs.getString('profile');
      address = prefs.getString('address');
      phone = prefs.getString('phone_number');
      nameController.text = name!;
      dobController.text = dob!;
      schoolController.text = school!;
      classController.text = studentClass!;
      subjectController.text = subject!;
    });
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
            profile = uploadedPath;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image Uploaded Successfully!'),
                duration: Duration(seconds: 1),
              ),
            );
            //')
            //)
          });
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

  Future<void> _saveprofile({
    required String name,
    required String dob,
    required String school,
    required String studentClass,
    required String subject,
    required String profile,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/edit-profile/$userID'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add if your API requires a token
        },
        body: jsonEncode({
          'name': name,
          'DOB': dob,
          'school': school,
          'class': studentClass,
          'profile': profile,
          'subject': subject,
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EditSplashScreen()),
          (route) => false,
        );

        // Success
        print("Data posted successfully: ${response.body}");
      } else {
        // Error
        print("Failed to post data: ${response.statusCode}");
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF48116A),
            fontSize: 22,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF48116A)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveprofile(
                name: nameController.text,
                dob: dobController.text,
                school: schoolController.text,
                studentClass: classController.text,
                subject: subjectController.text,
                profile: profile!,
                token: token!,
              );
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: () {
                handleImageSelection(profile);
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: isLargeScreen ? 80 : 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : NetworkImage(profile!) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt, color: Color(0xFF48116A)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Input Fields
            buildInputField('Enter your name', nameController, isLargeScreen),
            const SizedBox(height: 15),
            _buildTextFieldWithIcon(
              dob!,
              Icons.calendar_today,
              onTap: () => _selectDOB(context),
              value: selectedDOB != null
                  ? "${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}"
                  : null,
            ),
            const SizedBox(height: 15),
            buildInputField(
                'Enter your school', schoolController, isLargeScreen),
            // const SizedBox(height: 15),
            // _buildDropdownField(
            //   'Class',
            //   selectedValue: classController.text,
            //   onChanged: (value) {
            //     setState(() {
            //       classController.text = value!;
            //     });
            //   },
            //   items: [
            //     '10th',
            //     '11th',
            //     '12th',
            //   ],
            // ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _saveprofile(
                  name: nameController.text,
                  dob: dobController.text,
                  school: schoolController.text,
                  studentClass: classController.text,
                  subject: subjectController.text,
                  profile: profile!,
                  token: token!,
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: const Color(0xFF48116A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget _buildDropdownField(
  //   String hintText, {
  //   String? selectedValue,
  //   required ValueChanged<String?> onChanged,
  //   required List<String> items,
  // }) {
  //   return Container(
  //     height: 58,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(22),
  //       border: Border.all(color: Colors.grey),
  //       boxShadow: [
  //         BoxShadow(
  //             color: Colors.grey.shade200, blurRadius: 4, spreadRadius: 2),
  //       ],
  //     ),
  //     child: DropdownButtonFormField<String>(
  //       value: selectedValue,
  //       onChanged: onChanged,
  //       decoration: InputDecoration(
  //         labelText: hintText,
  //         border: InputBorder.none,
  //         contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //       ),
  //       items: items
  //           .map((item) => DropdownMenuItem(
  //                 value: item,
  //                 child: Text(item),
  //               ))
  //           .toList(),
  //     ),
  //   );
  // }

  Widget _buildTextFieldWithIcon(
    String hintText,
    IconData icon, {
    required VoidCallback onTap,
    String? value,
  }) {
    return Container(
      height: 58,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('DOB:', style: TextStyle(color: Colors.grey[800])),
            const SizedBox(width: 5),
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

  Widget buildInputField(
      String hint, TextEditingController controller, bool isLargeScreen) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: isLargeScreen ? 18 : 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(fontSize: isLargeScreen ? 18 : 14),
    );
  }
}
