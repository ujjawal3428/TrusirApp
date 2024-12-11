import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/Enquiry.dart';
import 'package:trusir/common/api.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:trusir/common/login_splash_screen.dart';

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
    String otp = otpControllers.map((controller) => controller.text).join();
    print("Entered OTP: $otp");

    if (otp.length != 4 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 4-digit OTP'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await fetchUserData(phone);
    showVerificationDialog(context);
    // verifyOTP(phone, otp);
    // Handle OTP verification logic
  }

  Future<void> verifyOTP(String phone, String otp) async {
    final url = Uri.parse(
      '$otpapi/SMS/VERIFY3/91$phone/$otp',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['Status'] == 'Success') {
          print('OTP verified successfully: ${response.body}');
          showVerificationDialog(context);
        } else if (responseBody['Status'] == 'Error') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseBody['Details']),
              duration: const Duration(seconds: 1),
            ),
          );
          print('Failed to verify OTP: ${responseBody['Details']}');
        } else {
          print('Unexpected response: ${response.body}');
        }
      } else {
        print('Failed to verify OTP with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
    }
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
        Navigator.pushReplacement(
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
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24, top: 150),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF48116A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the verification code we \njust sent on your phone number.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 44),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color.fromARGB(255, 177, 177, 177),
                          width: 1.5),
                    ),
                    child: TextField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
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
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Resend OTP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Color(0xFF48116A),
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 250,
              ),
              GestureDetector(
                onTap: () {
                  onPost(widget.phonenum, context);
                },
                child: Container(
                  width: 300,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 25, 220, 70),
                        Color.fromARGB(255, 2, 120, 12),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Verify',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins'),
                    ),
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
