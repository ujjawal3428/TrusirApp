import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';

class Teacherpfpage extends StatefulWidget {
  const Teacherpfpage({super.key});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<Teacherpfpage> {
  String age = '';
  String gender = '';
  String address = '';
  String graduation = '';
  String experience = '';
  String subjects = '';
  String language = '';
  String phoneNumber = '';

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
          age = data['age'] ?? '';
          gender = data['gender'] ?? '';
          address = data['address'] ?? '';
          graduation = data['graduation'] ?? '';
          experience = data['experience'] ?? '';
          subjects = data['subjects'] ?? '';
          language = data['language'] ?? '';
          phoneNumber = data['phoneNumber'] ?? '';
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 428,
                height: 389,
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 10,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          'assets/dikshaback@2x.png',
                          width: 58,
                          height: 58,
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 51,
                      left: 100,
                      child: Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF48116A),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Container(
                            width: 175,
                            height: 175,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/asmitcircle.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Asmit Kumar',
                            style: TextStyle(
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
              // Combining age and gender in one row
              buildInfoRow('assets/person.png', 'Age & Gender', '$age, $gender'),
              const SizedBox(height: 10),
              // Adding new rows for address, graduation, experience, subjects, language, and phone number
              buildInfoRow('assets/home.png', 'Address', address),
              const SizedBox(height: 10),
              buildInfoRow('assets/graduation@3x.png', 'Graduation', graduation),
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
                padding:
                    const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
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
