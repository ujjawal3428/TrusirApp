import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';

class SplashScreen extends StatefulWidget {
  final String phone;
  const SplashScreen({super.key, required this.phone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Step 1: Fetch userID using phone number
      await _fetchAndStoreUserID();

      // Step 2: Fetch and store user details
      await _fetchAndStoreUserData();
      String? role = prefs.getString('role');
      // Navigate to the next page
      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TeacherMainScreen()),
        );
      }
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  Future<void> _fetchAndStoreUserID() async {
    final prefs = await SharedPreferences.getInstance();

    // Call the login API
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/login/${widget.phone}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String userID = responseData['uerID'];
        String token = responseData['token'];
        String role = responseData['role'];
        bool newUser = responseData['new_user'];

        // Store userID in SharedPreferences
        await prefs.setString('userID', userID);
        await prefs.setString('phone_number', widget.phone);
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setBool('new_user', newUser);
      } else {
        throw Exception(
            'Failed to fetch userID. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching userID: $e');
    }
  }

  Future<void> _fetchAndStoreUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch userID from SharedPreferences
    String? userId = prefs.getString('userID');
    if (userId == null) {
      throw Exception('UserID not found in SharedPreferences');
    }

    // Call the user details API
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/get-user/$userId'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['role'] == 'student') {
          await prefs.setString('id', responseData['id'].toString());
          await prefs.setString('name', responseData['name']);
          await prefs.setString('father_name', responseData['father_name']);
          await prefs.setString('mother_name', responseData['mother_name']);
          await prefs.setString('gender', responseData['gender']);
          await prefs.setString('class', responseData['class']);
          await prefs.setString('subject', responseData['subject']);
          await prefs.setString('DOB', responseData['DOB']);
          await prefs.setString('role', responseData['role']);
          await prefs.setString('school', responseData['school']);
          await prefs.setString('medium', responseData['medium']);
          await prefs.setString('state', responseData['state']);
          await prefs.setString('city', responseData['city']);
          await prefs.setString('address', responseData['address']);
          await prefs.setString('area', responseData['area']);
          await prefs.setString('pincode', responseData['pincode']);
          await prefs.setString('adhaar_front', responseData['adhaar_front']);
          await prefs.setString('adhaar_back', responseData['adhaar_back']);
          await prefs.setString('profile', responseData['profile']);
          await prefs.setString('time_slot', responseData['time_slot']);
        } else if (responseData['role'] == 'teacher') {
          await prefs.setString('id', responseData['id'].toString());
          await prefs.setString('name', responseData['name']);
          await prefs.setString('father_name', responseData['father_name']);
          await prefs.setString('mother_name', responseData['mother_name']);
          await prefs.setString('gender', responseData['gender']);
          await prefs.setString('class', responseData['class']);
          await prefs.setString('subject', responseData['subject']);
          await prefs.setString('DOB', responseData['DOB']);
          await prefs.setString('role', responseData['role']);
          await prefs.setString('school', responseData['school']);
          await prefs.setString('medium', responseData['medium']);
          await prefs.setString('state', responseData['state']);
          await prefs.setString('city', responseData['city']);
          await prefs.setString(
              'qualification', responseData['qualification'] ?? 'N/A');
          await prefs.setString(
              'experience', responseData['experience'] ?? 'N/A');
          await prefs.setString('address', responseData['address']);
          await prefs.setString('area', responseData['area']);
          await prefs.setString('pincode', responseData['pincode']);
          await prefs.setString('adhaar_front', responseData['adhaar_front']);
          await prefs.setString('adhaar_back', responseData['adhaar_back']);
          await prefs.setString('profile', responseData['profile']);
          await prefs.setString('time_slot', responseData['time_slot']);
        }
      } else {
        throw Exception(
            'Failed to fetch user details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()));
  }
}
