import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/file_downloader.dart';
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
    FileDownloader.loadDownloadedFiles();
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
      body: doubtsList.isEmpty && !isLoading && initialLoadComplete
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No doubts available',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _buildCreateButton()),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Column(
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
                              final doubt = doubtsList[index];
                              final filename =
                                  '${doubt.course}_your_doubt_${doubt.createdAt}';
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: Image.network(
                                      doubt.image.split(',').first,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      doubt.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Course: ${doubt.course}'),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Status: ${doubt.status}',
                                        ),
                                        Text(
                                            'Posted on: ${formatDate(doubt.createdAt)}'),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      height: 20,
                                      width: 80,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            barrierColor:
                                                Colors.black.withOpacity(0.3),
                                            builder: (BuildContext context) {
                                              List<String> images =
                                                  doubt.image.split(',');
                                              return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                insetPadding:
                                                    const EdgeInsets.all(16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        "Images",
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      GridView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            const NeverScrollableScrollPhysics(),
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 3,
                                                          crossAxisSpacing: 10,
                                                          mainAxisSpacing: 10,
                                                        ),
                                                        itemCount:
                                                            images.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final image =
                                                              images[index];
                                                          return GestureDetector(
                                                            onTap: () {
                                                              FileDownloader
                                                                      .downloadedFiles
                                                                      .containsKey(
                                                                          '${filename}_$index')
                                                                  ? FileDownloader
                                                                      .openFile(
                                                                          '${filename}_$index')
                                                                  : FileDownloader
                                                                      .downloadFile(
                                                                          context,
                                                                          image,
                                                                          '${filename}_$index');
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Expanded(
                                                                  child: Image
                                                                      .network(
                                                                    image,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  '${doubt.title}_$index',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize: 8,
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.open_in_new,
                                          size: 17,
                                        ),
                                        label: const Text(
                                          "Open",
                                          style: TextStyle(fontSize: 10),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          foregroundColor: Colors.blue,
                                        ),
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
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildCreateButton()),
                ],
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
                  builder: (context) => const StudentDoubtScreen()));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 40),
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
