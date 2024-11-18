import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => _goBack(context),
          child: Container(
             margin: const EdgeInsets.only(left: 20.0,top: 20.0),
                         child: Image.asset(
              "back_button.png", 
              width: 100,
              height: 100,// Ensure this path is correct
              
              
            ),
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20), // Add space if needed
              Text(
                "About Us",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 20),
              
              Text(
                'Trusir is a registered and trusted Indian company that offers Home to Home tuition service. We have a clear vision of helping students achieve their academic goals through one-to-one teaching.\n \n We are a small team of educators, parents, and tech experts who are passionate about helping kids learn and grow. Our app is designed to make learning fun and to provide an exciting and engaging experience for kids. We believe that learning should be enjoyable and that kids should be encouraged to explore and play. We hope you enjoy using our app and that it helps your child explore and grow. Thank you for choosing us!',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
              SizedBox(height: 20),

              // Main content with images and payment options
            ],
          ),
        ),
      ),
    );
  }

  // Go back function
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }
}
