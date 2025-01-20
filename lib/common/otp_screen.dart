import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isVerifying = false;

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
    if (otp.length != 4 || !RegExp(r'^[0-9]+$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 4-digit OTP'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show progress indicator
    setState(() {
      isVerifying = true;
    });

    try {
      // await verifyOTP(phone, otp);
      await fetchUserData(phone);
      showVerificationDialog(context);
    } finally {
      // Hide progress indicator
      setState(() {
        isVerifying = false;
      });
    }
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
          await fetchUserData(phone);
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
      barrierColor: Colors.grey,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/check.png', height: 100, width: 100),
              const SizedBox(height: 16),
              Text(
                'Your OTP has been verified!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.purple.shade900,
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
    final isWeb =
        MediaQuery.of(context).size.width > 900; // Detecting web screens

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png',
                      height: isWeb ? 60 : 50)), // Adjust back button size
            ],
          ),
        ),
        toolbarHeight: isWeb ? 90 : 70, // Adjust toolbar height for web
      ),
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 100 : 24.0, // Adjust padding for web
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isWeb ? 45 : 35, // Increase font size for web
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF48116A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the verification code \nwe just sent on your phone number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isWeb ? 18 : 16, // Adjust font size for web
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 44),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return Container(
                      height:
                          isWeb ? 80 : 60, // Increase container size for web
                      width:
                          isWeb ? 80 : 60, // Increase container width for web
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color.fromARGB(255, 177, 177, 177),
                          width: 1.5,
                        ),
                      ),
                      child: RawKeyboardListener(
                        focusNode:
                            FocusNode(), // Use a separate focus node for the listener
                        onKey: (RawKeyEvent event) {
                          if (event
                                  .isKeyPressed(LogicalKeyboardKey.backspace) &&
                              otpControllers[index].text.isEmpty &&
                              index > 0) {
                            // Move to the previous field when backspace is pressed
                            FocusScope.of(context)
                                .requestFocus(focusNodes[index - 1]);
                            otpControllers[index].clear();
                          }
                        },
                        child: TextFormField(
                          controller: otpControllers[index],
                          focusNode: focusNodes[index],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                                left: 10, right: 10, top: isWeb ? 20 : 10),
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize:
                                isWeb ? 30 : 24, // Adjust text size for web
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 3) {
                              FocusScope.of(context)
                                  .requestFocus(focusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(focusNodes[index - 1]);
                            }

                            bool allFilled = otpControllers.every(
                                (controller) => controller.text.isNotEmpty);
                            if (allFilled) {
                              FocusScope.of(context).unfocus();
                              onPost(widget.phonenum, context);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 70),
                _buildVerifyButton(isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(bool isWeb) {
    return Center(
      child: isVerifying
          ? const CircularProgressIndicator() // Show progress indicator
          : GestureDetector(
              onTap: () {
                onPost(widget.phonenum, context);
              },
              child: Image.asset(
                height: isWeb ? 150 : null,
                'assets/verify.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}
