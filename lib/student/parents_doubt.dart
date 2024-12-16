import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:url_launcher/url_launcher.dart';

class ParentsDoubt {
  String? title;
  String? description;
  String? photo;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image': photo,
    };
  }
}

class ParentsDoubtScreen extends StatefulWidget {
  const ParentsDoubtScreen({super.key});

  @override
  State<ParentsDoubtScreen> createState() => ParentsDoubtScreenState();
}

class ParentsDoubtScreenState extends State<ParentsDoubtScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final ParentsDoubt formData = ParentsDoubt();

  Future<void> openDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> submitForm(BuildContext context) async {
    // Fetch the entered data
    formData.title = titleController.text.trim();
    formData.description = descriptionController.text.trim();

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

    if (formData.description == null || formData.description!.isEmpty) {
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
    final url = Uri.parse('$baseUrl/api/add-parents-doubts/$userId');
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
                'Parents Doubt',
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
              formData.title = titleController.text;
              formData.description = descriptionController.text;
            });
            submitForm(context);
          },
          elevation: 0, // To match the gradient
          backgroundColor:
              const Color(0xFF48116A), // Transparent for gradient to show
          child: const Icon(
            Icons.add, // Plus icon
            color: Colors.white,
            size: 50, // Icon size
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: constraints.maxWidth * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.50),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: titleController,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Title',
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: const BorderSide(
                                  width: 1,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 168,
                              width: constraints.maxWidth *
                                  0.65, // Responsive width
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.20),
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: descriptionController,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'Description',
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 120, horizontal: 20),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    borderSide: const BorderSide(
                                      width: 1,
                                      color: Color.fromARGB(255, 212, 211, 211),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                handleFileSelection(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  width: constraints.maxWidth *
                                      0.2, // Responsive width
                                  height: 168,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(14.40),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.white,
                                          offset: Offset(2, 2),
                                        )
                                      ]),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 30),
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
                                              textAlign: TextAlign.center,
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
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.width * 0.02),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: MediaQuery.of(context).size.height *
                                        0.2,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(14.40),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.white54,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.04),
                                          child: Image.asset(
                                            'assets/whatsapp@3x.png',
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.015,
                                        ),
                                        const Center(
                                          child: Text(
                                            'WhatsApp',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.01,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    openDialer('9797472922');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.2,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(14.40),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.white54,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.04),
                                                child: Image.asset(
                                                  'assets/phone@3x.png',
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.12,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.015,
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
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.01,
                                              ),
                                              const Center(
                                                child: Text(
                                                  'Click here',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
