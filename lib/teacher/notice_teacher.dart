import 'package:flutter/material.dart';

class AddNoticeTeacher extends StatefulWidget {
  const AddNoticeTeacher({super.key});

  @override
  State<AddNoticeTeacher> createState() => _AddNoticeTeacherState();
}

class _AddNoticeTeacherState extends State<AddNoticeTeacher> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedStudent;
  final List<String> students = ['Student A', 'Student B', 'Student C', 'Student D'];

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
        });
      },
      items: students.map((student) {
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
          if (_titleController.text.isEmpty || _descriptionController.text.isEmpty || selectedStudent == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
          } else {
            // Handle post action
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
