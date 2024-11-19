import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  String name = '';
  String dob = '';
  String school = '';
  String studentClass = '';
  String subject = '';
  String profile = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-profile/$userID'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? '';
          dob = data['dob'] ?? '';
          school = data['school'] ?? '';
          studentClass = data['class'] ?? '';
          subject = data['subject'] ?? '';
          profile = data['profile_photo'];
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

    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 1.0),
            child: Row(
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
                  'My Profile',
                  style: TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(right: isLargeScreen ? 30 : 10),
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
          toolbarHeight: 70,
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          // Profile header
         SizedBox(
  width: screenWidth,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center, // Center children vertically
    crossAxisAlignment: CrossAxisAlignment.center, // Center children horizontally
    children: [
      Padding(
        padding: EdgeInsets.only(
          top: isLargeScreen ? 60 : 40,
          bottom: 20,
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: isLargeScreen ? 250 : 175,
                height: isLargeScreen ? 250 : 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(profile),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: isLargeScreen ? 36 : 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF48116A),
                ),
              ),
            ),
            const SizedBox(height: 5), // Bottom spacing
          ],
        ),
      ),
    ],
  )
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
            ]),
          )
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
