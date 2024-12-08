import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/attendance.dart';
import 'package:trusir/extra_knowledge.dart';
import 'package:trusir/login_page.dart';
import 'package:trusir/profilepopup.dart';
import 'package:trusir/test_series.dart';
import 'package:trusir/fee_payment.dart';
import 'package:trusir/my_profile.dart';
import 'package:trusir/notice.dart';
import 'package:trusir/parents_doubt.dart';
import 'package:trusir/progress_report.dart';
import 'package:trusir/setting.dart';
import 'package:trusir/student_doubt.dart';
import 'package:trusir/teacher_myprofile.dart';
import 'package:trusir/video_knowledge.dart';

class Studentfacilities extends StatefulWidget {
  const Studentfacilities({super.key});

  @override
  State<Studentfacilities> createState() => _StudentfacilitiesState();
}

class _StudentfacilitiesState extends State<Studentfacilities> {
  String name = '';
  String profile = '';
  String address = '';
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
    setState(() {
      userID = prefs.getString('userID')!;
      name = prefs.getString('name')!;
      profile = prefs.getString('profile')!;
      address = prefs.getString('address')!;
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
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
              logout(context);
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
                  left: 20.0, right: 20, bottom: 5, top: 10),
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
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                width: 92,
                                height: 92,
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
                              builder: (context) => const AttendancePage(),
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
                              builder: (context) => const TestSeriesScreen(),
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
                              builder: (context) => const SettingsScreen(),
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
