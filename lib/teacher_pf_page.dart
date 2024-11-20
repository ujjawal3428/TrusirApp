import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:trusir/api.dart';

class Teacherpfpage extends StatefulWidget {
  const Teacherpfpage({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<Teacherpfpage> {
  String name = '';
  String age = '';
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

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher-profile/$userID'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['name'] ?? 'N/A';
          age = data['age']?.toString() ?? 'N/A';
          gender = data['gender'] ?? 'N/A';
          address = data['address'] ?? 'N/A';
          graduation = data['graduation'] ?? 'N/A';
          experience = data['experience'] ?? 'N/A';
          subjects = data['subjects'] != null
              ? (data['subjects'] as List<dynamic>).join(', ')
              : 'N/A';
          language = data['language'] != null
              ? (data['language'] as List<dynamic>).join(', ')
              : 'N/A';
          phoneNumber = data['phoneNumber'] ?? 'N/A';
          profilePhoto = data['profile_photo'] ??
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[50],
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
                phoneNumber,
                imageBackgroundColor: Colors.teal.shade100,
                textBackgroundColor: Colors.teal.shade50,
              ),
              const SizedBox(height: 10),
            ],
          ),
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
