import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/teacher/teacher_main_screen.dart';

class EditSplashScreen extends StatefulWidget {
  const EditSplashScreen({super.key});

  @override
  EditSplashScreenState createState() => EditSplashScreenState();
}

class EditSplashScreenState extends State<EditSplashScreen> {
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
