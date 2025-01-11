import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/main_screen.dart';

class PopUpSplashScreen extends StatefulWidget {
  final String userId;

  const PopUpSplashScreen({super.key, required this.userId});

  @override
  PopUpSplashScreenState createState() => PopUpSplashScreenState();
}

class PopUpSplashScreenState extends State<PopUpSplashScreen> {
  @override
  void initState() {
    super.initState();
    _clearUserData().then((_) => _fetchAndStoreUserData(widget.userId));
  }

  // Function to clear specific user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // List of keys to clear
    List<String> keysToClear = [
      'id',
      'name',
      'father_name',
      'mother_name',
      'gender',
      'class',
      'subject',
      'DOB',
      'userID',
      'role',
      'school',
      'medium',
      'state',
      'city',
      'address',
      'area',
      'pincode',
      'adhaar_front',
      'adhaar_back',
      'profile',
      'time_slot',
    ];

    for (String key in keysToClear) {
      await prefs.remove(key);
    }
  }

  // Function to fetch user data and store it in SharedPreferences
  Future<void> _fetchAndStoreUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userId);

    try {
      // API call
      final response = await http.get(
        Uri.parse('$baseUrl/api/get-user/$userId'),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final responseData = json.decode(response.body);

        // Store each entry in SharedPreferences
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
        await prefs.setString(
            'adhaar_front', responseData['adhaar_front'] ?? 'N/A');
        await prefs.setString(
            'adhaar_back', responseData['adhaar_back'] ?? 'N/A');
        await prefs.setString('profile', responseData['profile'] ?? 'N/A');

        // Navigate to the next screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
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
