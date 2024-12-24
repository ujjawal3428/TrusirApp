import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';

class AddNoticePage extends StatefulWidget {
  final String? userID;
  const AddNoticePage({super.key, required this.userID});

  @override
  State<AddNoticePage> createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _onPost() async {
    final prefs = await SharedPreferences.getInstance();
    final teacherUserID = prefs.getString('userID');
    final String currentDate =
        DateTime.now().toIso8601String(); // ISO 8601 format

    final payload = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'posted_on': currentDate,
      'to': widget.userID,
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
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/back_button.png', height: 50)),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
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
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                controller: _titleController,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Title',
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
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
            const SizedBox(height: 20),
            Container(
              height: 168,
              width: double.infinity, // Responsive width
              decoration: BoxDecoration(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                controller: _descriptionController,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 120, horizontal: 20),
                  labelText: 'Description',
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
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
            const SizedBox(height: 20),
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
          _onPost();
        },
        child: Image.asset(
          'assets/postbutton.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
