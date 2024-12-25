import 'package:flutter/material.dart';
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
                  child: Image.network(
                    course.image,
                    width: double.infinity,
                    height: 180,
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
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
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

class TeacherCoursePage extends StatelessWidget {
  const TeacherCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TeacherCourse> courses = [
      TeacherCourse(
        id: 1,
        amount: '1500',
        name: 'Mathematics Basics',
        subject: 'Mathematics',
        image: 'https://via.placeholder.com/150',
      ),
      TeacherCourse(
        id: 2,
        amount: '2000',
        name: 'Science Experiments',
        subject: 'Science',
        image: 'https://via.placeholder.com/150',
      ),
      TeacherCourse(
        id: 3,
        amount: '1800',
        name: 'English Grammar',
        subject: 'English',
        image: 'https://via.placeholder.com/150',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
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
              child: const Icon(Icons.arrow_back, color: Colors.deepPurple),
            ),
            const SizedBox(width: 16),
            const Text(
              'Courses',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
                  5,
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
                        'Student ${index + 1}',
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
      body: ListView.builder(
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
