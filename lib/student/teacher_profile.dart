import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:trusir/common/api.dart'; // Assuming you've added your base URL here

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  TeacherProfileScreenState createState() => TeacherProfileScreenState();
}

Future<void> openDialer(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

class TeacherProfileScreenState extends State<TeacherProfileScreen> {
  List<Teacher> teachers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    final response = await http.get(Uri.parse('$baseUrl/teacher/$userID'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        teachers = data.map((json) => Teacher.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load teachers');
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(children: [
                // Display the teacher profiles in a grid view
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 8),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = teachers[index];

                      return GestureDetector(
                        onTap: () => openDialer(teacher.mobile),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Container(
                              width: 180,
                              height: 251,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Image from network
                                  Container(
                                    width: 98,
                                    height: 101,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(teacher.image),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Name Text
                                  Text(
                                    teacher.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Phone Number
                                  Text(
                                    teacher.mobile,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    teacher.subject,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tag
                            Positioned(
                              top: -10,
                              left: -30,
                              child: Transform.rotate(
                                angle: -0.785398,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 0, left: 0, right: 0),
                                  child: Container(
                                    width: 150,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      teacher.tClass,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ])));
  }
}

class Teacher {
  final String name;
  final String subject;
  final String tClass;
  final String mobile;
  final String image;

  Teacher({
    required this.name,
    required this.subject,
    required this.tClass,
    required this.mobile,
    required this.image,
  });

  // Factory method to create a Teacher object from JSON
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      name: json['name'],
      tClass: json['class'] ?? 'N/A',
      subject: json['subject'] ?? 'N/A',
      mobile: json['phone'],
      image: json['profile'],
    );
  }
}
