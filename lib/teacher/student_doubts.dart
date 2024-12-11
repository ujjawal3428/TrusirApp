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

class StudentDoubtsPage extends StatefulWidget {
  const StudentDoubtsPage({super.key});

  @override
  State<StudentDoubtsPage> createState() => _StudentDoubtsPageState();
}

class _StudentDoubtsPageState extends State<StudentDoubtsPage> {
  late Future<List<Doubt>> doubts;
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    doubts = fetchDoubts();
    _requestNotificationPermission();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('downloadedDoubts') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('downloadedDoubts', jsonEncode(downloadedFiles));
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
      final filePath = await _getAppSpecificDownloadPath(filename);

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
        downloadedFiles[filename] = filePath;
        isDownloading = false;
        downloadProgress = '';
      });
      await _saveDownloadedFiles();
      showDownloadNotification(filename, filePath);
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
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
                'Student Doubts',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: FutureBuilder<List<Doubt>>(
        future: doubts, // Your future for fetching doubts
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
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: doubts.length,
              itemBuilder: (context, index) {
                final doubt = doubts[index];
                final filename = '${doubt.course}_doubt_${doubt.createdAt}.jpg';
                final isDownloaded = downloadedFiles.containsKey(filename);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: SizedBox(
                        height: 60,
                        width: 60,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(doubt.image),
                        ),
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
                          Text(
                            'Status: ${doubt.status}',
                          ),
                          Text('Posted on: ${doubt.createdAt.toLocal()}'),
                        ],
                      ),
                      trailing: Column(
                        children: [
                          SizedBox(
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
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 20,
                            width: 80,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Handle upload action
                              },
                              icon: const Icon(Icons.upload, size: 17),
                              label: const Text("Upload",
                                  style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(0),
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Doubt {
  final int id;
  final String title;
  final String course;
  final String image;
  final DateTime createdAt;
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
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'] ?? 'N/A',
    );
  }
}
