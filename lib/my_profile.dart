import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  String dob = '';
  String school = '';
  String studentClass = '';
  String subject = '';
  String profile_photo = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-profile/testid'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dob = data['dob'] ?? '';
          school = data['school'] ?? '';
          studentClass = data['class'] ?? '';
          subject = data['subject'] ?? '';
          profile_photo = data['profile_photo'];
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
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

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              SizedBox(
                width: screenWidth,
                child: Column(
                  children: [
                    // Top row with back button, title and edit button
                    Padding(
                      padding: EdgeInsets.only(
                        top: isLargeScreen ? 60 : 40,
                        bottom: 20, // Space between top row and profile section
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Back Button
                          Padding(
                            padding:
                                EdgeInsets.only(left: isLargeScreen ? 30 : 10),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/dikshaback@2x.png',
                                width: isLargeScreen ? 70 : 58,
                                height: isLargeScreen ? 70 : 58,
                              ),
                            ),
                          ),
                          // Profile Title
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              'My Profile',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 28 : 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF48116A),
                              ),
                            ),
                          ),
                          // Edit Profile Button
                          const Spacer(),
                          Padding(
                            padding:
                                EdgeInsets.only(right: isLargeScreen ? 30 : 10),
                            child: GestureDetector(
                              onTap: () {
                                print("Edit Profile tapped!");
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
                    // Profile picture and name section
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 20.0), // Consistent 20px padding
                      child: Column(
                        children: [
                          Container(
                            width: isLargeScreen ? 250 : 175,
                            height: isLargeScreen ? 250 : 175,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(profile_photo),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Asmit Kumar',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 36 : 30,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF48116A),
                            ),
                          ),
                          const SizedBox(height: 20), // Bottom spacing
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Info rows
              const SizedBox(height: 10),
              buildInfoRow(
                'assets/pastry@3x.png',
                'Date of Birth',
                dob,
                isLargeScreen,
                rowColors[0],
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                'assets/house@3x.png',
                'School',
                school,
                isLargeScreen,
                rowColors[1],
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                'assets/graduation@3x.png',
                'Class',
                studentClass,
                isLargeScreen,
                rowColors[2],
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                'assets/pensp@3x.png',
                'Subjects',
                subject,
                isLargeScreen,
                rowColors[3],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(
    String iconPath,
    String title,
    String value,
    bool isLargeScreen,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: isLargeScreen ? 100 : 75,
            height: isLargeScreen ? 100 : 75,
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
          const SizedBox(width: 15),
          // Text container
          Flexible(
            child: Container(
              height: isLargeScreen ? 100 : 75,
              width: isLargeScreen ? 400 : 306,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeScreen ? 22 : 18,
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
