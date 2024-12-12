import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trusir/common/api.dart';

class Addtestseries extends StatefulWidget {
  const Addtestseries({super.key});

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

  Future<String?> _getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userID'); // Retrieve 'userID' from storage
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

  final List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'History'
  ];

  // Function to send data to the API
  Future<void> _sendTestData(String testName, String subject) async {
    // Get the current date and time
    final now = DateTime.now();
    final currentDate = "${now.year}-${now.month}-${now.day}";
    final currentTime = "${now.hour}:${now.minute}";

    final userID = await _getUserID();
    if (userID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

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
                'Test Series',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Test Name
              TextFormField(
                controller: _testNameController,
                decoration: InputDecoration(
                  labelText: 'Test Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Subject Dropdown
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  question != null
                      ? Image.network(width: 50, height: 50, question!)
                      : SizedBox(
                          height: 40,
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() async {
                                question = await handleFileSelection(context);
                              }); // Here, implement the file picker logic for questions
                            },
                            icon: const Icon(Icons.upload_file),
                            label: const Text(
                              'Upload Questions',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                  answer != null
                      ? Image.network(width: 50, height: 50, answer!)
                      : SizedBox(
                          height: 40,
                          width: 150,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() async {
                                answer = await handleFileSelection(context);
                              });
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
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendTestData(
                      _testNameController.text,
                      selectedSubject!,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48116A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Upload Test',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
