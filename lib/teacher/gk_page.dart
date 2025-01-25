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
import 'package:trusir/common/api.dart';
import 'package:trusir/common/notificationhelper.dart';
import 'package:trusir/teacher/add_gk.dart';

class StudentGKPage extends StatefulWidget {
  final String studentuserID;
  const StudentGKPage({super.key, required this.studentuserID});

  @override
  State<StudentGKPage> createState() => _StudentGKPageState();
}

class _StudentGKPageState extends State<StudentGKPage> {
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};
  List<GK> gkList = [];
  String extension = '';
  int page = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    fetchGks();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('yourDownloadedGKs') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('yourDownloadedGKs', jsonEncode(downloadedFiles));
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
      isDownloading = true;
      downloadProgress = '0%';
    });

    try {
      // Infer file extension from the URL or content type
      String fileExtension = _getFileExtensionFromUrl(url);
      String finalFilename = '$filename$fileExtension';

      final filePath = await _getAppSpecificDownloadPath(finalFilename);
      await _requestPermissions();
      await _requestNotificationPermission();
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

  Widget _buildFilePreview(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      // Display the image preview
      return Image.network(
        fileUrl,
        width: 50,
        height: 50,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey, size: 50);
        },
      );
    } else {
      // Display an icon for non-image file types
      return Icon(
        _getIconForFile(fileUrl),
        size: 50,
        color: _getIconColorForFile(fileUrl),
      );
    }
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

  Future<void> fetchGks() async {
    if (!hasMoreData || isLoading) return; // Prevent unnecessary calls

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
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
            hasMoreData = false; // No more data available
          } else {
            gkList.addAll(data.map((json) => GK.fromJson(json)).toList());
            page++; // Increment page for next fetch
          }
        });
      } else {
        throw Exception('Failed to load GKs');
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
                                    final filename =
                                        '${gk.course}_gk_${gk.createdAt}';
                                    final isDownloaded =
                                        downloadedFiles.containsKey(filename);

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.shade100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                          leading: _buildFilePreview(gk.image),
                                          title: Text(
                                            gk.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Description: ${gk.course}'),
                                              const SizedBox(height: 2),
                                              Text(
                                                  'Posted on: ${gk.createdAt}'),
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
                                                  _downloadFile(
                                                      gk.image, filename);
                                                }
                                              },
                                              icon: Icon(
                                                isDownloaded
                                                    ? Icons.open_in_new
                                                    : Icons.download,
                                                size: 17,
                                              ),
                                              label: Text(
                                                isDownloaded
                                                    ? "Open"
                                                    : "Download",
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.all(0),
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
                bottom: 0,
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
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              'assets/postbutton.png',
              height: 70.0,
              fit: BoxFit.contain,
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
      createdAt:
          DateTime.parse(json['created_at']).toIso8601String().split('T')[0],
    );
  }
}
