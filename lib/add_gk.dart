import 'package:flutter/material.dart';

class AddGK extends StatelessWidget {
  const AddGK({super.key});

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
                  'Add GK',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            // Title Input Field with Background
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Image.asset(
                  'assets/titlebox.png', // Ensure this path is correct
                  fit: BoxFit.fill,
                  width: 300,
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
              alignment: Alignment.topLeft,
              children: [
                Image.asset(
                  'assets/descriptionbox.png', 
                  fit: BoxFit.contain,
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
            const SizedBox(height: 20),

            // Attach File Box
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Image.asset(
                    'assets/attachfilebox.png', 
                    width: 160,
                    height: 50,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
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
            const SizedBox(height: 5),

            // File Format Text
           const Padding(
                padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Attach PDF, JPEG, PNG',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const Spacer(),

            // Disclaimer Text
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
            const SizedBox(height: 20),

            // Post Button
            Center(
              child: GestureDetector(
                onTap: _onPost,
                child: Image.asset(
                  'assets/postbutton.png', // Ensure this path is correct
                  fit: BoxFit.contain,
                  width: 200,
                  height: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPost() {
    debugPrint("Post button pressed");
    // Implement your post action logic here
  }
}
