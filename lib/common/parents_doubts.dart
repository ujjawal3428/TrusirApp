import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/file_downloader.dart';

class ParentsDoubtsPage extends StatefulWidget {
  const ParentsDoubtsPage({super.key});

  @override
  State<ParentsDoubtsPage> createState() => _ParentsDoubtsPageState();
}

class _ParentsDoubtsPageState extends State<ParentsDoubtsPage> {
  List<Doubt> doubtsList = [];
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};
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

  String formatTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime; // Example: 11:40 PM
  }

  Future<void> fetchDoubts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userID');
    if (!hasMoreData || isLoading) return; // Prevent unnecessary calls

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    try {
      final response = await http
          .get(Uri.parse(
              '$baseUrl/api/view-doubts/$userId/parent?page=$page&data_per_page=10'))
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
      backgroundColor: Colors.grey[50],
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
                'Parents Doubts',
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
      body: doubtsList.isEmpty && !isLoading && initialLoadComplete
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No doubts available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: doubtsList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final doubt = doubtsList[index];
                      final filename =
                          '${doubt.course}_parent_doubt_${doubt.createdAt}';

                      // Determine file extension for this item

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    barrierColor: Colors.black.withOpacity(0.3),
                                    builder: (BuildContext context) {
                                      List<String> images =
                                          doubt.image.split(',');
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Images",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
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
                                                itemCount: images.length,
                                                itemBuilder: (context, index) {
                                                  final image = images[index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      FileDownloader
                                                              .downloadedFiles
                                                              .containsKey(
                                                                  '${filename}_$index')
                                                          ? FileDownloader.openFile(
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
                                                          child: Image.network(
                                                            image,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          '${doubt.title}_$index',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 8,
                                                            color: Colors.blue,
                                                          ),
                                                          overflow: TextOverflow
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
      course: json['description'],
      image: json['image'],
      createdAt: json['created_at'],
      status: json['status'] ?? 'N/A',
    );
  }
}
