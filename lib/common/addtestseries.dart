import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/image_uploading.dart';

class Addtestseries extends StatefulWidget {
  final String userID;
  const Addtestseries({super.key, required this.userID});

  @override
  State<Addtestseries> createState() => _AddtestseriesState();
}

class _AddtestseriesState extends State<Addtestseries> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;
  final TextEditingController _testNameController = TextEditingController();
  String? photo;
  String answer = '';
  bool isQuestion = false;
  bool isAnswer = false;
  bool isquestionUploading = false;
  bool isanswerUploading = false;
  String question = '';
  List<String> _courses = [];
  String extension = '';

  Future<void> fetchAllCourses() async {
    final url = Uri.parse('$baseUrl/all-course');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (mounted) {
        setState(() {
          _courses = data.map<String>((course) {
            return course['name'] as String;
          }).toList();
        });
      }
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<void> handleUploadFromCamera() async {
    final String result = await ImageUploadUtils.uploadImagesFromCamera();

    if (result != 'null') {
      setState(() {
        if (isQuestion) {
          question = result;
          isquestionUploading = false;
          isQuestion = false;
        } else if (isAnswer) {
          answer = result;
          isanswerUploading = false;
          isAnswer = false;
        } // Save the download URL in the local variable
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
    }
  }

  Future<void> handleUploadFromGallery() async {
    final String result = await ImageUploadUtils.uploadImagesFromGallery();

    if (result != 'null') {
      setState(() {
        if (isQuestion) {
          question = result;
          isquestionUploading = false;
          isQuestion = false;
        } else if (isAnswer) {
          answer = result;
          isanswerUploading = false;
          isAnswer = false;
        }
        // Save the download URL in the local variable
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');

      setState(() {
        if (isQuestion) {
          isquestionUploading = false;
        } else if (isAnswer) {
          isanswerUploading = false;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllCourses();
  }

  // Function to send data to the API
  Future<void> _sendTestData(String testName, String subject) async {
    // Get the current date and time
    final now = DateTime.now();
    final currentDate = "${now.year}-${now.month}-${now.day}";
    final currentTime = "${now.hour}:${now.minute}";

    final userID = widget.userID;

    // Construct the API payload
    final postData = {
      "userID": userID, // Replace with dynamic user ID if available
      "test_name": testName,
      "question": question,
      "answer": answer,
      "subject": subject,
      "date": currentDate,
      "time": currentTime,
    };
    print("${postData["question"]}  ${postData["answer"]}");

    // Send the POST request
    const apiUrl =
        "$baseUrl/api/store-test-series"; // Replace with your API URL
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(postData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test uploaded successfully!')),
        );
        Navigator.pop(context);
        print(postData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload test.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Test Name
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: TextFormField(
                    controller: _testNameController,
                    decoration: InputDecoration(
                        fillColor: Colors.white,
                        labelText: 'Test Name',
                        labelStyle: TextStyle(color: Colors.grey.shade500),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        isDense: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the test name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Subject Dropdown
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  iconSize: 25,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  value: selectedSubject,
                  items: _courses.map((String subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: Colors.grey.shade500),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    isDense: true,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a subject';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 7),
                    child: isquestionUploading
                        ? const CircularProgressIndicator()
                        : Container(
                            width: 100,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  7.2), // Adjusted for smaller size
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha(50), // Adjusted opacity
                                  offset: const Offset(1, 1), // Scaled offset
                                  blurRadius: 2, // Scaled blur radius
                                ),
                              ],
                            ),
                            child: question.isNotEmpty
                                ? Image.network(question)
                                : GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor:
                                            Colors.black.withAlpha(77),
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding:
                                                const EdgeInsets.all(8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Scaled radius
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 200,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .lightBlue.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              11),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          isQuestion = true;
                                                          isquestionUploading =
                                                              true;
                                                        });
                                                        handleUploadFromCamera();
                                                      },
                                                      child: const Text(
                                                        "Camera",
                                                        style: TextStyle(
                                                            fontSize:
                                                                12, // Adjusted font size
                                                            color: Colors.black,
                                                            fontFamily:
                                                                'Poppins'),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 200,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              11),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          isQuestion = true;
                                                          isquestionUploading =
                                                              true;
                                                        });
                                                        handleUploadFromGallery();
                                                      },
                                                      child: const Text(
                                                        "Upload File",
                                                        style: TextStyle(
                                                            fontSize:
                                                                12, // Adjusted font size
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
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Icon(
                                            Icons.upload_file_rounded,
                                            size: 23,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Center(
                                          child: Text(
                                            'Upload Questions',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9, // Scaled font size
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Click here',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey,
                                              fontSize: 9,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 7),
                    child: isanswerUploading
                        ? const CircularProgressIndicator()
                        : Container(
                            width: 100,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.2),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: answer.isNotEmpty
                                ? Image.network(answer)
                                : GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierColor:
                                            Colors.black.withAlpha(77),
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding:
                                                const EdgeInsets.all(8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: 200,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .lightBlue.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              11),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          isAnswer = true;
                                                          isanswerUploading =
                                                              true;
                                                        });
                                                        handleUploadFromCamera();
                                                      },
                                                      child: const Text(
                                                        "Camera",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            fontFamily:
                                                                'Poppins'),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: 200,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .orange.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              11),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          isAnswer = true;
                                                          isanswerUploading =
                                                              true;
                                                        });
                                                        handleUploadFromGallery();
                                                      },
                                                      child: const Text(
                                                        "Upload File",
                                                        style: TextStyle(
                                                            fontSize: 12,
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
                                    child: const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Icon(
                                            Icons.upload_file_rounded,
                                            color: Colors.indigo,
                                            size: 23,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Center(
                                          child: Text(
                                            'Upload Answers',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Click here',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 9,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                  ),
                ],
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: _buildCreateButton(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            if (question == '') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload Question')),
              );
              return;
            } else if (answer == '') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload Answer')),
              );
              return;
            }
            _sendTestData(
              _testNameController.text,
              selectedSubject!,
            );
          }
        },
        child: Image.asset(
          'assets/create_test.png',
          width: double.infinity,
          height: 60,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
