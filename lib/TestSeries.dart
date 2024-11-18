import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

import 'package:photo_view/photo_view_gallery.dart';

class TestSeriesScreen extends StatefulWidget {
  const TestSeriesScreen({super.key});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  List<dynamic> testSeriesList = [];

  bool _isDownloading = false;
  String _downloadProgress = '';
  final url =
      "https://balvikasyojana.com:8899/test-series/testID?page=2&data_per_page=10";

  // Map to store downloaded file paths for questions and answers
  Map<String, String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    fetchTestSeries();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> fetchTestSeries() async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final newData = json.decode(response.body);
        setState(() {
          testSeriesList.addAll(newData);
        });
      } else {
        throw Exception('Failed to load test series');
      }
    } catch (e) {
      throw Exception('Failed to load test series: $e');
    }
  }

  Future<String> _getDownloadPath(String filename) async {
    Directory? directory;

    if (Platform.isAndroid) {
      try {
        directory =
            await getExternalStorageDirectory(); // App-specific directory
        if (directory == null) {
          throw Exception('Could not access external storage directory');
        }
        return '${directory.path}/$filename';
      } catch (e) {
        throw Exception('Error getting download path: $e');
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$filename';
    }
  }

  Future<void> _downloadFile(String url, String filename) async {
    if (!(await Permission.storage.isGranted)) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = '0%';
    });

    try {
      final filePath = await _getDownloadPath(filename);

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress =
                  '${(received / total * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      // Save the path to the downloaded file
      setState(() {
        downloadedFiles[filename] = filePath;
        _isDownloading = false;
        _downloadProgress = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloaded to $filePath'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _downloadProgress = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _openFile(String filename) async {
    final filePath = downloadedFiles[filename];
    if (filePath != null) {
      // Show the image in PhotoView
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: PhotoViewGallery.builder(
              itemCount: 1,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(filePath)),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(),
            ),
          );
        },
      );

      // Show a SnackBar for debugging purposes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening file: $filePath'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Handle the case when the file is not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File not found'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> containerColors = [
      Colors.lightBlue.shade100,
      Colors.lightGreen.shade100,
      Colors.amber.shade100,
      Colors.pink.shade100,
      Colors.lime.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/dikshaback@2x.png',
                      width: 58,
                      height: 58,
                    ),
                  ),
                  const SizedBox(width: 22),
                  const Text(
                    'Test Series',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isDownloading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      'Downloading: $_downloadProgress',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            testSeriesList.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children:
                        testSeriesList.asMap().entries.map<Widget>((entry) {
                      int index = entry.key;
                      var test = entry.value;

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1,
                          decoration: BoxDecoration(
                            color:
                                containerColors[index % containerColors.length],
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5.0, top: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              test['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              test['subject'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              test['date'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              test['time'],
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        String filename =
                                            'questions_${test['name']}.jpg';
                                        if (downloadedFiles
                                            .containsKey(filename)) {
                                          // Open the file if it already exists
                                          _openFile(filename);
                                        } else {
                                          // Download the file if it doesn't exist
                                          if (test['questions'] != null) {
                                            _downloadFile(
                                              test['questions'],
                                              filename,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Questions URL not available'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Download Questions',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    InkWell(
                                      onTap: () {
                                        String filename =
                                            'answers_${test['name']}.jpg';
                                        if (downloadedFiles
                                            .containsKey(filename)) {
                                          // Open the file if it already exists
                                          _openFile(filename);
                                        } else {
                                          // Download the file if it doesn't exist
                                          if (test['answers'] != null) {
                                            _downloadFile(
                                              test['answers'],
                                              filename,
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Answers URL not available'),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Download Answers',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            TextButton(
                onPressed: () {
                  fetchTestSeries();
                },
                child: const Text('Load More')),
          ],
        ),
      ),
    );
  }
}
