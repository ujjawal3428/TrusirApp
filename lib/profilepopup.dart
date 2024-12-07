import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';
import 'package:trusir/login_page.dart';
import 'package:trusir/my_profile.dart';
import 'package:trusir/popup_splash_screen.dart';

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
    String? phonenum = prefs.getString('phone_number');
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/users/$phonenum'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            profiles = json.encode(responseData['data']);
            if (responseData['data'].isNotEmpty && selectedProfile == null) {
              selectedProfile = responseData['data'][0];
              prefs.setString('selectedProfile', json.encode(profile));
            }
          });
        }
      }
    } catch (e) {
      print("Error occurred: $e");
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
                    height: 500,
                    color: Colors.white,
                    child: FutureBuilder(
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
                              snapshot.data as List<Map<String, dynamic>>;

                          return Stack(children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // Top Section
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundImage:
                                            selectedProfile?['profile'] != null
                                                ? NetworkImage(
                                                    selectedProfile!['profile'])
                                                : const AssetImage(
                                                        'assets/rakesh@3x.png')
                                                    as ImageProvider,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              selectedProfile?['name'] ??
                                                  'Your Name',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Class: ${selectedProfile?['class']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            SizedBox(
                                              height: 25,
                                              width: 80,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const MyProfileScreen()),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.purple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10,
                                  ),
                                  child: Container(
                                    height: 230,
                                    width: double.infinity,
                                    color: Colors.grey[100],
                                    child: ListView.builder(
                                      itemCount: data.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 0),
                                              title: Text(data[index]['name']),
                                              subtitle: Text(
                                                  'Class: ${data[index]['class']}'),
                                              leading: CircleAvatar(
                                                radius: 18,
                                                backgroundImage: data[index]
                                                            ['profile'] !=
                                                        null
                                                    ? NetworkImage(
                                                        data[index]['profile'])
                                                    : const NetworkImage(
                                                        'https://via.placeholder.com/150'),
                                              ),
                                              onTap: () async {
                                                setState(() {
                                                  selectedProfile = data[index];
                                                });
                                                await saveSelectedProfile(
                                                    selectedProfile!);
                                              },
                                            ),
                                            Divider(
                                              color: Colors.grey[300],
                                              thickness: 1,
                                              height: 1,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Container(
                                        width: 80,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            logout(context);
                                          },
                                          child: const Center(
                                            child: Text('Sign Out',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12,
                                                )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 2,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ]);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        : const Scaffold(
            backgroundColor: Colors.white30,
            body: Center(child: CircularProgressIndicator()));
  }
}
