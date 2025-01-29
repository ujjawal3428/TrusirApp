import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/teacher_facilities.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';

class MyCourseModel {
  final int id;
  final String courseID;
  final String courseName;
  final String teacherName;
  final String teacherID;
  final String studentID;
  final String image;
  final String studentName;
  final String timeSlot;
  final String type;
  final String price;

  MyCourseModel({
    required this.id,
    required this.courseID,
    required this.courseName,
    required this.teacherName,
    required this.teacherID,
    required this.studentID,
    required this.image,
    required this.studentName,
    required this.timeSlot,
    required this.type,
    required this.price,
  });

  // Factory method for creating an instance from JSON
  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    return MyCourseModel(
      id: json['id'],
      courseID: json['courseID'],
      courseName: json['courseName'],
      teacherName: json['teacherName'],
      teacherID: json['teacherID'],
      studentID: json['StudentID'],
      image: json['image'],
      studentName: json['StudentName'],
      timeSlot: json['timeSlot'],
      type: json['type'],
      price: json['price'],
    );
  }
}

class TeacherCourseCard extends StatelessWidget {
  final MyCourseModel course;

  const TeacherCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        course.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.error,
                              size: 40,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.deepPurple,
                            Colors.pinkAccent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.courseName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Start from - 01/10/2024',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Time Slot: ${course.timeSlot}',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹${course.price}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                    child: Text(
                      course.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherCoursePage extends StatefulWidget {
  const TeacherCoursePage({super.key});

  @override
  State<TeacherCoursePage> createState() => _TeacherCoursePageState();
}

class _TeacherCoursePageState extends State<TeacherCoursePage> {
  final apiBase = '$baseUrl/my-student';
  List<MyCourseModel> courses = [];
  List<StudentProfile> studentprofile = [];
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

  Future<List<MyCourseModel>> fetchCourses(String userID) async {
    final url = Uri.parse('$baseUrl/get-courses/$userID');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final responseData =
          data.map((json) => MyCourseModel.fromJson(json)).toList();
      courses = responseData;
      return courses;
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    await fetchStudentProfiles();
    await fetchCourses(studentprofile[0].userID);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherMainScreen(),
                    ),
                  );
                },
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 20),
              const Text(
                'Course',
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 8.0, right: 8, top: 0, bottom: 6),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    studentprofile.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            fetchCourses(studentprofile[index].userID);
                          });
                        },
                        child: Text(
                          studentprofile[index].name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWeb ? 2 : 1,
            // mainAxisExtent: isWeb ? 560 : null,
            childAspectRatio: 16 / 14.5),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        shrinkWrap: true,
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return TeacherCourseCard(course: course);
        },
      ),
    );
  }
}
