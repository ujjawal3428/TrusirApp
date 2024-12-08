import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/login_page.dart';
import 'package:trusir/main_screen.dart';
import 'package:trusir/teacher_main_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trusir/notificationhelper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      if (notificationResponse.payload != null) {
        handleNotificationTap(notificationResponse.payload!); // Handle tap
      }
    },
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      return const TrusirLoginPage();
    } else if (role == 'teacher' && isNewUser) {
      return const TrusirLoginPage();
    } else if (role == 'student' && !isNewUser) {
      return const MainScreen();
    } else if (role == 'teacher' && !isNewUser) {
      return const TeacherMainScreen();
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
