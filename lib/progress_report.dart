import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: const ProgressReportPage(),
      ),
    );
  }
}

class ProgressReportPage extends StatefulWidget {
  const ProgressReportPage({super.key});

  @override
  State<ProgressReportPage> createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  late Future<List<dynamic>> _reports;
  List<dynamic> _loadedReports = []; // List to store loaded reports
  bool _isDownloading = false;
  String _downloadProgress = '';
  Map<String, String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    _reports = fetchProgressReports();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<List<dynamic>> fetchProgressReports() async {
    final response = await http.get(
        Uri.parse('https://balvikasyojana.com:8899/progress-report/testID'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load progress reports');
    }
  }

  void _loadMoreReports() async {
    try {
      // Fetch the same data again
      List<dynamic> newReports = await fetchProgressReports();
      setState(() {
        // Append the new reports to the existing list
        _loadedReports.addAll(newReports);
      });
    } catch (e) {
      print('Error loading more reports: $e');
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
    return SingleChildScrollView(
      child: Column(
        children: [
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
          _buildBackButton(context),
          const SizedBox(height: 20),
          _buildCurrentMonthCard(),
          const SizedBox(height: 20),
          _buildPreviousMonthsReports(),
          const SizedBox(height: 20),
          FutureBuilder<List<dynamic>>(
            future: _reports,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final reports = snapshot.data!;
                // Store the fetched data in _loadedReports
                _loadedReports = reports;
                return Column(
                  children: _loadedReports
                      .map((report) => _buildPreviousMonthCard(
                            subject: report['subject'],
                            date: report['date'],
                            time: report['time'],
                            marks: report['marks'],
                            reportUrl: report['report'],
                          ))
                      .toList(),
                );
              }
            },
          ),
          TextButton(
            onPressed:
                _loadMoreReports, // Call the _loadMoreReports method when clicked
            child: const Text('Load More...'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
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
            'Progress Report',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthCard() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 386,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFC22054),
              Color(0xFF48116A),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC22054).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(-5, 5),
            ),
            BoxShadow(
              color: const Color(0xFF48116A).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Month',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '24 Jan 2025 - Today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InkWell(
                        child: Container(
                          width: 102,
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF045C19),
                                Color(0xFF77D317),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'view report',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Image.asset(
                    'assets/listaim@3x.png',
                    width: 108,
                    height: 115,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousMonthsReports() {
    return const Padding(
      padding: EdgeInsets.only(left: 60, top: 20.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Previous months Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPreviousMonthCard({
    required String subject,
    required String date,
    required String time,
    required String marks,
    required String reportUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 386,
        height: 136,
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -35,
              child: Image.asset(
                'assets/circleleft.png',
                width: 160,
                height: 160,
              ),
            ),
            Positioned(
              bottom: -42,
              right: -40,
              child: Image.asset(
                'assets/circleright.png',
                width: 160,
                height: 160,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Marks Obtained: $marks',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Date: $date',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  height: 48,
                  width: 357,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      String filename = '${subject}_report_$date.jpg';

                      if (downloadedFiles.containsKey(filename)) {
                        _openFile(filename);
                      } else {
                        _downloadFile(reportUrl, filename);
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Download Report',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.download,
                          color: Colors.black,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
