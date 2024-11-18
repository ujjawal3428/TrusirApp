import 'package:flutter/material.dart';
import 'package:trusir/TestSeries.dart';
import 'package:trusir/bottomnavigationbar.dart';
import 'package:trusir/feepayment.dart';
import 'package:trusir/myprofile.dart';
import 'package:trusir/notice.dart';
import 'package:trusir/parentsdoubt.dart';
import 'package:trusir/progressreport.dart';
import 'package:trusir/setting.dart';
import 'package:trusir/studentdoubt.dart';
import 'package:trusir/teacherprofile.dart';

class Studentfacilities extends StatefulWidget {
  const Studentfacilities({super.key});

  @override
  State<Studentfacilities> createState() => _StudentfacilitiesState();
}

class _StudentfacilitiesState extends State<Studentfacilities> {
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                       Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Student Facilities',
                            style: TextStyle(
                              color: Color(0xFF48116A),
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 116,
                      width: constraints.maxWidth > 388 ? 388 : constraints.maxWidth - 40,
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
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 25.0, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Asmit Kumar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700
                                    ),
                                  ),
                                  Padding(
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
                                  Padding(
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
                            child: Image.asset(
                              'assets/diksha@4x.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: tileWidth / tileHeight,
                            children: [
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/myprofile.png', 'My Profile', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MyProfileScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFF59D80), 'assets/teacherprofile.png', 'Teacher Profile', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TeacherProfileScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFF8BBD0), 'assets/attendance.png', 'Attendance', tileWidth, tileHeight, () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const AttendanceScreen(),
                                //   ),
                                // );
                              }),
                              buildTile(context, const Color(0xFFFFCDD2), 'assets/money.png', 'Fee Payment', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FeePaymentScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFF00E533), 'assets/pencil and ruller.png', 'Test Series', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TestSeriesScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/medal.png', 'Progress Report', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProgressReportScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/qna.png', 'Student Doubt', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StudentDoubtScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/sir.png', 'Parents Doubt', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ParentsDoubtScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/knowledge.png', 'Extra Knowledge', tileWidth, tileHeight, () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const ExtraKnowledgeScreen(),
                                //   ),
                                // );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/notice.png', 'Notice', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NoticeScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/setting.png', 'Settings', tileWidth, tileHeight, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFB3E5FC), 'assets/video knowledge.png', 'Video Knowledge', tileWidth, tileHeight, () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const VideoKnowledgeScreen(),
                                //   ),
                                // );
                              }),
                            ],
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildTile(BuildContext context, Color color, String imagePath, String title, double tileWidth, double tileHeight, VoidCallback onTap) {
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