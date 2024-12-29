import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/login_page.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:trusir/common/notificationhelper.dart';

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
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor:
        Colors.grey[50], // Set the navigation bar color to grey
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.grey[50],
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: snapshot.data,
          );
        }
      },
    );
  }
}
