import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/login_page.dart';
import 'package:trusir/test_series.dart';
import 'package:trusir/bottom_navigation_bar.dart';
import 'package:trusir/fee_payment.dart';
import 'package:trusir/my_profile.dart';
import 'package:trusir/notice.dart';
import 'package:trusir/parents_doubt.dart';
import 'package:trusir/progress_report.dart';
import 'package:trusir/setting.dart';
import 'package:trusir/student_doubt.dart';
import 'package:trusir/teacher_myprofile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api.dart';

class Studentfacilities extends StatefulWidget {
  const Studentfacilities({super.key});

  @override
  State<Studentfacilities> createState() => _StudentfacilitiesState();
}

class _StudentfacilitiesState extends State<Studentfacilities> {
  int _selectedIndex = 0;
  String name = '';
  String profile = '';
  final Map<String, Map<String, double>> imageSizes = {
    'assets/myprofile.png': {'width': 50, 'height': 50},
    'assets/teacherprofile.png': {'width': 50, 'height': 49},
    'assets/attendance.png': {'width': 44, 'height': 46},
    'assets/money.png': {'width': 51, 'height': 32},
    'assets/pencil and ruller.png': {'width': 31, 'height': 44},
    'assets/medal.png': {'width': 33, 'height': 50},
    'assets/qna.png': {'width': 53, 'height': 53},
    'assets/sir.png': {'width': 46, 'height': 46},
    'assets/knowledge.png': {'width': 44, 'height': 46},
    'assets/notice.png': {'width': 43, 'height': 43},
    'assets/setting.png': {'width': 52, 'height': 52},
    'assets/video knowledge.png': {'width': 85, 'height': 74},
  };

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TrusirLoginPage()),
      (route) => false,
    );
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
          profile = data['profile_photo'] ?? 'https://via.placeholder.com/150';
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

    double tileWidth = 116;
    double tileHeight = 140;
    if (screenWidth > 600) {
      tileWidth *= 1.2;
      tileHeight *= 1.2;
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              'Student Facilities',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          actions: [
            InkWell(
              onTap: (){logout(context);}
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20.0),
                child: Image.asset(
                  'assets/logout@3x.png',
                  width: 103,
                  height: 24,
                ),
              ),
            ),
          ],
          toolbarHeight: 70,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20, bottom: 20, top: 18),
              child: Column(children: [
                Container(
                  height: 116,
                  width: constraints.maxWidth > 388
                      ? 388
                      : constraints.maxWidth - 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFC22054),
                        Color(0xFF48116A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC22054).withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(
                                  'Motihari, Bihar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Text(
                                  '980-456-7890',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Image.network(
                          profile,
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
                      crossAxisSpacing: 17,
                      mainAxisSpacing: 10,
                      childAspectRatio: tileWidth / tileHeight,
                      children: [
                        buildTile(
                            context,
                            const Color(0xFFB3E5FC),
                            'assets/myprofile.png',
                            'My Profile',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyProfileScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0xFFF59D80),
                            'assets/teacherprofile.png',
                            'Teacher Profile',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const TeacherProfileScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0xFFF8BBD0),
                            'assets/attendance.png',
                            'Attendance',
                            tileWidth,
                            tileHeight, () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const AttendanceScreen(),
                          //   ),
                          // );
                        }),
                        buildTile(
                            context,
                            const Color(0xFFFFCDD2),
                            'assets/money.png',
                            'Fee Payment',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeePaymentScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 242, 255, 186),
                            'assets/pencil and ruller.png',
                            'Test Series',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestSeriesScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0xFFB3E5FC),
                            'assets/medal.png',
                            'Progress Report',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProgressReportScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 255, 198, 247),
                            'assets/qna.png',
                            'Student Doubt',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StudentDoubtScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 198, 255, 185),
                            'assets/sir.png',
                            'Parents Doubt',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParentsDoubtScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 248, 180, 180),
                            'assets/knowledge.png',
                            'Extra Knowledge',
                            tileWidth,
                            tileHeight, () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const ExtraKnowledgeScreen(),
                          //   ),
                          // );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 187, 231, 251),
                            'assets/notice.png',
                            'Notice',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NoticeScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 253, 194, 246),
                            'assets/setting.png',
                            'Settings',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color.fromARGB(255, 246, 238, 189),
                            'assets/video knowledge.png',
                            'Video Knowledge',
                            tileWidth,
                            tileHeight, () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const VideoKnowledgeScreen(),
                          //   ),
                          // );
                        }),
                      ],
                    );
                  }),
                ),
              ]),
            ));
          },
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildTile(BuildContext context, Color color, String imagePath,
      String title, double tileWidth, double tileHeight, VoidCallback onTap) {
    final imageSize = imageSizes[imagePath] ?? {'width': 40.0, 'height': 40.0};
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.7 : 1.0;

    // Create a lighter version of the background color for the border
    final borderColor = HSLColor.fromColor(color).withLightness(0.9).toColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: tileWidth,
        height: tileHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: imageSize['width']! * scaleFactor,
              height: imageSize['height']! * scaleFactor,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * scaleFactor,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
