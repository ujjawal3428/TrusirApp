import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:trusir/common/api.dart';

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

  @override
  void initState() {
    super.initState();
    fetchAllCourses();
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

  Future<String> uploadFile(String filePath, String fileType) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri);

    // Add the file to the request with the correct field name
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 201) {
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
    setState(() {
      if (isQuestion) {
        isquestionUploading = true;
      } else if (isAnswer) {
        isanswerUploading = true;
      }
    });
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result != null && result.files.isNotEmpty) {
        List<String> uploadedUrls = [];

        for (final file in result.files) {
          final filePath = file.path;
          final fileName = file.name;
          final fileSize = file.size;

          if (filePath == null) {
            continue;
          }

          if (fileSize > 2 * 1024 * 1024) {
            Fluttertoast.showToast(
                msg: '$fileName exceeds 2MB. Skipping upload.');
            continue;
          }

          final fileType = fileName.endsWith('.jpg') ||
                  fileName.endsWith('.jpeg') ||
                  fileName.endsWith('.png')
              ? 'photo'
              : 'document';

          final uploadedPath = await uploadFile(filePath, fileType);

          if (uploadedPath != 'null') {
            uploadedUrls.add(uploadedPath);
            Fluttertoast.showToast(
                msg: '$fileName uploaded successfully: $uploadedPath');
          } else {
            Fluttertoast.showToast(msg: 'Failed to upload file: $fileName');
            setState(() {
              isquestionUploading = false;
              isanswerUploading = false;
            });
          }
        }

        if (uploadedUrls.isNotEmpty) {
          final resultString = uploadedUrls.join(', ');
          if (uploadedUrls.length > 1) {
            Fluttertoast.showToast(
                msg: 'All files uploaded successfully: $resultString');
          } else {
            Fluttertoast.showToast(
                msg: 'File uploaded successfully: ${uploadedUrls[0]}');
          }

          setState(() {
            if (isQuestion) {
              question = resultString;
              isQuestion = false;
              isquestionUploading = false;
            } else if (isAnswer) {
              answer = resultString;
              isAnswer = false;
              isanswerUploading = false;
            }
          });
        } else {
          Fluttertoast.showToast(msg: 'No files uploaded.');
          setState(() {
            isquestionUploading = false;
            isanswerUploading = false;
          });
        }
      } else {
        Fluttertoast.showToast(msg: 'No file selected.');
        setState(() {
          isquestionUploading = false;
          isanswerUploading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error during file selection: $e');
      setState(() {
        isquestionUploading = false;
        isanswerUploading = false;
      });
    }
  }

  Widget _buildFilePreview(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      // Display the image preview
      return Image.network(
        fileUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 50);
        },
      );
    } else {
      // Display an icon for non-image file types
      return Icon(
        _getIconForFile(fileUrl),
        size: 50,
        color: _getIconColorForFile(fileUrl),
      );
    }
  }

  IconData _getIconForFile(String url) {
    extension = url.split('.').last;
    if (extension == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (extension == 'docx' || extension == 'doc') {
      return Icons.description;
    } else if (extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'png') {
      return Icons.image;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getIconColorForFile(String url) {
    extension = url.split('.').last;
    if (extension == 'pdf') {
      return Colors.red;
    } else if (extension == 'docx' || extension == 'doc') {
      return Colors.blue;
    } else if (extension == 'png' ||
        extension == 'jpg' ||
        extension == 'jpeg') {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Future<String> uploadImage() async {
    setState(() {
      if (isQuestion) {
        isquestionUploading = true;
      } else if (isAnswer) {
        isanswerUploading = true;
      }
    });
    await _requestPermissions();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      Fluttertoast.showToast(msg: 'No image selected.');
      setState(() {
        isquestionUploading = false;
        isanswerUploading = false;
      });
      return 'null';
    }

    // Compress the image
    final compressedImage = await compressImage(File(image.path));

    if (compressedImage == null) {
      Fluttertoast.showToast(msg: 'Failed to compress image.');
      setState(() {
        isquestionUploading = false;
        isanswerUploading = false;
      });
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
        if (isQuestion) {
          setState(() {
            question = jsonResponse['download_url'];
            isQuestion = false;
            isquestionUploading = false;
          });
        } else if (isAnswer) {
          setState(() {
            answer = jsonResponse['download_url'];
            isAnswer = false;
            isanswerUploading = false;
          });
        }
        return jsonResponse['download_url'] as String;
      } else {
        Fluttertoast.showToast(msg: 'Download URL not found in the response.');
        setState(() {
          isquestionUploading = false;
          isanswerUploading = false;
        });
        return 'null';
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to upload image: ${response.statusCode}');
      setState(() {
        isquestionUploading = false;
        isanswerUploading = false;
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _testNameController,
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: 'Test Name',
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
                          horizontal: 16, vertical: 17),
                      isDense: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the test name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Subject Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedSubject,
                  items: _courses.map((String subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Subject',
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
                        horizontal: 16, vertical: 17),
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
      padding: const EdgeInsets.only(left: 10.0),
      child: isquestionUploading
          ? const CircularProgressIndicator()
          : Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.2), // Adjusted for smaller size
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50), // Adjusted opacity
                    offset: const Offset(1, 1), // Scaled offset
                    blurRadius: 2, // Scaled blur radius
                  ),
                ],
              ),
              child: question.isNotEmpty
                  ? _buildFilePreview(question)
                  : GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withAlpha(77),
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Scaled radius
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue.shade100,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isQuestion = true;
                                          });
                                          uploadImage();
                                        },
                                        child: const Text(
                                          "Camera",
                                          style: TextStyle(
                                              fontSize: 12, // Adjusted font size
                                              color: Colors.black,
                                              fontFamily: 'Poppins'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 200,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isQuestion = true;
                                          });
                                          handleFileSelection(context);
                                        },
                                        child: const Text(
                                          "Upload File",
                                          style: TextStyle(
                                              fontSize: 12, // Adjusted font size
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5), // Adjusted padding
                            child: Image.asset(
                              'assets/camera@3x.png',
                              width: 23, // Scaled width
                              height: 18.5, // Scaled height
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Center(
                            child: Text(
                              'Upload Questions',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 7, // Scaled font size
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Center(
                            child: Text(
                              'Click here',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 5, // Scaled font size
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
            ),
    ),
    Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: isanswerUploading
          ? const CircularProgressIndicator()
          : Container(
              width: 80,
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
                  ? _buildFilePreview(answer)
                  : GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withAlpha(77),
                          builder: (BuildContext context) {
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.lightBlue.shade100,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isAnswer = true;
                                          });
                                          uploadImage();
                                        },
                                        child: const Text(
                                          "Camera",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontFamily: 'Poppins'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: 200,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            isAnswer = true;
                                          });
                                          handleFileSelection(context);
                                        },
                                        child: const Text(
                                          "Upload File",
                                          style: TextStyle(
                                              fontSize: 12,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Image.asset(
                              'assets/camera@3x.png',
                              width: 23,
                              height: 18.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Center(
                            child: Text(
                              'Upload Answers',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Center(
                            child: Text(
                              'Click here',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 5,
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
