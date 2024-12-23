import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/login_page.dart';
import 'package:trusir/student/my_profile.dart';
import 'package:trusir/student/popup_splash_screen.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup({super.key});

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  String? profiles;
  Map<String, dynamic>? selectedProfile;

  @override
  void initState() {
    super.initState();
    fetchDataAndStoreInSharedPreferences({});
    loadSelectedProfile();
  }

  Future<void> loadSelectedProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedProfile = prefs.getString('selectedProfile');
    if (savedProfile != null) {
      setState(() {
        selectedProfile = json.decode(savedProfile);
      });
    }
  }

  Future<void> saveSelectedProfile(Map<String, dynamic> profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedProfile', json.encode(profile));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PopUpSplashScreen(userId: selectedProfile!['userID']),
      ),
      (route) => false,
    );
  }

  Future<void> fetchDataAndStoreInSharedPreferences(
      Map<String, dynamic> profile) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedProfiles = prefs.getString('profiles');
    if (savedProfiles != null) {
      setState(() {
        profiles = savedProfiles;
      });
    } else {
      String? phonenum = prefs.getString('phone_number');
      try {
        final response =
            await http.get(Uri.parse('$baseUrl/api/users/$phonenum'));
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            setState(() {
              profiles = json.encode(responseData['data']);
              prefs.setString('profiles', profiles!);
              if (responseData['data'].isNotEmpty && selectedProfile == null) {
                selectedProfile = responseData['data'][0];
                prefs.setString(
                    'selectedProfile', json.encode(selectedProfile));
              }
            });
          }
        }
      } catch (e) {
        print("Error occurred: $e");
      }
    }
  }

  Future<List<Map<String, dynamic>>> getProfiles() async {
    if (profiles != null) {
      return (json.decode(profiles!) as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    return [];
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TrusirLoginPage()),
      (route) => false,
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'profile_image',
            child: CircleAvatar(
              radius: 40,
              backgroundImage: selectedProfile?['profile'] != null
                  ? NetworkImage(selectedProfile!['profile'])
                  : const AssetImage('assets/rakesh@3x.png') as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedProfile?['name'] ?? 'Your Name',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Subject: ${selectedProfile?['subject'] ?? 'N/A'}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Class: ${selectedProfile?['class'] ?? 'N/A'}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return profiles != null
        ? Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              color: Colors.black54,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildProfileHeader(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: getProfiles(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text("Error: ${snapshot.error}"));
                                } else {
                                  List<Map<String, dynamic>> data =
                                      snapshot.data ?? [];
                                  double containerHeight =
                                      (data.length * 70.0).clamp(0, 300);

                                  return SizedBox(
                                    height: containerHeight,
                                    child: ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 15,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              leading: CircleAvatar(
                                                radius: 25,
                                                backgroundImage: data[index]
                                                            ['profile'] !=
                                                        null
                                                    ? NetworkImage(
                                                        data[index]['profile'])
                                                    : const NetworkImage(
                                                        'https://via.placeholder.com/150'),
                                              ),
                                              title: Text(
                                                data[index]['name'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Class: ${data[index]['class']}',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                  Text(
                                                    'Subject: ${data[index]['subject']}',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
                                                  ),
                                                ],
                                              ),
                                              onTap: () async {
                                                setState(() {
                                                  final selected =
                                                      data.removeAt(index);
                                                  data.insert(0, selected);
                                                  selectedProfile = selected;
                                                });

                                                final SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setString('profiles',
                                                    json.encode(data));
                                                prefs.setString(
                                                    'selectedProfile',
                                                    json.encode(
                                                        selectedProfile!));

                                                await saveSelectedProfile(
                                                    selectedProfile!);
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  logout(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  foregroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        : const Scaffold(
            backgroundColor: Colors.white30,
            body: Center(child: CircularProgressIndicator()),
          );
  }
}
