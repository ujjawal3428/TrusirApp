import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/editprofile_splash_screen.dart';

class TeacherEditProfileScreen extends StatefulWidget {
  const TeacherEditProfileScreen({super.key});

  @override
  TeacherEditProfileScreenState createState() =>
      TeacherEditProfileScreenState();
}

class TeacherEditProfileScreenState extends State<TeacherEditProfileScreen> {
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

  Future<String> uploadImage() async {
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
          profile = jsonResponse['download_url'];
        });
        return jsonResponse['download_url'] as String;
      } else {
        Fluttertoast.showToast(msg: 'Download URL not found in the response.');
        return 'null';
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to upload image: ${response.statusCode}');
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

  Future<void> handleImageSelection() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final fileSize =
            await pickedFile.length(); // Get the file size in bytes

        // Check if file size exceeds 2MB (2 * 1024 * 1024 bytes)
        if (fileSize > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('File size exceeds 2MB. Please select a smaller image.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      if (pickedFile != null) {
        // Upload the image and get the path
        final uploadedPath = await uploadImageSelective(pickedFile);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/back_button.png', height: 50)),
            const SizedBox(width: 20),
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontSize: 25,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
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
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.3),
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
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  uploadImage();
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
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  handleImageSelection();
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
