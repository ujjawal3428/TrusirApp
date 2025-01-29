import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/student/editprofilescreen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  MyProfileScreenState createState() => MyProfileScreenState();
}

class MyProfileScreenState extends State<MyProfileScreen> {
  String? name;
  String? dob;
  String? school;
  String? studentClass;
  String? subject;
  String? profile;
  String? userID;
  String? address;
  String? phone;
  String? fatherName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      name = prefs.getString('name') ?? 'N/A';
      dob = prefs.getString('DOB') ?? 'N/A';
      school = prefs.getString('school') ?? 'N/A';
      studentClass = prefs.getString('class') ?? 'N/A';
      subject = prefs.getString('subject') ?? 'N/A';
      fatherName = prefs.getString('father_name') ?? 'N/A';
      profile = prefs.getString('profile') ?? '';
      address = prefs.getString('address') ?? 'N/A';
      phone = prefs.getString('phone_number') ?? 'N/A';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    const rowColors = [
      Color.fromARGB(255, 255, 199, 221),
      Color.fromARGB(255, 216, 185, 255),
      Color.fromARGB(255, 199, 255, 215),
      Color.fromARGB(255, 199, 236, 255),
      Color.fromARGB(255, 255, 185, 185),
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
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 20),
              const Text(
                'My Profile',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(right: isLargeScreen ? 30 : 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 20 : 10,
                        vertical: isLargeScreen ? 10 : 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 20 : 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF48116A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: isLargeScreen
                  ? Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left: Profile image and name
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                profile != null && profile!.isNotEmpty
                                    ? Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(profile!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        radius: 100,
                                        backgroundColor: Colors.grey[300],
                                        child: const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(height: 10),
                                Text(
                                  name!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF48116A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Right: Info rows
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 50,
                                ),
                                buildInfoRow(
                                  'assets/men.png',
                                  'Father Name',
                                  fatherName!,
                                  isLargeScreen,
                                  rowColors[0],
                                ),
                                const SizedBox(height: 10),
                                buildInfoRow(
                                  'assets/graduation@3x.png',
                                  'Class',
                                  studentClass!,
                                  isLargeScreen,
                                  rowColors[1],
                                ),
                                const SizedBox(height: 10),
                                buildInfoRow(
                                  'assets/pensp@3x.png',
                                  'Subjects',
                                  subject!,
                                  isLargeScreen,
                                  rowColors[2],
                                ),
                                const SizedBox(height: 10),
                                buildInfoRow(
                                  'assets/house@3x.png',
                                  'School',
                                  school!,
                                  isLargeScreen,
                                  rowColors[3],
                                ),
                                const SizedBox(height: 10),
                                buildInfoRow(
                                  'assets/phone@2x.png',
                                  'Phone',
                                  '+91-$phone',
                                  isLargeScreen,
                                  rowColors[4],
                                ),
                                const SizedBox(height: 10),
                                buildInfoRow(
                                  'assets/location@2x.png',
                                  'Phone',
                                  address!,
                                  isLargeScreen,
                                  rowColors[0],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
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
                                      child: profile != null &&
                                              profile!.isNotEmpty
                                          ? Container(
                                              width: isLargeScreen ? 250 : 130,
                                              height: isLargeScreen ? 250 : 130,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(profile!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: isLargeScreen ? 125 : 65,
                                              backgroundColor: Colors.grey[300],
                                              child: const Icon(
                                                Icons.person,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 7),
                                    Center(
                                      child: Text(
                                        name!,
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 22 : 20,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF48116A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5), // Bottom spacing
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Info rows
                        const SizedBox(height: 18),
                        buildInfoRow(
                          'assets/men@4x.png',
                          'Father Name',
                          fatherName!,
                          isLargeScreen,
                          rowColors[0],
                        ),
                        const SizedBox(height: 13),
                        buildInfoRow(
                          'assets/graduation@3x.png',
                          'Class',
                          studentClass!,
                          isLargeScreen,
                          rowColors[1],
                        ),
                        const SizedBox(height: 13),
                        buildInfoRow(
                          'assets/pensp@3x.png',
                          'Subjects',
                          subject!,
                          isLargeScreen,
                          rowColors[2],
                        ),
                        const SizedBox(height: 13),
                        buildInfoRow(
                          'assets/house@3x.png',
                          'School',
                          school!,
                          isLargeScreen,
                          rowColors[3],
                        ),
                        const SizedBox(height: 13),
                        buildInfoRow(
                          'assets/phone@2x.png',
                          'Phone',
                          '+91-$phone',
                          isLargeScreen,
                          rowColors[4],
                        ),
                        const SizedBox(height: 13),
                        buildInfoRow(
                          'assets/location@2x.png',
                          'Address',
                          address!,
                          isLargeScreen,
                          rowColors[0],
                        ),
                        const SizedBox(height: 13),
                      ],
                    ),
            ),
    );
  }

  Widget buildInfoRow(
    String iconPath,
    String title,
    String value,
    bool isLargeScreen,
    Color backgroundColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 22),
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
                  blurRadius: 4,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Text container
          Flexible(
            child: Container(
              height: isLargeScreen ? 100 : 60,
              width: isLargeScreen ? 400 : 306,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(3, 3),
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
                      fontFamily: "Poppins",
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
