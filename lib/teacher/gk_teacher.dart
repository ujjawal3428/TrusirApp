import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddGkTeacher extends StatefulWidget {
  const AddGkTeacher({super.key});

  @override
  State<AddGkTeacher> createState() => _AddGkTeacherState();
}

class _AddGkTeacherState extends State<AddGkTeacher> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  XFile? selectedImage;
  String? selectedStudent;
  final List<String> students = ['Student A', 'Student B', 'Student C'];

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, ),
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
                    child: selectedImage != null
                        ? Image.asset(selectedImage!.path)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/camera@3x.png', width: 46, height: 37),
                              const SizedBox(height: 10),
                              const Text('Upload Image', style: TextStyle(fontSize: 14)),
                              const SizedBox(height: 5),
                              const Text('Click Here', style: TextStyle(fontSize: 10)),
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
                style: TextStyle(fontSize: 14, color: Colors.red, fontFamily: 'Poppins'),
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
          items: students.map((String student) {
            return DropdownMenuItem<String>(
              value: student,
              child: Text(student),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedStudent = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
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
            borderSide: const BorderSide(width: 0.5, color: Color.fromARGB(255, 237, 234, 234)),
          ),
        ),
      ),
    );
  }

  Widget _buildPostButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {},
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  pickImage(ImageSource.camera);
                }),
                const SizedBox(height: 16),
                _buildDialogButton('Upload File', Colors.orange.shade100, () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
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
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(22)),
      child: TextButton(
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins')),
      ),
    );
  }

