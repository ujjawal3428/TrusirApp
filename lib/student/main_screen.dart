import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trusir/student/bottom_navigation_bar.dart';
import 'package:trusir/student/course.dart';
import 'package:trusir/student/setting.dart';
import 'package:trusir/student/student_facilities.dart';

class MainScreen extends StatefulWidget {
  final int index;
  const MainScreen({super.key, required this.index});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentIndex = widget.index;
    });
  }

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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey[50], // Transparent for the homepage
        statusBarIconBrightness:
            Brightness.dark, // White icons for a dark background
      ),
    );
    return SafeArea(
      child: Scaffold(
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
      ),
    );
  }
}
