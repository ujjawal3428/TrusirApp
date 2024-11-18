import 'package:flutter/material.dart';

class AddGK extends StatelessWidget {
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
                SizedBox(width: 10),
                Text(
                  'Add General Knowledge',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),

            // Title Input Field with Background
            Stack(
              children: [
                Image.asset(
                  'titlebox.png', // Background image for text field
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Description Input Field with Background
            Stack(
              children: [
                Image.asset(
                  'descriptionbox.png', // Background image for description field
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 100,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
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
            SizedBox(height: 20),

            // Attach File Box
            Stack(
              children: [
                Image.asset(
                  'attachfilebox.png', // Background image for attach file box
                  
                  width: 160,
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Attach File',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),

            // File Format Text
           
              Text(
                'Attach PDF, JPEG, PNG',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Poppins',
                ),
              ),
            

            Spacer(),
             Center(
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
SizedBox(height: 20),

            // Post Button
            Center(
              child: GestureDetector(
                onTap: _onpost,
                child: Image.asset(
                  'postbutton.png', // Image for Post button
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onpost() {
    print("Post button pressed");
    // Implement the post action here
  }
}
