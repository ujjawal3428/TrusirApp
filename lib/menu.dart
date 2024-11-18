import 'package:flutter/material.dart';
import 'package:trusir/Teacher%20homepage.dart';
import 'package:trusir/course.dart';
import 'package:trusir/practice.dart';
import 'package:trusir/student_homepage.dart';
import 'package:trusir/studentregisteration.dart';
import 'package:trusir/teachersregisteration.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Menu Page"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1,
          vertical: size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FancyButton(
              text: 'Go to student page',
              icon: Icons.home,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentHomepage()),
                );
              },
            ),
            SizedBox(height: size.height * 0.04),
            FancyButton(
              text: 'Go to teachers page',
              icon: Icons.school,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  const Teacherhomepage()),
                );
              },
            ),
            SizedBox(height: size.height * 0.04),
            FancyButton(
              text: 'Go to student Registeration',
              icon: Icons.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentRegistrationPage()),
                );
              },
            ),

             SizedBox(height: size.height * 0.04),
            FancyButton(
              text: 'Go to teachers Registeration',
              icon: Icons.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherRegistrationPage()),
                );
              },
            ),
               SizedBox(height: size.height * 0.04),
              FancyButton(
              text: 'Practice Page',
              icon: Icons.sports_football,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OpenImageButton()),
                );
              },
            ),
             SizedBox(height: size.height * 0.04),
              FancyButton(
              text: 'Course Page',
              icon: Icons.sports_football,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CoursePage()),
                );
              },
            ),
             SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }
}

class FancyButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const FancyButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size.width * 0.07),
            SizedBox(width: size.width * 0.04),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
