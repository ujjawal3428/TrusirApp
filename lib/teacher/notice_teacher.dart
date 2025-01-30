import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/teacher_facilities.dart';

class AddNoticeTeacher extends StatefulWidget {
  final List<StudentProfile> studentprofile;
  const AddNoticeTeacher({super.key, required this.studentprofile});

  @override
  State<AddNoticeTeacher> createState() => _AddNoticeTeacherState();
}

class _AddNoticeTeacherState extends State<AddNoticeTeacher> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedStudent;
  String? selectedUserID;
  List<String> names = [];
  List<StudentProfile> students = [];
  Map<String, String> nameUserMap = {};

  void extractStudentData(List<StudentProfile> students, List<String> names,
      Map<String, String> nameUserIDMap) {
    for (var student in students) {
      names.add(student.name);
      nameUserIDMap[student.name] = student.userID;
    }
  }

  Future<void> _onPost() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherUserID = prefs.getString('userID');
    final String currentDate =
        DateTime.now().toIso8601String(); // ISO 8601 format

    final payload = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'posted_on': currentDate,
      'to': selectedUserID,
      'from': teacherUserID,
    };

    final url =
        Uri.parse('$baseUrl/api/add-notice'); // Replace with your API URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        print("Notice added successfully!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notice posted successfully!')),
        );
        Navigator.pop(context);
      } else {
        // Error
        print("Failed to post notice: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post notice: ${response.body}')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    print(widget.studentprofile[0]);
    setState(() {
      students = widget.studentprofile;
      extractStudentData(students, names, nameUserMap);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
              'Add Notice',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Title', _titleController),
                  const SizedBox(height: 20),
                  _buildDropdownField(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                ],
              ),
            ),
          ),
          _buildPostButton(), // Button stays at the bottom
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration('Select Student'),
      value: selectedStudent,
      onChanged: (value) {
        setState(() {
          selectedStudent = value;
          selectedUserID = nameUserMap[value]; // Get userID from map
        });
      },
      items: names.map((student) {
        return DropdownMenuItem(
          value: student,
          child: Text(student),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: _inputDecoration('Description'),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelStyle: const TextStyle(color: Colors.blue),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(width: 1, color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(width: 1, color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(width: 1, color: Colors.blue),
      ),
    );
  }

  Widget _buildPostButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          if (_titleController.text.isEmpty ||
              _descriptionController.text.isEmpty ||
              selectedStudent == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
          } else {
            _onPost();
          }
        },
        child: Image.asset(
          'assets/postbutton.png',
          height: 80,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
