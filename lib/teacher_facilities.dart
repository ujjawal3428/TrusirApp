import 'package:flutter/material.dart';
import 'package:trusir/bottom_navigation_bar.dart';
import 'package:trusir/teacher_profile.dart';
import 'package:trusir/notice.dart';
import 'package:trusir/setting.dart';
import 'package:trusir/teacher_pf_page.dart';

class TeacherFacilities extends StatefulWidget {
  const TeacherFacilities({super.key});

  @override
  State<TeacherFacilities> createState() => _TeacherFacilitiesState();
}

class _TeacherFacilitiesState extends State<TeacherFacilities> {
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Teacher Facilities',
            style: TextStyle(
              color: Color(0xFF48116A),
              fontSize: 24,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Image.asset(
                'assets/logout@3x.png',
                width: 103,
                height: 24,
              ),
            ),
          ],
          toolbarHeight: 70,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
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
                            color: const Color(0xFFC22054).withOpacity(0.2),
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
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      'Motihari, Bihar',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                        fontSize: 16,
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
                                        fontSize: 11,
                                        fontFamily: 'Poppins',
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
                              width: 92,
                              height: 92,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
                            crossAxisSpacing: 17,
                            mainAxisSpacing: 10,
                            childAspectRatio: 116 / 140,
                            children: [
                              buildTile(context, const Color(0xFFB3E5FC),
                                  'assets/myprofile.png', 'My Profile', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Teacherpfpage(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFF59D80),
                                  'assets/noticesp@3x.png', 'Notice', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NoticeScreen(),
                                  ),
                                );
                              }),
                              buildTile(context, const Color(0xFFF8BBD0),
                                  'assets/attendance.png', 'Attendance', () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const AttendanceScreen(),
                                //   ),
                                // );
                              }),
                              buildTile(context, const Color(0xFFFFCDD2),
                                  'assets/pen@3x.png', 'Write to us', () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const FeePaymentScreen(),
                                //   ),
                                // );
                              }),
                              buildTile(context, const Color(0xFF00E533),
                                  'assets/setting.png', 'Setting', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Text(
                          'Student Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 129,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        children: [
                          buildHorizontalTile(context, const Color(0xFFB3E5FC),
                              'assets/sir.png', 'Rakesh Tripathi', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NoticeScreen(),
                              ),
                            );
                          }),
                          const SizedBox(width: 17),
                          buildHorizontalTile(context, const Color(0xFFF59D80),
                              'assets/sir.png', 'Rakesh Tripathi', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TeacherProfileScreen(),
                              ),
                            );
                          }),
                          const SizedBox(width: 17),
                          buildHorizontalTile(context, const Color(0xFFF8BBD0),
                              'assets/sir.png', 'Rakesh Tripathi', () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const (),
                            //   ),
                            // );
                          }),
                          const SizedBox(width: 17),
                          buildHorizontalTile(context, const Color(0xFFFFCDD2),
                              'assets/sir.png', 'Rakesh Tripathi', () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const WritetoUs(),
                            //   ),
                            // );
                          }),
                          const SizedBox(width: 17),
                          buildHorizontalTile(context, const Color(0xFF00E533),
                              'assets/sir.png', 'Rakesh Tripathi', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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

  Widget buildTile(BuildContext context, Color color, String imagePath,
      String title, VoidCallback onTap) {
    final imageSize = imageSizes[imagePath] ?? {'width': 40.0, 'height': 40.0};
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.85 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: FractionallySizedBox(
        widthFactor: scaleFactor,
        child: Container(
          height: 140,
          width: 116,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: color,
              width: 1,
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
                    fontFamily: 'Poppins',
                    fontSize: 12 * scaleFactor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHorizontalTile(BuildContext context, Color color,
      String imagePath, String title, VoidCallback onTap) {
    final imageSize = imageSizes[imagePath] ?? {'width': 40.0, 'height': 40.0};

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 94,
        height: 129,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: imageSize['width']!,
              height: imageSize['height']!,
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
                style: const TextStyle(
                  fontSize: 12,
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