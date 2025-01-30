import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/image_uploading.dart';

class GK {
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

class AddGK extends StatefulWidget {
  final String studentuserID;
  const AddGK({super.key, required this.studentuserID});

  @override
  State<AddGK> createState() => _AddGKState();
}

class _AddGKState extends State<AddGK> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final GK formData = GK();
  String extension = '';
  bool isimageUploading = false;

  Future<void> handleUploadFromCamera() async {
    final String result = await ImageUploadUtils.uploadSingleImageFromCamera();

    if (result != 'null') {
      setState(() {
        setState(() {
          formData.photo = result;
          isimageUploading = false;
        });
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
    final String result = await ImageUploadUtils.uploadSingleImageFromGallery();

    if (result != 'null') {
      setState(() {
        setState(() {
          formData.photo = result;
          isimageUploading = false;
        });
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {
        isimageUploading = false;
      });
    }
  }

  Future<void> submitForm(BuildContext context) async {
    // Fetch the entered data
    formData.title = titleController.text;
    formData.description = descriptionController.text;

    // Validation: Check if any field is empty
    if (formData.title == null || formData.title!.isEmpty) {
      setState(() {
        formData.title = "No Title";
      });
    }

    if (formData.description == null || formData.description!.isEmpty) {
      setState(() {
        formData.description = "No Description";
      });
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
    final url =
        Uri.parse('$baseUrl/api/tecaher-gks/$userId/${widget.studentuserID}');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(formData.toJson());

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Successfully submitted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GK Posted Successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Add GK',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
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
            Container(
              height: 168,
              width: double.infinity, // Responsive width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                controller: descriptionController,
                maxLines: null, // Allows the text to wrap and grow vertically
                textAlignVertical:
                    TextAlignVertical.top, // Ensures text starts from the top
                expands:
                    true, // Makes the TextField expand to fit its parent container
                decoration: InputDecoration(
                  labelText: 'Description',
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
                    horizontal: 16,
                    vertical:
                        12, // Adjust vertical padding for better alignment
                  ),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: isimageUploading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
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
                                          handleUploadFromCamera();
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
                                          handleUploadFromGallery();
                                        },
                                        child: const Text(
                                          "Upload File",
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
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: double.infinity, // Responsive width
                          height: 168,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Center(
                              child: formData.photo != null
                                  ? Image.network(formData.photo!)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 30),
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
                                            textAlign: TextAlign.center,
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
                                            'Click Here',
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
                      ),
                    ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'This post will only be visible to the\nstudents you teach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildPostButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildPostButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          submitForm(context);
        },
        child: Image.asset(
          'assets/postbutton.png',
          width: double.infinity,
          height: 70,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
