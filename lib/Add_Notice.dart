import 'package:flutter/material.dart';

class AddNoticePage extends StatelessWidget {
  const AddNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Back Button and Title
            Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/back_button.png', // Replace with your back button image path
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10), // Space between back button and title

                // Title Text
                const Text(
                  'Add Notice',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C), // Purple color for title
                    fontFamily: 'Poppins', // Ensure Poppins font is added to pubspec.yaml
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Title Input Field with Background
            Stack(
              children: [
                Image.asset(
                  'titlebox.png', // Background image for text field
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description Input Field with Background
            Stack(
              children: [
                Image.asset(
                  'descriptionbox.png', // Background image for description field
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 100,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Description',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 400),

            // Visibility Notice
            const Center(
              child: Text(
                'This post will be only visible to the\nstudent you teach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Spacer(),

            // Post Button
            Center(
              child: GestureDetector(
                onTap: _onpost,
                child: Image.asset(
                  'postbutton.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
void _onpost() {
    print("post button pressed");
    // Implement the Enquire action here
  }
