import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/image_uploading.dart';
import 'package:trusir/student/your_doubt.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDoubts {
  String? title;
  String? course;
  String? photo;
  String? teacherID;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'course': course,
      'image': photo,
      'teacher_userID': teacherID,
    };
  }
}

class Course {
  final String courseName;
  final String teacherID;

  Course({required this.courseName, required this.teacherID});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['courseName'] as String,
      teacherID: json['teacherID'] as String,
    );
  }
}

class StudentDoubtScreen extends StatefulWidget {
  const StudentDoubtScreen({super.key});

  @override
  State<StudentDoubtScreen> createState() => _StudentDoubtScreenState();
}

class _StudentDoubtScreenState extends State<StudentDoubtScreen> {
  bool _isDropdownOpen = false;
  List<Course> _courses = [];
  String _selectedCourse = '-- Select Course --';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _teacherIDController = TextEditingController();
  final StudentDoubts formData = StudentDoubts();
  String extension = '';
  bool isimageUploading = false;

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
    fetchAllCourses();
  }

  Future<void> fetchAllCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
    final url = Uri.parse('$baseUrl/get-courses/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Course> courses = data.map<Course>((courseJson) {
        return Course.fromJson(courseJson as Map<String, dynamic>);
      }).toList();

      // Use a Set to filter out duplicates
      final Set<String> uniqueCourseNames = {};
      final List<Course> uniqueCourses = [];

      for (var course in courses) {
        if (uniqueCourseNames.add(course.courseName)) {
          // Only add the course if its name is not already in the set
          uniqueCourses.add(course);
        }
      }

      if (mounted) {
        setState(() {
          _courses = uniqueCourses; // Update _courses with the filtered list
        });
      }
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<void> submitForm(BuildContext context) async {
    // Fetch the entered data
    formData.title = _titleController.text;
    formData.course = _courseController.text;
    formData.teacherID = _teacherIDController.text;

    // Validation: Check if any field is empty
    if (formData.title == null || formData.title!.isEmpty) {
      setState(() {
        formData.title = "No Title";
      });
    }

    if (formData.course == null || formData.course!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Select a course!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (formData.photo == null || formData.photo!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload the image'),
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
        Fluttertoast.showToast(msg: 'Failed to submit form: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error occurred: $e');
    }
  }

  Future<void> handleUploadFromCamera() async {
    final String result = await ImageUploadUtils.uploadImagesFromCamera();

    if (result != 'null') {
      setState(() {
        isimageUploading = false;
        if (formData.photo == null || formData.photo!.isEmpty) {
          formData.photo = result; // Add if no existing images
        } else {
          formData.photo = '${formData.photo},$result'; // Append new images
        }
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {
        isimageUploading = false;
      });
    }
  }

  Future<void> handleUploadFromGallery() async {
    final String result = await ImageUploadUtils.uploadImagesFromGallery();

    if (result != 'null') {
      setState(() {
        isimageUploading = false;
        if (formData.photo == null || formData.photo!.isEmpty) {
          formData.photo = result; // Add if no existing images
        } else {
          formData.photo = '${formData.photo},$result'; // Append new images
        }
      });
      Fluttertoast.showToast(msg: 'Images uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {
        isimageUploading = false;
      });
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
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/back_button.png', height: 50)),
                const SizedBox(width: 20),
                const Text(
                  'Student Doubt',
                  style: TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YourDoubtPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu))
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
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
                                color: Colors.black.withValues(alpha: 0.2),
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
                                  color: Colors.black.withValues(alpha: 0.2),
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
                            child: _courses.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No courses available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _courses.map((course) {
                                      return ListTile(
                                        title: Text(course.courseName),
                                        onTap: () {
                                          setState(() {
                                            _selectedCourse = course.courseName;
                                            _courseController.text =
                                                course.courseName;
                                            _teacherIDController.text =
                                                course.teacherID;
                                            print(course.teacherID);
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
                                    child: isimageUploading
                                        ? const CircularProgressIndicator()
                                        : Container(
                                            width: 150,
                                            height: 133,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14.40),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.2),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: formData.photo != null
                                                ? GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        barrierColor: Colors
                                                            .black
                                                            .withOpacity(0.3),
                                                        builder: (BuildContext
                                                            context) {
                                                          List<String> images =
                                                              formData.photo!
                                                                  .split(',');

                                                          return Dialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    "Uploaded Images",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  GridView
                                                                      .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    physics:
                                                                        const NeverScrollableScrollPhysics(),
                                                                    gridDelegate:
                                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                                      crossAxisCount:
                                                                          3,
                                                                      crossAxisSpacing:
                                                                          10,
                                                                      mainAxisSpacing:
                                                                          10,
                                                                    ),
                                                                    itemCount:
                                                                        images
                                                                            .length,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return Stack(
                                                                        children: [
                                                                          Column(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Image.network(
                                                                                  images[index],
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 5),
                                                                              Text(
                                                                                images[index],
                                                                                style: const TextStyle(
                                                                                  fontSize: 8,
                                                                                  color: Colors.blue,
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child:
                                                                                GestureDetector(
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  images.removeAt(index);
                                                                                  formData.photo = images.join(','); // Update URL string
                                                                                });
                                                                                Fluttertoast.showToast(
                                                                                  msg: 'Image removed!',
                                                                                );
                                                                              },
                                                                              child: const CircleAvatar(
                                                                                radius: 12,
                                                                                backgroundColor: Colors.red,
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.white,
                                                                                  size: 16,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: [
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          setState(
                                                                              () {
                                                                            isimageUploading =
                                                                                true;
                                                                          });
                                                                          handleUploadFromCamera();
                                                                        },
                                                                        child: const Text(
                                                                            "Camera"),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                          setState(
                                                                              () {
                                                                            isimageUploading =
                                                                                true;
                                                                          });
                                                                          handleUploadFromGallery();
                                                                        },
                                                                        child: const Text(
                                                                            "Gallery"),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Image.network(
                                                      formData.photo!
                                                          .split(',')
                                                          .first,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        barrierColor: Colors
                                                            .black
                                                            .withValues(
                                                                alpha: 0.3),
                                                        builder: (BuildContext
                                                            context) {
                                                          return Dialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .all(16),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
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
                                                                          BorderRadius.circular(
                                                                              22),
                                                                    ),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        setState(
                                                                            () {
                                                                          isimageUploading =
                                                                              true;
                                                                        });
                                                                        handleUploadFromCamera();
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        "Camera",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.black,
                                                                            fontFamily: 'Poppins'),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          16),
                                                                  // Button for "I'm a Teacher"
                                                                  Container(
                                                                    width: 200,
                                                                    height: 50,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .orange
                                                                          .shade100,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              22),
                                                                    ),
                                                                    child:
                                                                        TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        setState(
                                                                            () {
                                                                          isimageUploading =
                                                                              true;
                                                                        });
                                                                        handleUploadFromGallery();
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        "Upload File",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            color:
                                                                                Colors.black,
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
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
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
                                                              color:
                                                                  Colors.black,
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
                                                              color:
                                                                  Colors.black,
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
                                                  .withValues(alpha: 0.2),
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
