import 'package:flutter/material.dart';
import 'package:trusir/student/student_registration.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomepage extends StatelessWidget {
  final bool enablephone;
  const StudentHomepage({super.key, required this.enablephone});

  Future<void> openDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      print("Error launching WhatsApp: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 20.0,
              bottom: 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const SizedBox(height: 20),
                const Text(
                  'trusir',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 5),
               

                // Welcome text
                const Text(
                  'Welcome To Trusir',
                  style: TextStyle(
                    fontSize: 34,
                    height: 1.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Divider(color: Colors.black, thickness: 2, endIndent: 10),
                const SizedBox(height: 10),
                const Text(
                  'Trusir is a registered and trusted Indian company that offers Home to Home tuition service. We have a clear vision of helping students achieve their academic goals through one-to-one teaching.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.3,
                    fontFamily: 'Poppins',
                    color: Color(0xFF001241),
                  ),
                ),
                const SizedBox(height: 24),

                // Services ListView (Horizontal)
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _serviceCard(
                        title: 'Trusted Teachers',
                        imagePath: 'assets/girlimage@4x.png',
                        backgroundColor:
                            const Color.fromARGB(214, 193, 226, 252),
                      ),
                      _serviceCard(
                        title: 'Home to Home Tuition',
                        imagePath: 'assets/girlimage@4x.png',
                        backgroundColor:
                            const Color.fromARGB(210, 251, 197, 216),
                      ),
                      _serviceCard(
                        title: 'Qualified And Trusted Teachers',
                        imagePath: 'assets/girlimage@4x.png',
                        backgroundColor:
                            const Color.fromARGB(229, 252, 211, 215),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Our Services title
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00081D),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Offline Payment Button with descriptive text
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Define your onTap action here
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/g2@4x.png',
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                ),

                // Additional text sections
                const Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 30.0,
                          left: 6,
                          right: 6,
                        ),
                        child: Text(
                          'Get the Best Tutor for your child',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: Color(0xFF00081D),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          left: 6,
                          right: 6,
                        ),
                        child: Text(
                          'Get the best learning support for your child',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFBCBCBC),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                          left: 6,
                          right: 6,
                        ),
                        child: Text(
                          'For all your learning support needs such as homework, test, school project and examinations; we are here to give you the best support.',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10,
                          left: 6,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'The best tutors are here',
                            style: TextStyle(
                              fontSize: 20,
                              height: 1,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFBCBCBC),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 10.0,
                          left: 6,
                          right: 6,
                        ),
                        child: Text(
                          'Our tutors are seasoned professionals, screened and given relevant training on a monthly basis to deliver the excellent results you desire.',
                          style: TextStyle(
                            fontSize: 20,
                            height: 1,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Row of two images
                Column(
                  children: [
                    Image.asset(
                      'assets/t1@3x.png',
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/t2.jpg',
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Explore our offerings text
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore our offerings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B395F),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Subjects Buttons
                Wrap(
                  spacing: 5,
                  runSpacing: 6,
                  children: [
                    'Nursery',
                    'LKG',
                    'UKG',
                    'Class 1',
                    'Class 2',
                    'Class 3',
                    'Class 4',
                    'Class 5',
                    'Class 6',
                    'Class 7',
                    'Class 8',
                    'Class 9',
                    'Class 10',
                  ].map((subject) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Explore Subjects title
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Explore Subjects',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2B395F),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 5,
                  runSpacing: 6,
                  children: [
                    'Hindi',
                    'English',
                    'Maths',
                    'Science: Physics, Chemistry, Biology',
                    'Social Science: History, Geography, Political Science, Economics'
                  ].map((subject) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        subject,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Fixed Registration Button at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: -10,
            child: _buildRegistrationButton(context),
          ),
          Positioned(
            right: 13,
            top: MediaQuery.of(context).size.height * 0.5 - -130,
            child: SizedBox(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'whatsappButton', // Add unique tag
                backgroundColor: Colors.transparent,
                onPressed: () {
                  _launchWhatsApp('919797472922', 'Hi');
                },
                child: Image.asset(
                  'assets/whatsapp@3x.png',
                ),
              ),
            ),
          ),
          Positioned(
            right: 13,
            top: MediaQuery.of(context).size.height * 0.58 - -130,
            child: SizedBox(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'callButton', // Add unique tag
                backgroundColor: Colors.transparent,
                onPressed: () {
                  openDialer('9797472922');
                },
                child: Image.asset(
                  'assets/call.png',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentRegistrationPage(),
            ),
          );
        },
        child: Image.asset(
          'assets/registeration.png',
          width: 330,
          height: 70,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _serviceCard({
    required String title,
    required String imagePath,
    required Color backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 160,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 100, fit: BoxFit.cover),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ContactInfoRow extends StatelessWidget {
  final String imagePath;
  final String info;

  const ContactInfoRow({
    super.key,
    required this.imagePath,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          imagePath,
          height: 60,
          width: 60,
        ),
        const SizedBox(width: 10),
        Text(
          info,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
