import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/contactus.dart';
import 'package:trusir/student/editprofilescreen.dart';
import 'package:trusir/common/parents_doubts.dart';
import 'package:trusir/common/terms_and_conditions.dart';
import 'package:trusir/common/about_us.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/student/your_doubt.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  String userID = '';
  bool isWeb = false;

  Future<void> fetchuserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
  }

  @override
  Widget build(BuildContext context) {
    isWeb = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text(
                'Setting',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          child: Column(
            children: [
              SizedBox(height: isWeb ? null : 30),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/editprofile.png',
                  Colors.blue.shade200,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      ),
                  'Edit Profile'),
              SizedBox(height: isWeb ? 10 : 20),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/pensp@3x.png',
                  Colors.indigo.shade200,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const YourDoubtPage(),
                        ),
                      ),
                  'Your Doubts'),
              SizedBox(height: isWeb ? 10 : 20),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/men.png',
                  Colors.blue.shade200,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParentsDoubtsPage(),
                        ),
                      ),
                  'Parents Doubts'),
              SizedBox(height: isWeb ? 10 : 20),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/aboutus.png',
                  Colors.purple.shade100,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutUsPage(),
                        ),
                      ),
                  'About Us'),
              SizedBox(height: isWeb ? 10 : 20),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/phone@2x.png',
                  Colors.indigo.shade200,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Contactus(),
                        ),
                      ),
                  'Contact Us'),
              SizedBox(height: isWeb ? 10 : 20),
              _settingscard(
                  context,
                  isWeb ? 80 : 50,
                  isWeb ? 40 : 30,
                  isWeb ? 70 : 55,
                  isWeb ? 450 : 306,
                  'assets/tnc.png',
                  Colors.pink.shade200,
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsAndConditionsPage(),
                        ),
                      ),
                  'Terms & Conditions'),
              SizedBox(height: isWeb ? 10 : 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingscard(
      BuildContext context,
      double containerSize,
      double imageSize,
      double newContainerheight,
      double newcontainerwidth,
      String image,
      Color color,
      VoidCallback onTap,
      String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SizedBox(
                width: imageSize,
                height: imageSize,
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: isWeb ? 50 : 10),
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: newContainerheight,
                width: newcontainerwidth,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, top: 10, bottom: 10, right: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 15),
                          child: Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
