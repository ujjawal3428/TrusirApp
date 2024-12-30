import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text(
                'About Us',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[50],
      body: const Padding(
        padding: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Trusir is a registered and trusted Indian company that offers Home to Home tuition service. We have a clear vision of helping students achieve their academic goals through one-to-one teaching.\n \n We are a small team of educators, parents, and tech experts who are passionate about helping kids learn and grow. Our app is designed to make learning fun and to provide an exciting and engaging experience for kids. We believe that learning should be enjoyable and that kids should be encouraged to explore and play. We hope you enjoy using our app and that it helps your child explore and grow. Thank you for choosing us!',
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
