import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trusir/enquiry.dart';
import 'package:trusir/login_splash_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phonenum;
  const OTPScreen({super.key, required this.phonenum});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool newuser = false;

  Future<Map<String, dynamic>?> fetchUserData(String phoneNumber) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Fetch from API
    try {
      final url = Uri.parse('$baseUrl/api/login/$phoneNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check response structure
        if (responseData.containsKey('new_user')) {
          final bool isNewUser = responseData['new_user'];

          // Save response to cache
          await prefs.setBool('new_user', isNewUser);
          setState(() {
            newuser = isNewUser;
          });

          if (isNewUser) {
            print('New user: $newuser');
          } else {
            await prefs.setString('userID', responseData['uerID']);
            await prefs.setString('role', responseData['role']);
            await prefs.setString('token', responseData['token']);
            await prefs.setBool('new_user', responseData['new_user']);
            print('Returning user data cached.');
          }

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

  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());

  // FocusNodes for each field
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  void onPost(String phone, BuildContext context) async {
    // Combine OTP from all controllers
    String otp = otpControllers.map((controller) => controller.text).join();
    print("Entered OTP: $otp");
    await fetchUserData(phone);
    showVerificationDialog(context);
    // Handle OTP verification logic
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
      if (newuser) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EnquiryPage()),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginSplashScreen()),
          (route) => false,
        );
      }
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
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const NeverScrollableScrollPhysics(),
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
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
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
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          // Move to the next field
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          // Move to the previous field if backspace is pressed
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  onPost(widget.phonenum, context);
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
      ),
    );
  }
}
