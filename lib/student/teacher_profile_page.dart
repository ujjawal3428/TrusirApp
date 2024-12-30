import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/teacher_edit_profile.dart';

class TeacherProfilePage extends StatefulWidget {
  final String userID;
  const TeacherProfilePage({super.key, required this.userID});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<TeacherProfilePage> {
  String name = '';
  String age = '';
  String dob = '';
  String gender = '';
  String address = '';
  String graduation = '';
  String experience = '';
  String subjects = '';
  String language = '';
  String phoneNumber = '';
  String profilePhoto = '';

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  int calculateAge(String dob) {
    // Parse the DOB string to a DateTime object
    DateTime dateOfBirth = DateTime.parse(dob);
    DateTime today = DateTime.now();

    // Calculate the age
    int age = today.year - dateOfBirth.year;

    // Check if the birthday has not yet occurred this year
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/get-user/${widget.userID}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? 'N/A';
          dob = data['DOB'];
          age = calculateAge(dob).toString();
          gender = data['gender'] ?? 'N/A';
          address = data['address'] ?? 'N/A';
          graduation = data['qualification'] ?? 'N/A';
          experience = data['experience'] ?? 'N/A';
          subjects = data['subject'] ?? 'N/A';
          language = data['medium'] ?? 'N/A';
          phoneNumber = data['phone'] ?? 'N/A';
          profilePhoto = data['profile'] ??
              'https://via.placeholder.com/150'; // Fallback image URL
        });
        print('Data fetched Successfully');
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Teacher Profile',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherEditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF48116A),
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
        child: Column(
          children: [
            SizedBox(
              width: 428,
              height: 180,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(profilePhoto),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF48116A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            buildInfoRow(
              'assets/male@2x.png',
              'Age & Gender',
              '$age, $gender',
              imageBackgroundColor: Colors.blue.shade100,
              textBackgroundColor: Colors.blue.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/location@2x.png',
              'Address',
              address,
              imageBackgroundColor: Colors.green.shade100,
              textBackgroundColor: Colors.green.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/degree@2x.png',
              'Graduation',
              graduation,
              imageBackgroundColor: Colors.yellow.shade100,
              textBackgroundColor: Colors.yellow.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/medal@2x.png',
              'Experience',
              experience,
              imageBackgroundColor: Colors.red.shade100,
              textBackgroundColor: Colors.red.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/pensp@3x.png',
              'Subjects',
              subjects,
              imageBackgroundColor: Colors.purple.shade100,
              textBackgroundColor: Colors.purple.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/ab@2x.png',
              'Language',
              language,
              imageBackgroundColor: Colors.orange.shade100,
              textBackgroundColor: Colors.orange.shade50,
            ),
            const SizedBox(height: 10),
            buildInfoRow(
              'assets/phone@2x.png',
              'Phone Number',
              '+91-$phoneNumber',
              imageBackgroundColor: Colors.teal.shade100,
              textBackgroundColor: Colors.teal.shade50,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(
    String iconPath,
    String title,
    String value, {
    Color imageBackgroundColor = Colors.pink,
    Color textBackgroundColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 17.0, right: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 55,
            height: 63,
            decoration: BoxDecoration(
              color: imageBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              height: 63,
              width: 306,
              decoration: BoxDecoration(
                color: textBackgroundColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  top: 10,
                  bottom: 10,
                  right: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : 'Loading...',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
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
