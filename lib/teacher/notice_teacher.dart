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

  List<String> selectedStudents = [];
  List<String> selectedUserIDs = [];
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
    final String currentDate = DateTime.now().toIso8601String();

    final url = Uri.parse('$baseUrl/api/add-notice');

    try {
      for (var userID in selectedUserIDs) {
        final payload = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'posted_on': currentDate,
          'to': userID,
          'from': teacherUserID,
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          print("Failed to post notice for $userID: ${response.body}");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notices posted successfully!')),
      );
      Navigator.pop(context);
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
                  _buildMultiSelectDropdown(),
                  const SizedBox(height: 20),
                  _buildDescriptionField(),
                ],
              ),
            ),
          ),
          _buildPostButton(),
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

  Widget _buildMultiSelectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Students",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Wrap(
          children: selectedStudents.map((student) {
            return Chip(
              label: Text(student),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  selectedUserIDs.remove(nameUserMap[student]);
                  selectedStudents.remove(student);
                });
              },
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () => _showMultiSelectDialog(),
          child: const Text("Choose Students"),
        ),
      ],
    );
  }

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelected = List.from(selectedStudents);

        return AlertDialog(
          title: const Text("Select Students"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: names.map((student) {
                    return CheckboxListTile(
                      title: Text(student),
                      value: tempSelected.contains(student),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelected.add(student);
                          } else {
                            tempSelected.remove(student);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedStudents = List.from(tempSelected);
                  selectedUserIDs =
                      selectedStudents.map((e) => nameUserMap[e]!).toList();
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
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
              selectedStudents.isEmpty) {
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
