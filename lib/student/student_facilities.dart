import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/student/attendance.dart';
import 'package:trusir/student/extra_knowledge.dart';
import 'package:trusir/student/gk_page.dart';
import 'package:trusir/student/profilepopup.dart';
import 'package:trusir/common/test_series.dart';
import 'package:trusir/student/fee_payment.dart';
import 'package:trusir/student/my_profile.dart';
import 'package:trusir/student/notice.dart';
import 'package:trusir/student/parents_doubt.dart';
import 'package:trusir/student/progress_report.dart';
import 'package:trusir/student/setting.dart';
import 'package:trusir/student/student_doubt.dart';
import 'package:trusir/student/teacher_profile.dart';
import 'package:trusir/student/video_knowledge.dart';
import 'package:trusir/common/wanna_logout.dart';

class Studentfacilities extends StatefulWidget {
  const Studentfacilities({super.key});

  @override
  State<Studentfacilities> createState() => _StudentfacilitiesState();
}

class _StudentfacilitiesState extends State<Studentfacilities> {
  String name = '';
  String profile = '';
  String area = '';
  String city = '';
  String phone = '';
  String userID = '';

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
    'assets/video knowledge.png': {'width': 85, 'height': 55},
  };

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID')!;
      name = prefs.getString('name')!;
      profile = prefs.getString('profile')!;
      area = prefs.getString('area')!;
      city = prefs.getString('city')!;
      phone = prefs.getString('phone_number')!;
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(top: 0),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WanaLogout(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 0, right: 20.0),
              child: Image.asset(
                'assets/logout@3x.png',
                width: 103,
                height: 24,
              ),
            ),
          ),
        ],
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20, top: 10, bottom: 10),
              child: Column(children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => const ProfilePopup(),
                      ),
                    );
                  },
                  child: Container(
                    width: constraints.maxWidth > 388
                        ? 388
                        : constraints.maxWidth - 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF48116A), // Darker color for the top
                          Color(0xFFC22054), // Lighter color for the bottom
                        ],
                        begin: Alignment
                            .topCenter, // Start the gradient at the top
                        end: Alignment
                            .bottomCenter, // End the gradient at the bottom
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC22054).withValues(alpha: 0.3),
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
                            padding: const EdgeInsets.only(
                                left: 20.0, top: 12, bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w700),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$area, ',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        city,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    phone,
                                    style: const TextStyle(
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
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white12,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                profile,
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                            const Color(0x80FFF59D),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AttendancePage(
                                userID: userID,
                              ),
                            ),
                          );
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
                            const Color(0x33FF00E5),
                            'assets/pencil and ruller.png',
                            'Test Series',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TestSeriesScreen(userID: userID),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0x80FFE082),
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
                            const Color(0x80F48FB1),
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
                            const Color(0xFFB3E5FC),
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
                            const Color(0x80FFF59D),
                            'assets/knowledge.png',
                            'Extra Knowledge',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ExtraKnowledge(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0x80FFF59D),
                            'assets/knowledge.png',
                            'General Knowledge',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GKPage(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0x80FFE082),
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
                            const Color(0x33FF00E5),
                            'assets/setting.png',
                            'Settings',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(),
                            ),
                          );
                        }),
                        buildTile(
                            context,
                            const Color(0xFFFFCDD2),
                            'assets/video knowledge.png',
                            'Video Knowledge',
                            tileWidth,
                            tileHeight, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoKnowledge(),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ]),
            );
          },
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
    final borderColor = HSLColor.fromColor(color).withLightness(0.95).toColor();

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
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 3,
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ]),
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
