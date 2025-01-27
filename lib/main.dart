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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
          Colors.grey[200], // Set the navigation bar color to grey
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up fade animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    navigateToInitialPage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> navigateToInitialPage() async {
    await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
    final initialPage = await getInitialPage();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => initialPage),
      );
    }
  }

  Future<Widget> getInitialPage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? role = prefs.getString('role');
    final bool isNewUser = prefs.getBool('new_user') ?? true;

    if (role == null) {
      return const TrusirLoginPage();
    } else if (role == 'student' && isNewUser) {
      return const TrusirLoginPage();
    } else if (role == 'teacher' && isNewUser) {
      return const TrusirLoginPage();
    } else if (role == 'student' && !isNewUser) {
      return const MainScreen(
        index: 0,
      );
    } else if (role == 'teacher' && !isNewUser) {
      return const TeacherMainScreen();
    } else {
      return const TrusirLoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C006D),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.accents[3].withValues(alpha: 0.9),
                  const Color(0xFF3C006D).withValues(alpha: 0.9),
                  const Color(0xFF5A008F).withValues(alpha: 0.9),
                  Colors.accents[4].withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Logo with fade animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/trusir.png', // Replace with your logo asset path
                      width: 200,
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              left: 120,
              right: 0,
              bottom: 110,
              child: Text(
                'trusir.com',
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.grey[100],
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700),
              ))
        ],
      ),
    );
  }
}
