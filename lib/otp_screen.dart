import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trusir/enquiry.dart';

class OTPScreen extends StatelessWidget {
  final String phonenum;
  OTPScreen({super.key, required this.phonenum});

  final TextEditingController otpController = TextEditingController();

  Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch from API
    try {
      final url = Uri.parse('$baseUrl/login/$phoneNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check response structure
        if (responseData.containsKey('phone_number') &&
            responseData.containsKey('uerID') &&
            responseData.containsKey('role') &&
            responseData.containsKey('new_user')) {
          // Save response to cache
          await prefs.setString('userID', responseData['uerID']);
          await prefs.setString('phone', responseData['phone_number']);
          await prefs.setString('role', responseData['role']);
          await prefs.setBool('new_user', responseData['new_user']);
          print('Data fetched from API and cached.');
          return responseData;
        } else {
          print('Unexpected response structure.');
          return null;
        }
      } else {
        print('Failed to fetch data from API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  void onPost(String phone, BuildContext context) async {
    await fetchUserData(phone);
    showVerificationDialog(context);
  }

  void showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.pink, size: 60),
              SizedBox(height: 16),
              Text(
                'Your OTP has been verified!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    // Close the dialog and navigate to the next screen after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close the dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EnquiryPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Enter OTP', style: TextStyle(color: Colors.purple)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the verification code we just sent on your phone number.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: TextField(
                    controller: otpController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                onPost(phonenum, context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
