import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/notificationhelper.dart';

class ProgressReportScreen extends StatelessWidget {
  const ProgressReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: const ProgressReportPage(),
    );
  }
}

class ProgressReportPage extends StatefulWidget {
  const ProgressReportPage({super.key});

  @override
  State<ProgressReportPage> createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  List<dynamic> _loadedReports = [];
  bool reportempty = true;
  bool _isDownloading = false;
  String _downloadProgress = '';
  Map<String, String> downloadedFiles = {};
  int page = 1;

  final List<Color> containerColors = [
    Colors.lightBlue.shade50,
    Colors.lightGreen.shade50,
    Colors.amber.shade50,
    Colors.pink.shade50,
    Colors.lime.shade50,
    Colors.orange.shade50,
    Colors.teal.shade50,
  ];

  final List<List<Color>> circleColors = [
    [
      Colors.lightBlue.shade200,
      Colors.lightBlue.shade200,
    ],
    [
      Colors.lightGreen.shade200,
      Colors.lightGreen.shade200,
    ],
    [
      Colors.amber.shade200,
      Colors.amber.shade200,
    ],
    [
      Colors.pink.shade200,
      Colors.pink.shade200,
    ],
    [
      Colors.lime.shade200,
      Colors.lime.shade200,
    ],
    [
      Colors.orange.shade200,
      Colors.orange.shade200,
    ],
    [
      Colors.teal.shade200,
      Colors.teal.shade200,
    ],
  ];

  // Add this method to get colors based on index
  Color getContainerColor(int index) {
    return containerColors[index % containerColors.length];
  }

  List<Color> getCircleColors(int index) {
    return circleColors[index % circleColors.length];
  }

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
    _loadedReports = [];
    reportempty = false;
    _loadInitialReports();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('downloadedReports') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('downloadedReports', jsonEncode(downloadedFiles));
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.isGranted) {
      return;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

      // Skip permissions for Android versions below API 30
      if (androidInfo.version.sdkInt < 30) {
        return;
      }

      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted) {
        return;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.videos,
      ].request();

      if (statuses.values.any((status) => !status.isGranted)) {
        openAppSettings();
      }
    }
  }

  Future<List<dynamic>> fetchProgressReports({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    final response = await http.get(Uri.parse(
        '$baseUrl/progress-report/$userID?page=$page&data_per_page=10'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Failed to load progress reports');
    }
  }

  void _loadMoreReports() async {
    page++;
    try {
      List<dynamic> newReports = await fetchProgressReports(page: page);
      if (mounted) {
        if (newReports.isEmpty) {
          setState(() {
            reportempty = true; // No more data available
          });
        } else {
          setState(() {
            _loadedReports.addAll(newReports);
          });
        }
      }
    } catch (e) {
      print('Error loading more reports: $e');
    }
  }

  void _loadInitialReports() async {
    try {
      List<dynamic> initialReports = await fetchProgressReports();
      if (mounted) {
        setState(() {
          _loadedReports = initialReports;
          reportempty = initialReports.isEmpty;
        });
      }
    } catch (e) {
      print('Error loading initial reports: $e');
    }
  }

  Future<String> _getAppSpecificDownloadPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> _downloadFile(String url, String filename) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = '0%';
    });

    try {
      final filePath = await _getAppSpecificDownloadPath(filename);
      await _requestPermissions();
      await _requestNotificationPermission();
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
        downloadedFiles[filename] = filePath;
        _isDownloading = false;
        _downloadProgress = '';
      });
      await _saveDownloadedFiles();

      showDownloadNotification(filename, filePath);
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

  Future<void> _openFile(String filename) async {
    final filePath = downloadedFiles[filename];
    OpenFile.open(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/back_button.png', height: 50)),
            const SizedBox(width: 20),
            const Text(
              'Progress Report',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontSize: 25,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
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
            _buildCurrentMonthCard(),
            const SizedBox(height: 20),
            _buildPreviousMonthsReports(),
            const SizedBox(height: 20),
            Column(
              children: _loadedReports.isEmpty
                  ? [
                      const Center(child: Text('No Reports Available')),
                    ]
                  : _loadedReports.map((report) {
                      return _buildPreviousMonthCard(
                        subject: report['subject'],
                        date: formatDate(report['created_at']),
                        time: formatTime(report['created_at']),
                        marks: report['marks'],
                        reportUrl: report['report'],
                        cardColors: 'color',
                        index: _loadedReports.indexOf(report),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 20),
            if (_loadedReports.isNotEmpty)
              reportempty
                  ? const Center(
                      child: Text(
                        'No more reports',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  : TextButton(
                      onPressed: _loadMoreReports,
                      child: const Text('Load More...'),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(
        left: 1.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [],
      ),
    );
  }

  Widget _buildCurrentMonthCard() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 5.0,
        right: 18,
        left: 18,
      ),
      child: Container(
        width: 386,
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF48116A),
              Color(0xFFC22054),
            ],
            begin: Alignment.topCenter, // Start the gradient at the top
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC22054).withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(-5, 5),
            ),
            BoxShadow(
              color: const Color(0xFF48116A).withValues(alpha: 0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10.0, right: 10, bottom: 10, top: 0),
          child: Row(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Month',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '24 Jan 2025 - Today',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10.0),
                  child: Image.asset(
                    'assets/listaim@3x.png',
                    width: 100,
                    height: 95,
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
      padding: EdgeInsets.only(top: 10.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'Previous months Reports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
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
    required String cardColors,
    required int index,
  }) {
    String filename = '${subject}_report_$date.jpg';
    bool isDownloaded = downloadedFiles.containsKey(filename);
    List<Color> currentCircleColors = getCircleColors(index);

    return Padding(
      padding: const EdgeInsets.only(left: 18.0, right: 18, top: 0, bottom: 10),
      child: Container(
        width: 386,
        height: 126,
        decoration: BoxDecoration(
          color: getContainerColor(index),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -35,
              child: Image.asset(
                color: currentCircleColors[0],
                'assets/circleleft.png',
                width: 160,
                height: 160,
              ),
            ),
            Positioned(
              bottom: -42,
              right: -40,
              child: Image.asset(
                color: currentCircleColors[0],
                'assets/circleright.png',
                width: 150,
                height: 150,
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10, right: 10, bottom: 10.0),
                child: Container(
                  height: 35,
                  width: 357,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (isDownloaded) {
                        _openFile(filename);
                      } else {
                        _downloadFile(reportUrl, filename);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isDownloaded ? 'Open Report' : 'Download Report',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isDownloaded ? Icons.open_in_new : Icons.download,
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
