import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TestSeriesScreen extends StatefulWidget {
  const TestSeriesScreen({super.key});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  List<dynamic> testSeriesList = [];

  bool _isDownloading = false;
  String _downloadProgress = '';

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
    const url =
        "https://balvikasyojana.com:8899/test-series/testID"; // Change to your actual API URL
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
    try {
      if (Platform.isAndroid) {
        // Get the download directory path
        directory = Directory('/storage/emulated/0/Download');
        // Create directory if it doesn't exist
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      return '${directory.path}/$filename';
    } catch (e) {
      throw Exception('Error getting download path: $e');
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

      setState(() {
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
            // Header Section
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

            // Download Progress
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

            // FutureBuilder to load the data
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
                                // Test Information
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

                                // Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Questions Button
                                    InkWell(
                                      onTap: () {
                                        if (test['questions'] != null) {
                                          _downloadFile(test['questions'],
                                              'questions_${test['name']}.jpg');
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
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 37,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.indigo.shade900,
                                            width: 1.2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Questions',
                                              style: TextStyle(
                                                color: Colors.indigo.shade900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.file_download_rounded,
                                              color: Colors.indigo.shade900,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),

                                    // Answers Button
                                    InkWell(
                                      onTap: () {
                                        if (test['answers'] != null) {
                                          _downloadFile(test['answers'],
                                              'answers_${test['name']}.jpg');
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
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.4,
                                        height: 37,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.blue.shade900,
                                            width: 1.2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(32),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Answers',
                                              style: TextStyle(
                                                color: Colors.indigo.shade900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.file_download_rounded,
                                              color: Colors.indigo.shade900,
                                              size: 16,
                                            ),
                                          ],
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

            ElevatedButton(
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
