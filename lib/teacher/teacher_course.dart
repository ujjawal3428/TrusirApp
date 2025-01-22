import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/course.dart';
import 'package:trusir/teacher/teacher_facilities.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';

class TeacherCourse {
  final int id;
  final String amount;
  final String name;
  final String subject;
  final String image;

  TeacherCourse({
    required this.id,
    required this.amount,
    required this.name,
    required this.subject,
    required this.image,
  });
}

class TeacherCourseCard extends StatelessWidget {
  final TeacherCourse course;

  const TeacherCourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.pinkAccent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
              'End to - 20/10/2024',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '₹${course.amount}',
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
                  child: const Text(
                    'Demo',
                    style: TextStyle(
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
      print(studentprofile[0].userID);
    } else {
      throw Exception('Failed to load student profiles');
    }
  }

  Future<List<CourseDetail>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    final url = Uri.parse('$baseUrl/get-courses/$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final responseData =
          data.map((json) => CourseDetail.fromJson(json)).toList();
      _courseDetails = responseData;
      return _courseDetails;
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  List<CourseDetail> _courseDetails = [];

  @override
  void initState() {
    super.initState();
    fetchStudentProfiles();
    fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    final List<TeacherCourse> courses = [
      TeacherCourse(
        id: 1,
        amount: '1500',
        name: 'Mathematics Basics',
        subject: 'Mathematics',
        image:
            'https://admin.trusir.com/uploads/profile/profile_1736527860.jpg',
      ),
      TeacherCourse(
        id: 2,
        amount: '2000',
        name: 'Science Experiments',
        subject: 'Science',
        image:
            'https://admin.trusir.com/uploads/profile/profile_1736527860.jpg',
      ),
      TeacherCourse(
        id: 3,
        amount: '1800',
        name: 'English Grammar',
        subject: 'English',
        image:
            'https://admin.trusir.com/uploads/profile/profile_1736527860.jpg',
      ),
    ];

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
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  studentprofile.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple[50],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Handle student button click
                      },
                      child: Text(
                        studentprofile[index].name,
                        style: const TextStyle(
                          color: Colors.deepPurple,
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWeb ? 2 : 1,
            mainAxisExtent: isWeb ? 550 : null,
            childAspectRatio: 16 / 14),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return TeacherCourseCard(course: course);
        },
      ),
    );
  }
}
