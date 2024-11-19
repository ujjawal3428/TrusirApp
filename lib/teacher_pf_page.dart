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
                    fontSize: 24,
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
                height: 389,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            width: 175,
                            height: 175,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(profilePhoto),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 30,
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
              const SizedBox(height: 10),
              buildInfoRow(
                  'assets/person.png', 'Age & Gender', '$age, $gender'),
              const SizedBox(height: 10),
              buildInfoRow('assets/home.png', 'Address', address),
              const SizedBox(height: 10),
              buildInfoRow(
                  'assets/graduation@3x.png', 'Graduation', graduation),
              const SizedBox(height: 10),
              buildInfoRow('assets/experience.png', 'Experience', experience),
              const SizedBox(height: 10),
              buildInfoRow('assets/pensp@3x.png', 'Subjects', subjects),
              const SizedBox(height: 10),
              buildInfoRow('assets/language.png', 'Language', language),
              const SizedBox(height: 10),
              buildInfoRow('assets/phone.png', 'Phone Number', phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoRow(String iconPath, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
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
          Flexible(
            child: Container(
              height: 75,
              width: 306,
              decoration: BoxDecoration(
                color: const Color.fromARGB(65, 255, 46, 46),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : 'Loading...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
