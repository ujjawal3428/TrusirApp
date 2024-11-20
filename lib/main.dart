import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/login_page.dart';
import 'package:trusir/student_homepage.dart';
import 'package:trusir/teacher_homepage.dart';
import 'package:trusir/student_facilities.dart';
import 'package:trusir/teacher_facilities.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? role = prefs.getString('role');
    final bool isNewUser = prefs.getBool('new_user') ?? true;

    if (role == null) {
      // No user is logged in
      return const TrusirLoginPage();
    } else if (role == 'student' && isNewUser) {
      return const StudentHomepage();
    } else if (role == 'teacher' && isNewUser) {
      return const Teacherhomepage();
    } else if (role == 'student' && !isNewUser) {
      return const Studentfacilities();
    } else if (role == 'teacher' && !isNewUser) {
      return const TeacherFacilities();
    } else {
      // Fallback to login page if the role is unrecognized
      return const TrusirLoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            home: snapshot.data,
          );
        }
      },
    );
  }
}
