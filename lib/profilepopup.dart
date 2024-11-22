import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';
import 'package:trusir/login_page.dart';

class ProfilePopup extends StatefulWidget {
  const ProfilePopup({super.key});

  @override
  State<ProfilePopup> createState() => _ProfilePopupState();
}

class _ProfilePopupState extends State<ProfilePopup> {
  String? profiles;

  @override
  void initState() {
    super.initState();
    fetchDataAndStoreInSharedPreferences();
    getDataFromSharedPreferences();
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

  Future<void> fetchDataAndStoreInSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phonenum = prefs.getString('phone_number');
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/users/$phonenum'));
      if (response.statusCode == 200) {
        // Parse response
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Store data in SharedPreferences

          print("Data successfully stored in SharedPreferences.");
          setState(() {
            profiles = json.encode(responseData['data']);
          });
          print(profiles);
        } else {
          print("API response indicates failure.");
        }
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getDataFromSharedPreferences() async {
    if (profiles != null) {
      List<dynamic> jsonData = json.decode(profiles!);
      return jsonData.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return profiles != null
        ? Container(
            color: Colors.black54,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Container(
                  height: 500,
                  color: Colors.white,
                  child: FutureBuilder(
                    future: getDataFromSharedPreferences(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else {
                        // Data fetched
                        List<Map<String, dynamic>> data =
                            snapshot.data as List<Map<String, dynamic>>;

                        // Example: Filter only names
                        List<String> names =
                            data.map((item) => item['name'] as String).toList();
                        List<String?> profilepic = data
                            .map((item) => item['profile'] as String?)
                            .toList();
                        List<String?> email = data
                            .map((item) => item['email'] as String?)
                            .toList();
                        return Stack(children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 4), // Leave space for the close button
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 35,
                                      backgroundImage:
                                          AssetImage('assets/rakesh@3x.png'),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Your Name',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'youremail@example.com',
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
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.purple,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                              // Scrollable Profiles List
                              const SizedBox(height: 8),
                              Container(
                                height: 230,
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: ListView.builder(
                                  itemCount: names.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 0),
                                            title: Text(names[index]),
                                            subtitle: Text(email[index] ??
                                                'profile$index@example.com'),
                                            leading: CircleAvatar(
                                              radius: 18,
                                              backgroundImage: NetworkImage(
                                                  profilepic[index] ??
                                                      'https://via.placeholder.com/150'),
                                            )),
                                        Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                          height:
                                              1, // Controls the space above and below the divider
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        logout(context); // Close the popup
                                      },
                                      child: const Center(
                                        // Center the text within the button
                                        child: Text('Sign Out',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            )),
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
                                Navigator.pop(context); // Close the popup
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
          )
        : const Center(child: CircularProgressIndicator());
  }
}
