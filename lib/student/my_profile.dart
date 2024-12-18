import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/student/editprofilescreen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  String? name;
  String? dob;
  String? school;
  String? studentClass;
  String? subject;
  String? profile;
  String? userID;
  String? address;
  String? phone;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      name = prefs.getString('name');
      dob = prefs.getString('DOB');
      school = prefs.getString('school');
      studentClass = prefs.getString('class');
      subject = prefs.getString('subject');
      profile = prefs.getString('profile');
      address = prefs.getString('address');
      phone = prefs.getString('phone_number');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    const rowColors = [
      Color.fromARGB(255, 255, 199, 221),
      Color.fromARGB(255, 199, 236, 255),
      Color.fromARGB(255, 255, 185, 185),
      Color.fromARGB(255, 191, 184, 255),
    ];

    return Scaffold(
        backgroundColor: Colors.grey[50],
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
                  'My Profile',
                  style: TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: isLargeScreen ? 30 : 10),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: isLargeScreen ? 16 : 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF48116A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Profile header
            SizedBox(
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: isLargeScreen ? 250 : 130,
                              height: isLargeScreen ? 250 : 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(profile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Center(
                            child: Text(
                              name!,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 22 : 20,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF48116A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5), // Bottom spacing
                        ],
                      ),
                    ),
                  ],
                )),
            // Info rows
            const SizedBox(height: 18),
            buildInfoRow(
              'assets/pastry@3x.png',
              'Date of Birth',
              dob!,
              isLargeScreen,
              rowColors[0],
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/house@3x.png',
              'School',
              school!,
              isLargeScreen,
              rowColors[1],
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/graduation@3x.png',
              'Class',
              studentClass!,
              isLargeScreen,
              rowColors[2],
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/pensp@3x.png',
              'Subjects',
              subject!,
              isLargeScreen,
              rowColors[3],
            ),
          ]),
        ));
  }

  Widget buildInfoRow(
    String iconPath,
    String title,
    String value,
    bool isLargeScreen,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: isLargeScreen ? 100 : 65,
            height: isLargeScreen ? 100 : 65,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text container
          Flexible(
            child: Container(
              height: isLargeScreen ? 100 : 65,
              width: isLargeScreen ? 400 : 306,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isLargeScreen ? 22 : 16,
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
