import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/notificationhelper.dart';
import 'package:trusir/student/student_doubt.dart';

class YourDoubtPage extends StatefulWidget {
  const YourDoubtPage({super.key});

  @override
  State<YourDoubtPage> createState() => _YourDoubtPageState();
}

class _YourDoubtPageState extends State<YourDoubtPage> {
  late Future<List<Doubt>> doubts;
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};
  String extension = '';

  @override
  void initState() {
    super.initState();
    doubts = fetchDoubts();
    _requestNotificationPermission();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('yourDownloadedDoubts') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('yourDownloadedDoubts', jsonEncode(downloadedFiles));
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

  Future<String> _getAppSpecificDownloadPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> _downloadFile(String url, String filename) async {
    setState(() {
      _requestPermissions();
      isDownloading = true;
      downloadProgress = '0%';
    });

    try {
      // Infer file extension from the URL or content type
      String fileExtension = _getFileExtensionFromUrl(url);
      String finalFilename = '$filename$fileExtension';

      final filePath = await _getAppSpecificDownloadPath(finalFilename);

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress =
                  '${(received / total * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      setState(() {
        downloadedFiles[finalFilename] = filePath;
        downloadedFiles[filename] = filePath;
        isDownloading = false;
        downloadProgress = '';
      });
      await _saveDownloadedFiles();
      showDownloadNotification(finalFilename, filePath);
    } catch (e) {
      setState(() {
        isDownloading = false;
        downloadProgress = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

// Function to infer file extension from the URL
  String _getFileExtensionFromUrl(String url) {
    setState(() {
      extension = url.split('.').last;
    });
    if (extension == 'pdf') {
      return '.pdf';
    } else if (extension == 'docx') {
      return '.docx';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      return '.jpg';
    } else if (extension == 'png') {
      return '.png';
    }
    return ''; // Default, in case we can't determine the extension
  }

  IconData _getIconForFile(String url) {
    extension = url.split('.').last;
    if (extension == 'pdf') {
      return Icons.picture_as_pdf;
    } else if (extension == 'docx' || extension == 'doc') {
      return Icons.description;
    } else if (extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'png') {
      return Icons.image;
    } else {
      return Icons.insert_drive_file; // Default icon for unknown file types
    }
  }

  Color _getIconColorForFile(String url) {
    extension = url.split('.').last;
    if (extension == 'pdf') {
      return Colors.red;
    } else if (extension == 'docx' || extension == 'doc') {
      return Colors.blue;
    } else if (extension == 'png' ||
        extension == 'jpg' ||
        extension == 'jpeg') {
      return Colors.green;
    } else {
      return Colors.grey; // Default color for unknown file types
    }
  }

  Future<void> _openFile(String filename) async {
    final filePath = downloadedFiles[filename];
    OpenFile.open(filePath);
  }

  Future<List<Doubt>> fetchDoubts() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');

    final response = await http.get(
      Uri.parse(
          'https://balvikasyojana.com:8899/api/view-doubts/$userID/student'), // Replace with your API endpoint
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Doubt.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doubts');
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
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF48116A),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 5),
              const Text(
                'Your Doubts',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      backgroundColor: Colors.grey.shade300,
      body: Column(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.79,
              child: FutureBuilder<List<Doubt>>(
                future: doubts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No doubts available.'));
                  } else {
                    final doubts = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: doubts.length,
                      itemBuilder: (context, index) {
                        final doubt = doubts[index];
                        final filename =
                            '${doubt.course}_your_doubt_${doubt.createdAt}';
                        final isDownloaded =
                            downloadedFiles.containsKey(filename);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Icon(
                                _getIconForFile(doubt.image),
                                color: _getIconColorForFile(doubt.image),
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
                                  Text('Posted on: ${doubt.createdAt}'),
                                ],
                              ),
                              trailing: SizedBox(
                                height: 20,
                                width: 80,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (isDownloaded) {
                                      _openFile(filename);
                                    } else {
                                      _downloadFile(doubt.image, filename);
                                    }
                                  },
                                  icon: Icon(
                                    isDownloaded
                                        ? Icons.open_in_new
                                        : Icons.download,
                                    size: 17,
                                  ),
                                  label: Text(
                                    isDownloaded ? "Open" : "Download",
                                    style: const TextStyle(fontSize: 10),
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
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StudentDoubtScreen()));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
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
                      'Create Doubt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
      createdAt:
          DateTime.parse(json['created_at']).toIso8601String().split('T')[0],
      status: json['status'] ?? 'N/A',
    );
  }
}
