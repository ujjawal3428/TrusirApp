import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String? answer;
  String? question;
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

  Future<String?> handleFileSelection(BuildContext context) async {
    try {
      // Use FilePicker to select a file
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size; // File size in bytes

        // Check if file size exceeds 2MB (2 * 1024 * 1024 bytes)
        if (fileSize > 2 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('File size exceeds 2MB. Please select a smaller file.'),
              duration: Duration(seconds: 2),
            ),
          );
          return null; // Exit the method
        }

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
          return uploadedPath;
        } else {
          print('Failed to upload the file.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to upload the file.(Only upload pdf, docx and image)'),
              duration: Duration(seconds: 1),
            ),
          );
          return null;
        }
      } else {
        print('No file selected.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            duration: Duration(seconds: 1),
          ),
        );
        return null;
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
      return null;
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
      return Icons.insert_drive_file; // Default icon for unknown file types
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
      return Colors.grey; // Default color for unknown file types
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
      height: MediaQuery.of(context).size.height * 0.38,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Test Name
              TextFormField(
                controller: _testNameController,
                decoration: InputDecoration(
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Subject Dropdown
              DropdownButtonFormField<String>(
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
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
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  question != null
                      ? _buildFilePreview(question!)
                      : SizedBox(
                          height: 40,
                          width: 150,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final selectedFile =
                                  await handleFileSelection(context);
                              if (selectedFile != null) {
                                setState(() {
                                  question = selectedFile;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text(
                              'Upload Questions',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                  answer != null
                      ? _buildFilePreview(answer!)
                      : SizedBox(
                          height: 40,
                          width: 150,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              backgroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final selectedFile =
                                  await handleFileSelection(context);
                              if (selectedFile != null) {
                                setState(() {
                                  answer = selectedFile;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text(
                              'Upload Answers',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 20),
              // Submit Button
              Padding(
                padding: const EdgeInsets.all(8.0),
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
            if (question == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload Question')),
              );
              return;
            } else if (answer == null) {
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
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
