import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/login_page.dart';

class WanaLogout extends StatelessWidget {
  const WanaLogout({super.key});

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TrusirLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content with padding and scroll view
          Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Color(0xFF48116A),
                      size: 30,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 160),

                  // Online Payment Button
                  Center(
                    child: Image.asset(
                      'assets/wanna_logout.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Logout Confirmation Text
                  const Center(
                    child: Text(
                      'Are you sure you want to Logout?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 190),

                  // Cancel Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      }, // Calls _onEnquire on tap
                      child: Image.asset(
                        'assets/cancelbutton.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Logout Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        logout(context);
                      }, // Calls _onEnquire on tap
                      child: Image.asset(
                        'assets/logoutbutton.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
