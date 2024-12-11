import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/student_profile.dart';
import 'package:trusir/teacher/teacher_notice.dart';
import 'package:trusir/teacher/teacher_pf_page.dart';
import 'package:trusir/teacher/teacherssettings.dart';
import 'package:trusir/common/wanna_logout.dart';

class StudentProfile {
  final String name;
  final String image;
  final String phone;
  final String subject;
  final String userID;

  StudentProfile({
    required this.name,
    required this.image,
    required this.phone,
    required this.subject,
    required this.userID,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      name: json['name'],
      image: json['image'],
      phone: json['mobile'],
      subject: json['subject'],
      userID: json['userID'],
    );
  }
}

class TeacherFacilities extends StatefulWidget {
  const TeacherFacilities({super.key});

  @override
  State<TeacherFacilities> createState() => _TeacherFacilitiesState();
}

class _TeacherFacilitiesState extends State<TeacherFacilities> {
  List<StudentProfile> studentprofile = [];
  String name = '';
  String address = '';
  String phone = '';
  String profile = '';
  String userID = '';

  final apiBase = '$baseUrl/my-student';

  Future<void> fetchStudentProfiles({int page = 1}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    final url = '$apiBase/$userID';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        // Initial fetch
        studentprofile =
            data.map((json) => StudentProfile.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load student profiles');
    }
  }

  final List<Color> cardColors = [
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.purple.shade100,
  ];

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
    fetchStudentProfiles();
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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Teacher Facilities',
          style: TextStyle(
            color: Color(0xFF48116A),
            fontSize: 22,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WanaLogout()),
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
        toolbarHeight: 70,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Teacherpfpage()),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    address,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontSize: 13,
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
                              borderRadius: BorderRadius.circular(22),
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 94 / 120,
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
                          buildTile(context, const Color(0x80FFF59D),
                              'assets/noticesp@3x.png', 'Notice', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TeacherNoticeScreen(),
                              ),
                            );
                          }),
                          buildTile(context, const Color(0xFFB3E5FC),
                              'assets/setting.png', 'Setting', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Teacherssettings(),
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
                    padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
                    child: Text(
                      'Student Profiles',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      height: 340,
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 94 / 120,
                        ),
                        itemCount: studentprofile.length,
                        itemBuilder: (context, index) {
                          StudentProfile studentProfile = studentprofile[index];

                          Color cardColor =
                              cardColors[index % cardColors.length];

                          final borderColor = HSLColor.fromColor(cardColor)
                              .withLightness(0.95)
                              .toColor();

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentProfileScreen(
                                    name: studentProfile.name,
                                    phone: studentProfile.phone,
                                    subject: studentProfile.subject,
                                    image: studentProfile.image,
                                    userID: studentProfile.userID,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 94,
                              height: 120,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: borderColor,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.network(
                                        studentProfile.image,
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      studentProfile.name,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
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
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildTile(BuildContext context, Color color, String imagePath,
      String title, VoidCallback onTap) {
    final imageSize = imageSizes[imagePath] ?? {'width': 40.0, 'height': 40.0};
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.85 : 1.0;

    final borderColor = HSLColor.fromColor(color).withLightness(0.95).toColor();

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
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
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
}
