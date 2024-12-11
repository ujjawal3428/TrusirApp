import 'package:flutter/material.dart';
import 'package:trusir/common/contactus.dart';
import 'package:trusir/student/editprofilescreen.dart';
import 'package:trusir/common/parents_doubts.dart';
import 'package:trusir/common/terms_and_conditions.dart';
import 'package:trusir/common/about_us.dart';
import 'package:trusir/student/your_doubt.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              Text(
                'Setting',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 22,
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
        child: Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 37,
                        height: 37,
                        child: Image.asset(
                          'assets/editprofile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                  onPressed: () {},
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/pensp@3x.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const YourDoubtPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'Your Doubts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                  onPressed: () {},
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          'assets/men.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: (){
                        
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ParentsDoubtsPage(),
                                    ),
                                  );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'Parents Doubts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                 onPressed: (){},
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          'assets/aboutus.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AboutUsPage(),
                                    ),
                                  );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'About Us',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                  onPressed: () {
                                    
                                  },
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          'assets/phone@2x.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Contactus(),
                                    ),
                                  );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'Contact Us',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                  onPressed: () {
                                    
                                  },
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
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          'assets/tnc.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: (){
                         Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsAndConditionsPage(),
                                      ),
                                    );
                      },
                      child: Container(
                        height: 55,
                        width: 306,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
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
                                const Text(
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.arrow_forward_ios_rounded),
                                  color: const Color(0xFF48116A),
                                  onPressed: () {
                                   
                                  },
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
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
