import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/login_page.dart';

class WanaLogout extends StatelessWidget {
  final String profile;
  const WanaLogout({super.key, required this.profile});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TrusirLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWeb = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Main content with padding and scroll view
          Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button

                    // Online Payment Button
                    Center(
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[50],
                        radius: 150,
                        child: ClipOval(
                          child: Image.network(
                            profile,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
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
                    const SizedBox(height: 50),

                    // Cancel Button
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        }, // Calls _onEnquire on tap
                        child: Image.asset(
                          height: isWeb ? 150 : null,
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
                          height: isWeb ? 150 : null,
                          'assets/logoutbutton.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
