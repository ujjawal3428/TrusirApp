import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? drawing;
  StudentDoubtScreen({super.key, this.drawing});

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

  Future<void> openDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
    if (widget.drawing != null) {
      formData.photo = widget.drawing;
    }
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
    // Fetch the entered data
    formData.title = _titleController.text.trim();
    formData.course = _courseController.text.trim();

    // Validation: Check if any field is empty
    if (formData.title == null || formData.title!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (formData.course == null || formData.course!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description cannot be empty!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
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

  Future<void> handleFileSelection(BuildContext context) async {
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
        final uploadedPath = await uploadFile(filePath, fileType);

        if (uploadedPath != 'null') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File Uploaded Successfully!'),
              duration: Duration(seconds: 1),
            ),
          );
          print('File uploaded successfully: $uploadedPath');
          formData.photo = uploadedPath;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
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
        body: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(children: [
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Title',
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
                              contentPadding: const EdgeInsets.only(left: 20),
                              hintText: 'Type Here...',
                              hintStyle: const TextStyle(
                                  color: Colors.grey, fontSize: 17),
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
                                horizontal: 15, vertical: 10),
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
                                        fontSize: 17),
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
                              top: 20.0,
                            ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10, left: 2, right: 2, top: 2),
                                    child: Container(
                                      width: 150,
                                      height: 133,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(14.40),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.20),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: formData.photo != null
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Image.network(
                                                    width: 100,
                                                    height: 100,
                                                    formData.photo!,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(
                                                      Icons
                                                          .picture_as_pdf_rounded,
                                                      size: 50,
                                                    ),
                                                  ),
                                                ),
                                                const Center(
                                                  child: Text(
                                                    'File Uploaded',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 7,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                handleFileSelection(context);
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 15),
                                                    child: Image.asset(
                                                      'assets/camera@3x.png',
                                                      width: 46,
                                                      height: 37,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Center(
                                                    child: Text(
                                                      'Upload Image',
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
                                                    child: Text(
                                                      'Click here',
                                                      style: TextStyle(
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
                                  GestureDetector(
                                    onTap: () {
                                      openDialer('9797472922');
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
                                          // border: Border.all(width: 1,color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(14.40),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.20),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/phone@3x.png',
                                              width: 46,
                                              height: 37,
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
                                              child: Text(
                                                'Click here',
                                                style: TextStyle(
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
                                ]),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        _buildSubmitButton(context)
                      ]),
                ),
              ]),
            ),
          ],
        ));
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            formData.title = _titleController.text;
          });
          submitForm(context);
        },
        child: Image.asset(
          'assets/submit.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
