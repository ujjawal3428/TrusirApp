import 'dart:math';

import 'package:flutter/material.dart';

class StudentProfilePage extends StatefulWidget {
  final String? name;
  final String? fatherName;
  final String? school;
  final String? studentClass;
  final String? subject;
  final String? profile;
  final String? address;
  final String? phone;
  const StudentProfilePage(
      {super.key,
      required this.name,
      required this.fatherName,
      required this.school,
      required this.studentClass,
      required this.subject,
      required this.profile,
      required this.address,
      required this.phone});

  @override
  StudentProfilePageState createState() => StudentProfilePageState();
}

class StudentProfilePageState extends State<StudentProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    final rowColors = [
      const Color.fromARGB(255, 255, 199, 221),
      const Color.fromARGB(255, 199, 236, 255),
      const Color.fromARGB(255, 255, 185, 185),
      const Color.fromARGB(255, 191, 184, 255),
      Colors.green.shade100
    ];

    return Scaffold(
        backgroundColor: Colors.grey[50],
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
                const SizedBox(width: 20),
                Text(
                  "${widget.name}'s Profile",
                  style: const TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            // Profile header
            SizedBox(
                width: screenWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: isLargeScreen ? 250 : 130,
                              height: isLargeScreen ? 250 : 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(widget.profile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Center(
                            child: Text(
                              widget.name!,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 22 : 20,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF48116A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5), // Bottom spacing
                        ],
                      ),
                    ),
                  ],
                )),
            // Info rows
            const SizedBox(height: 18),
            buildInfoRow(
              'assets/men@4x.png',
              'Father Name',
              widget.fatherName!,
              60,
              isLargeScreen,
              rowColors[0],
            ),
            const SizedBox(height: 13),
            buildInfoRow(
              'assets/graduation@3x.png',
              'Class',
              widget.studentClass!,
              60,
              isLargeScreen,
              rowColors[2],
            ),
            const SizedBox(height: 13),
            buildInfoRow(
              'assets/pensp@3x.png',
              'Subjects',
              widget.subject!,
              60,
              isLargeScreen,
              rowColors[3],
            ),
            const SizedBox(height: 13),
            buildInfoRow(
              'assets/house@3x.png',
              'School',
              widget.school!,
              60,
              isLargeScreen,
              rowColors[1],
            ),
            const SizedBox(height: 13),
            buildInfoRow(
              'assets/phone@2x.png',
              'Phone',
              '+91-${widget.phone}',
              60,
              isLargeScreen,
              rowColors[1],
            ),
            const SizedBox(height: 13),
            buildInfoRow('assets/location@2x.png', 'Address', widget.address!,
                null, isLargeScreen, rowColors[4]),
            const SizedBox(height: 20),
          ]),
        ));
  }

  Widget buildInfoRow(
    String iconPath,
    String title,
    String value,
    double? containerHeight,
    bool isLargeScreen,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 17.0, right: 17),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: isLargeScreen ? 100 : 60,
            height: isLargeScreen ? 100 : 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(3, 3),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text container
          Flexible(
            child: Container(
              height: isLargeScreen ? 100 : max(60, containerHeight ?? 110),
              width: isLargeScreen ? 400 : 306,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 10, bottom: 10, right: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value.isNotEmpty ? value : 'Loading...',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isLargeScreen ? 22 : 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
