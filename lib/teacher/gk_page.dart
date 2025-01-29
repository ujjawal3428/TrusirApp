import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/teacher/add_gk.dart';

// New DetailPage to show GK details
class GKDetailPage extends StatelessWidget {
  final GK gk;

  const GKDetailPage({super.key, required this.gk});

  @override
  Widget build(BuildContext context) {
    String formatDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    }

    String formatTime(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);
      return formattedTime; // Example: 11:40 PM
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/back_button.png', height: 50),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          gk.title,
          style: const TextStyle(
            color: Color(0xFF48116A),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  gk.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 200, color: Colors.grey);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                gk.title,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                gk.course,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Posted on: ${formatDate(gk.createdAt)} ${formatTime(gk.createdAt)}',
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentGKPage extends StatefulWidget {
  final String studentuserID;
  const StudentGKPage({super.key, required this.studentuserID});

  @override
  State<StudentGKPage> createState() => _StudentGKPageState();
}

class _StudentGKPageState extends State<StudentGKPage> {
  List<GK> gkList = [];
  int page = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialLoadComplete = false;

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }

  String formatTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime; // Example: 11:40 PM
  }

  @override
  void initState() {
    super.initState();
    fetchGks();
  }

  Future<void> fetchGks() async {
    if (!hasMoreData || isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userID');

      final response = await http
          .get(Uri.parse(
              '$baseUrl/tecaher-gks/$userID/${widget.studentuserID}?page=$page&data_per_page=10'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          if (data.isEmpty) {
            hasMoreData = false;
          } else {
            gkList.addAll(data.map((json) => GK.fromJson(json)).toList());
            page++;
          }
        });
      } else {
        throw Exception('Failed to load GKs');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
        initialLoadComplete = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/back_button.png', height: 50)),
                const SizedBox(width: 20),
                const Text(
                  'GK',
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
        backgroundColor: Colors.grey[50],
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: gkList.isEmpty
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  gkList.isEmpty && !isLoading && initialLoadComplete
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "No GK's available",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SingleChildScrollView(
                              child: SizedBox(
                                height: (gkList.length * 130.0).clamp(0,
                                    MediaQuery.of(context).size.height * 0.65),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(10.0),
                                  itemCount: gkList.length,
                                  itemBuilder: (context, index) {
                                    final gk = gkList[index];

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GKDetailPage(gk: gk),
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: double.infinity,
                                          height:
                                              130, // Set a fixed height for the card
                                          child: Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      gk.image,
                                                      width: 75,
                                                      height: 75,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 50,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        Text(
                                                          gk.title,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                "Poppins",
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          'Description: ${gk.course}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                "Poppins",
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          'Posted on: ${formatDate(gk.createdAt)}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "Poppins",
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (isLoading)
                              const CircularProgressIndicator()
                            else if (!hasMoreData && gkList.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No more GKs',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            else if (gkList.isNotEmpty)
                              TextButton(
                                onPressed: fetchGks,
                                child: const Text('Load More'),
                              ),
                          ],
                        ),
                ],
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: -20,
                child: _buildCreateButton(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddGK(
                        studentuserID: widget.studentuserID,
                      )));
        },
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20,
          ),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Image.asset(
              'assets/postbutton.png',
              height: 80.0,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class GK {
  final int id;
  final String title;
  final String course;
  final String image;
  final String createdAt;

  GK({
    required this.id,
    required this.title,
    required this.course,
    required this.image,
    required this.createdAt,
  });

  factory GK.fromJson(Map<String, dynamic> json) {
    return GK(
      id: json['id'],
      title: json['title'],
      course: json['description'],
      image: json['image'],
      createdAt: json['created_at'],
    );
  }
}
