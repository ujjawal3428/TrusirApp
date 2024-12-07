import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';

class StudentDoubts {
  String? title;
  String? course;
  String? photo;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'course': course,
      'image': photo,
    };
  }
}

class StudentDoubtScreen extends StatefulWidget {
  const StudentDoubtScreen({super.key});

  @override
  State<StudentDoubtScreen> createState() => _StudentDoubtScreenState();
}

class _StudentDoubtScreenState extends State<StudentDoubtScreen> {
  bool _isDropdownOpen = false;
  List<String> _courses = [];
  String _selectedCourse = '-- Select Course --';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final StudentDoubts formData = StudentDoubts();

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-course/testID'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _courses = List<String>.from(data);
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  Future<void> submitForm(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
    print(userId);
    final url = Uri.parse('$baseUrl/api/add-student-doubts/$userId');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doubt Submitted Successfully!'),
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);

        print(body);
      } else {
        // Handle error
        print('Failed to submit form: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
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
            formData.photo = uploadedPath;
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
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error during image selection: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
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
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 5),
                const Text(
                  'Student Doubt',
                  style: TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.grey[300]!, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                formData.title = _titleController.text;
              });
              submitForm(context);
            },
            elevation: 0, // To match the gradient
            backgroundColor:
                const Color(0xFF48116A), // Transparent for gradient to show
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 50,
            ), // Plus icon
            // Icon size
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Submit Your Doubt',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF48116A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Test Title',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: const BorderSide(
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35),
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Course',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDropdownOpen = !_isDropdownOpen;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    _selectedCourse,
                                    style: TextStyle(
                                      color: _selectedCourse ==
                                              '-- Select Course --'
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isDropdownOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isDropdownOpen)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: _courses.map((course) {
                                return ListTile(
                                  title: Text(course),
                                  onTap: () {
                                    setState(() {
                                      _selectedCourse = course;
                                      _courseController.text = course;
                                      _isDropdownOpen = false;
                                      formData.course = _selectedCourse;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 40.0,
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      handleImageSelection(formData.photo);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10,
                                          left: 2,
                                          right: 2,
                                          top: 2),
                                      child: Container(
                                        width: 150,
                                        height: 133,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(14.40),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.white54,
                                                offset: Offset(2, 2),
                                              )
                                            ]),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 30),
                                              child: formData.photo != null
                                                  ? Image.network(
                                                      width: 50,
                                                      height: 50,
                                                      formData.photo!)
                                                  : Image.asset(
                                                      'assets/camera@3x.png',
                                                      width: 46,
                                                      height: 37,
                                                    ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Center(
                                              child: Text(
                                                formData.photo != null
                                                    ? 'Image Uploaded'
                                                    : 'Upload Image',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Center(
                                              child: Text(
                                                formData.photo != null
                                                    ? ''
                                                    : 'Click Here',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, left: 2, right: 2, top: 2),
                                    child: Container(
                                      width: 150,
                                      height: 133,
                                      decoration: BoxDecoration(
                                          // border: Border.all(width: 1,color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(14.40),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.white54,
                                              offset: Offset(2, 2),
                                            )
                                          ]),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 30),
                                            child: Image.asset(
                                              'assets/phone@3x.png',
                                              width: 46,
                                              height: 37,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Center(
                                            child: Text(
                                              'Call Teacher',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const Center(
                                            child: InkWell(
                                              child: Text(
                                                'Click here',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ]),
                ),
              ]),
            ),
          ],
        ));
  }
}
