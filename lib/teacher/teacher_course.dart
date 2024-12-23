import 'package:flutter/material.dart';
import 'package:trusir/student/main_screen.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 4),
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
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Science',
                      style: TextStyle(
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
            const Text(
              'Start from - 01/10/2024',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'End to - 20/10/2024',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
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
                const SizedBox(width: 20,),
                 SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {  },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
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
        elevation: 1,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              },
              child: Image.asset('assets/back_button.png', height: 30),
            ),
            const SizedBox(width: 20),
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