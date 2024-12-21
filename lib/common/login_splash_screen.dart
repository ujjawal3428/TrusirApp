import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';

class LoginSplashScreen extends StatefulWidget {
  const LoginSplashScreen({super.key});

  @override
  LoginSplashScreenState createState() => LoginSplashScreenState();
}

class LoginSplashScreenState extends State<LoginSplashScreen> {
  @override
  void initState() {
    super.initState();
    _fetchAndStoreUserData();
  }

  Future<void> _fetchAndStoreUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Fetch UserID from SharedPreferences
    String? userId = prefs.getString('userID');
    print("UserID: $userId");
    if (userId == null) {
      print("UserID not found in SharedPreferences");
      return;
    }

    try {
      // API call
      final response = await http.get(
        Uri.parse('$baseUrl/api/get-user/$userId'),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final responseData = json.decode(response.body);

        // Store each entry in SharedPreferences
        if (responseData['role'] == 'student') {
          await prefs.setString('id', responseData['id'].toString());
          await prefs.setString('name', responseData['name'] ?? 'N/A');
          await prefs.setString(
              'father_name', responseData['father_name'] ?? 'N/A');
          await prefs.setString(
              'mother_name', responseData['mother_name'] ?? 'N/A');
          await prefs.setString('gender', responseData['gender'] ?? 'N/A');
          await prefs.setString('class', responseData['class'] ?? 'N/A');
          await prefs.setString('subject', responseData['subject'] ?? 'N/A');
          await prefs.setString('DOB', responseData['DOB'] ?? 'N/A');
          await prefs.setString('role', responseData['role'] ?? 'N/A');
          await prefs.setString('school', responseData['school'] ?? 'N/A');
          await prefs.setString('medium', responseData['medium'] ?? 'N/A');
          await prefs.setString('state', responseData['state'] ?? 'N/A');
          await prefs.setString('city', responseData['city'] ?? 'N/A');
          await prefs.setString('address', responseData['address'] ?? 'N/A');
          await prefs.setString('area', responseData['area'] ?? 'N/A');
          await prefs.setString('pincode', responseData['pincode'] ?? 'N/A');
          await prefs.setString(
              'adhaar_front', responseData['adhaar_front'] ?? 'N/A');
          await prefs.setString(
              'adhaar_back', responseData['adhaar_back'] ?? 'N/A');
          await prefs.setString('profile', responseData['profile'] ?? 'N/A');
          await prefs.setString(
              'time_slot', responseData['time_slot'] ?? 'N/A');
        } else if (responseData['role'] == 'teacher') {
          await prefs.setString('id', responseData['id'].toString());
          await prefs.setString('name', responseData['name'] ?? 'N/A');
          await prefs.setString(
              'father_name', responseData['father_name'] ?? 'N/A');
          await prefs.setString(
              'mother_name', responseData['mother_name'] ?? 'N/A');
          await prefs.setString('gender', responseData['gender'] ?? 'N/A');
          await prefs.setString('class', responseData['class'] ?? 'N/A');
          await prefs.setString('subject', responseData['subject'] ?? 'N/A');
          await prefs.setString('DOB', responseData['DOB'] ?? 'N/A');
          await prefs.setString('role', responseData['role'] ?? 'N/A');
          await prefs.setString('school', responseData['school'] ?? 'N/A');
          await prefs.setString('medium', responseData['medium'] ?? 'N/A');
          await prefs.setString('state', responseData['state'] ?? 'N/A');
          await prefs.setString('city', responseData['city'] ?? 'N/A');
          await prefs.setString(
              'qualification', responseData['qualification'] ?? 'N/A');
          await prefs.setString(
              'experience', responseData['experience'] ?? 'N/A');
          await prefs.setString('address', responseData['address'] ?? 'N/A');
          await prefs.setString('area', responseData['area'] ?? 'N/A');
          await prefs.setString('pincode', responseData['pincode'] ?? 'N/A');
          await prefs.setString(
              'adhaar_front', responseData['adhaar_front'] ?? 'N/A');
          await prefs.setString(
              'adhaar_back', responseData['adhaar_back'] ?? 'N/A');
          await prefs.setString('profile', responseData['profile'] ?? 'N/A');
          await prefs.setString(
              'time_slot', responseData['time_slot'] ?? 'N/A');
        }

        // Navigate to the next screen
        if (responseData['role'] == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else if (responseData['role'] == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherMainScreen()),
          );
        }
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Successful!'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        // Handle API error
        print('Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
