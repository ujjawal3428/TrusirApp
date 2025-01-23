import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';

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
      noticetitle: json['title'],
      notice: json['description'],
      date: json['posted_on'],
    );
  }
}

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  List<Notice> notices = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  final apiBase = '$baseUrl/api/my-notice';

  Future<void> fetchNotices({int page = 1}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    final url = '$apiBase/$userID?page=$page&data_per_page=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        if (page == 1) {
          notices = data.map((json) => Notice.fromJson(json)).toList();
        } else {
          notices.addAll(data.map((json) => Notice.fromJson(json)));
        }

        isLoading = false;
        isLoadingMore = false;

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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', 
                    height: constraints.maxWidth > 600 ? 50 : 30,
                  ),
                ),
                SizedBox(width: constraints.maxWidth > 600 ? 20 : 10),
                Text(
                  'Notice',
                  style: TextStyle(
                    color: const Color(0xFF48116A),
                    fontSize: constraints.maxWidth > 600 ? 25 : 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            );
          },
        ),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : notices.isEmpty
              ? const Center(
                  child: Text(
                    "No Notices Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth > 1200 
                              ? 1200 
                              : constraints.maxWidth > 600 
                                ? 800 
                                : constraints.maxWidth,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth > 600 ? 20 : 10,
                              vertical: 15,
                            ),
                            child: Column(
                              children: [
                                ...notices.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Notice notice = entry.value;

                                  Color cardColor = 
                                    cardColors[index % cardColors.length];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 20,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: constraints.maxWidth > 600 
                                          ? 600 
                                          : constraints.maxWidth - 40,
                                      ),
                                      child: Card(
                                        color: cardColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 15,
                                                  top: 5,
                                                ),
                                                child: Image.asset(
                                                  'assets/bell.png',
                                                  width: 36,
                                                  height: 36,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: 
                                                    CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      notice.noticetitle,
                                                      style: TextStyle(
                                                        fontSize: constraints.maxWidth > 600 ? 18 : 16,
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      'Posted on : ${notice.date}',
                                                      style: TextStyle(
                                                        fontSize: constraints.maxWidth > 600 ? 13 : 11,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      notice.notice,
                                                      style: TextStyle(
                                                        fontSize: constraints.maxWidth > 600 ? 13 : 11,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                hasMore
                                  ? Padding(
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
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      child: Text('No more Notices'),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}