import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/delete.dart';
import 'package:trusir/student/student_doubt.dart';

class YourDoubtPage extends StatefulWidget {
  const YourDoubtPage({super.key});

  @override
  State<YourDoubtPage> createState() => _YourDoubtPageState();
}

class _YourDoubtPageState extends State<YourDoubtPage> {
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};
  List<Doubt> doubtsList = [];
  String extension = '';
  int page = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    fetchDoubts();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }

  Future<void> fetchDoubts() async {
    if (!hasMoreData || isLoading) return; // Prevent unnecessary calls

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userID = prefs.getString('userID');

      final response = await http
          .get(Uri.parse(
              '$baseUrl/api/view-doubts/$userID/student?page=$page&data_per_page=10'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          if (data.isEmpty) {
            hasMoreData = false; // No more data available
          } else {
            doubtsList
                .addAll(data.map((json) => Doubt.fromJson(json)).toList());
            page++; // Increment page for next fetch
          }
        });
      } else {
        throw Exception('Failed to load doubts');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false; // Stop loading indicator
        initialLoadComplete = true; // Mark the initial load as complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                'Your Doubts',
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
      body: Stack(
        children: [
          doubtsList.isEmpty && !isLoading && initialLoadComplete
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No doubts available',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        child: SizedBox(
                          height: (doubtsList.length * 130.0).clamp(
                              0, MediaQuery.of(context).size.height * 0.65),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10.0),
                            itemCount: doubtsList.length,
                            itemBuilder: (context, index) {
                              final gk = doubtsList[index];

                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  YourDoubtDetailPage(gk: gk),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    gk.image.split(',').first,
                                                    width: 75,
                                                    height: 75,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return const Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 50);
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
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          fontFamily: "Poppins",
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Description: ${gk.course}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: "Poppins",
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        'Posted on: ${gk.createdAt}',
                                                        style: TextStyle(
                                                          fontFamily: "Poppins",
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
                                        )),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                          onPressed: () {
                                            DeleteUtility.deleteItem(
                                                'doubt', gk.id);
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.redAccent,
                                          )))
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      if (isLoading)
                        const CircularProgressIndicator()
                      else if (!hasMoreData && doubtsList.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No more Doubts',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        )
                      else if (doubtsList.isNotEmpty)
                        TextButton(
                          onPressed: fetchDoubts,
                          child: const Text('Load More'),
                        ),
                    ],
                  ),
                ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildCreateButton()),
        ],
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
                  builder: (context) => const StudentDoubtScreen()));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
          child: Image.asset(
            'assets/create_doubt.png',
            width: double.infinity,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class Doubt {
  final int id;
  final String title;
  final String course;
  final String image;
  final String createdAt;
  final String status;

  Doubt({
    required this.id,
    required this.title,
    required this.course,
    required this.image,
    required this.createdAt,
    required this.status,
  });

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      image: json['image'],
      createdAt: json['created_at'],
      status: json['status'] ?? 'N/A',
    );
  }
}

class YourDoubtDetailPage extends StatelessWidget {
  final Doubt gk;

  const YourDoubtDetailPage({super.key, required this.gk});

  @override
  Widget build(BuildContext context) {
    String formatDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    }

    List<String> imageUrls = gk.image.split(',').map((e) => e.trim()).toList();

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
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Adjust columns as needed
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Title: ${gk.title}',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Course: ${gk.course}',
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Posted on: ${formatDate(gk.createdAt)}',
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
