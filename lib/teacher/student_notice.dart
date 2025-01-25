import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/add_notice.dart';

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

class StudentNoticeScreen extends StatefulWidget {
  final String userID;
  const StudentNoticeScreen({super.key, required this.userID});

  @override
  State<StudentNoticeScreen> createState() => _StudentNoticeScreenState();
}

class _StudentNoticeScreenState extends State<StudentNoticeScreen> {
  List<Notice> notices = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;
  final apiBase = '$baseUrl/api/my-notice';

  Future<void> fetchNotices({int page = 1}) async {
    final url = '$apiBase/${widget.userID}?page=$page&data_per_page=10';
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
    Colors.blue.shade300,
    Colors.yellow.shade300,
    Colors.pink.shade300,
    Colors.green.shade300,
    Colors.purple.shade300,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                const Text(
                  'Notice',
                  style: TextStyle(
                    color: Color(0xFF48116A),
                    fontSize: 25,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          toolbarHeight: 70,
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : notices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No Notices Available",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              _buildAddNoticeButton(context),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 15,
                              top: 0,
                            ),
                            child: Column(
                              children: [
                                ...notices.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Notice notice = entry.value;

                                  // Cycle through colors using the modulus operator
                                  Color cardColor =
                                      cardColors[index % cardColors.length];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      top: 20,
                                      right: 10,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 386,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: cardColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 55, top: 10, bottom: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                hasMore
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: isLoadingMore
                                            ? const CircularProgressIndicator()
                                            : TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isLoadingMore = true;
                                                    currentPage++;
                                                  });
                                                  fetchNotices(
                                                      page: currentPage);
                                                },
                                                child:
                                                    const Text('Load More...'),
                                              ),
                                      )
                                    : const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 20),
                                        child: Text('No more Notices'),
                                      ),
                              ],
                            ),
                          ),
                        ),
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: _buildAddNoticeButton(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNoticeButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoticePage(
                userID: widget.userID,
              ),
            ),
          );
        },
        child: Image.asset(
          'assets/add_notice.png',
          width: double.infinity,
          height: 70,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
