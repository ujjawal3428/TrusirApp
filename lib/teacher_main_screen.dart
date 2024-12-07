import 'package:flutter/material.dart';
import 'package:trusir/teacher_bottomnavbar.dart';
import 'package:trusir/teacher_facilities.dart';
import 'package:trusir/teacherssettings.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  TeacherMainScreenState createState() => TeacherMainScreenState();
}

class TeacherMainScreenState extends State<TeacherMainScreen> {
  int currentIndex = 0;

  // List of pages for each bottom navigation item
  final List<Widget> pages = [
    const TeacherFacilities(), // Home page (Student Facilities) // Placeholder for Courses
    const Teacherssettings(), // Placeholder for Menu
  ];

  // Function to handle bottom navigation item taps
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
                bottom: currentIndex == 2
                    ? 0
                    : 80), // Adjust for bottom nav bar height
            child: pages[currentIndex],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TeacherBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}
