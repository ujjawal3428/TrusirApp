import 'package:flutter/material.dart';
import 'package:trusir/student/bottom_navigation_bar.dart';
import 'package:trusir/student/course.dart';
import 'package:trusir/student/setting.dart';
import 'package:trusir/student/student_facilities.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  // List of pages for each bottom navigation item
  final List<Widget> pages = [
    const Studentfacilities(), // Home page (Student Facilities)
    const CoursePage(), // Placeholder for Courses

    SettingsScreen(),
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
      backgroundColor: Colors.grey[50],
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
            child: CustomBottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabTapped,
            ),
          ),
        ],
      ),
    );
  }
}