import 'package:flutter/material.dart';
import 'package:trusir/common/wanna_logout.dart';

class InactivePage extends StatelessWidget {
  const InactivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Padding(
            padding: EdgeInsets.only(top: 0),
            child: Text(
              'Account Inactive',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WanaLogout(
                        profile:
                            'https://admin.trusir.com/uploads/profile/profile_1738645207.png'),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 0, right: 20.0),
                child: Image.asset(
                  'assets/logout@3x.png',
                  width: 103,
                  height: 24,
                ),
              ),
            ),
          ],
          toolbarHeight: 70,
        ),
        body: const Center(
            child: Text('Account Inactive, Please Contact Administrator')));
  }
}
