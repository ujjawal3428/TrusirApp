import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/api.dart';

class Notice {
  final String noticetitle;
  final String date;
  final String notice;

  Notice({
    required this.noticetitle,
    required this.notice,
    required this.date,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      noticetitle: json['notice_title'],
      notice: json['notice'],
      date: json['posted_on'],
    );
  }
}

class TeacherNoticeScreen extends StatefulWidget {
  const TeacherNoticeScreen({super.key});

  @override
  State<TeacherNoticeScreen> createState() => _TeacherNoticeScreenState();
}

class _TeacherNoticeScreenState extends State<TeacherNoticeScreen> {
  List<Notice> notices = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  final apiBase = '$baseUrl/my-notice';

  Future<void> fetchNotices({int page = 1}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    final url = '$apiBase/$userID?page=$page&data_per_page=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        if (page == 1) {
          // Initial fetch
          notices = data.map((json) => Notice.fromJson(json)).toList();
        } else {
          // Append new data
          notices.addAll(data.map((json) => Notice.fromJson(json)));
        }

        isLoading = false;
        isLoadingMore = false;

        // Check if more data is available
        if (data.isEmpty) {
          hasMore = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      throw Exception('Failed to load notices');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  final List<Color> cardColors = [
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
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
              const SizedBox(width: 5),
              const Text(
                'Notice',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 0),
              child: Column(
                children: [
                  ...notices.asMap().entries.map((entry) {
                    int index = entry.key;
                    Notice notice = entry.value;

                    // Cycle through colors using the modulus operator
                    Color cardColor = cardColors[index % cardColors.length];

                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 10, top: 20, right: 10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 386,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: cardColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 55, top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notice.noticetitle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Posted on : ${notice.date}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    notice.notice,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Image.asset(
                              'assets/bell.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (hasMore)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: () {
                                setState(() {
                                  isLoadingMore = true;
                                  currentPage++;
                                });
                                fetchNotices(page: currentPage);
                              },
                              child: const Text('Load More...'),
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