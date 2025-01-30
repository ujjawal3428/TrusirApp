import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/image_uploading.dart';
import 'package:trusir/teacher/add_gk.dart';
import 'package:trusir/teacher/teacher_facilities.dart';

class AddGkTeacher extends StatefulWidget {
  final List<StudentProfile> studentprofile;
  const AddGkTeacher({super.key, required this.studentprofile});

  @override
  State<AddGkTeacher> createState() => _AddGkTeacherState();
}

class _AddGkTeacherState extends State<AddGkTeacher> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedStudent;
  String? selecteduserID;
  List<String> names = [];
  final GK formData = GK();
  List<StudentProfile> students = [];
  Map<String, String> nameUserMap = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      students = widget.studentprofile;
      extractStudentData(students, names, nameUserMap);
    });
  }

  void extractStudentData(List<StudentProfile> students, List<String> names,
      Map<String, String> nameUserIDMap) {
    for (var student in students) {
      names.add(student.name);
      nameUserIDMap[student.name] = student.userID;
    }
  }

  Future<void> handleUploadFromCamera() async {
    final String result = await ImageUploadUtils.uploadSingleImageFromCamera();

    if (result != 'null') {
      setState(() {
        setState(() {
          formData.photo = result;
        });
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
      setState(() {});
    }
  }

  Future<void> handleUploadFromGallery() async {
    final String result = await ImageUploadUtils.uploadSingleImageFromGallery();

    if (result != 'null') {
      setState(() {
        setState(() {
          formData.photo = result;
        });
      });
      Fluttertoast.showToast(msg: 'Image uploaded successfully!');
    } else {
      Fluttertoast.showToast(msg: 'Image upload failed!');
    }
  }

  Future<void> submitForm() async {
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
    final url = Uri.parse('$baseUrl/api/tecaher-gks/$userId/$selecteduserID');
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
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset('assets/back_button.png', height: 50),
            ),
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
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildDropdownField(),
            const SizedBox(height: 15),
            _buildTextField(titleController, 'Title'),
            const SizedBox(height: 15),
            _buildTextField(descriptionController, 'Description', maxLines: 5),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => _showImagePickerDialog(context),
                child: Container(
                  width: double.infinity,
                  height: 168,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: formData.photo != null
                        ? Image.network(formData.photo!)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/camera@3x.png',
                                  width: 46, height: 37),
                              const SizedBox(height: 10),
                              const Text('Upload Image',
                                  style: TextStyle(fontSize: 14)),
                              const SizedBox(height: 5),
                              const Text('Click Here',
                                  style: TextStyle(fontSize: 10)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'This post will only be visible to the\nstudents you teach',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14, color: Colors.red, fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 20),
            _buildPostButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedStudent,
          hint: const Text('Select Student'),
          items: names.map((String student) {
            return DropdownMenuItem<String>(
              value: student,
              child: Text(student),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedStudent = value;
              selecteduserID = nameUserMap[value]; // Get userID from map
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
                width: 0.5, color: Color.fromARGB(255, 237, 234, 234)),
          ),
        ),
      ),
    );
  }

  Widget _buildPostButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          submitForm();
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

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogButton('Camera', Colors.lightBlue.shade100, () {
                  Navigator.pop(context);
                  handleUploadFromCamera();
                }),
                const SizedBox(height: 16),
                _buildDialogButton('Upload File', Colors.orange.shade100, () {
                  Navigator.pop(context);
                  handleUploadFromGallery();
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildDialogButton(String text, Color color, VoidCallback onPressed) {
  return Container(
    width: 200,
    height: 50,
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
    child: TextButton(
      onPressed: onPressed,
      child: Text(text,
          style: const TextStyle(
              fontSize: 18, color: Colors.black, fontFamily: 'Poppins')),
    ),
  );
}
