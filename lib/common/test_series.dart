import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/addtestseries.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/notificationhelper.dart';

class TestSeriesScreen extends StatefulWidget {
  final String? userID;
  const TestSeriesScreen({super.key, required this.userID});

  @override
  State<TestSeriesScreen> createState() => _TestSeriesScreenState();
}

class _TestSeriesScreenState extends State<TestSeriesScreen> {
  List<dynamic> testSeriesList = [];
  bool hasData = true;
  final url = "$baseUrl/api/test-series";
  bool hasMoreData = true;
  bool isLoading = false;
  bool initialLoadComplete = false;
  int page = 1;

  // Map to store downloaded file paths for questions and answers
  Map<String, String> downloadedFiles = {};

  @override
  void initState() {
    super.initState();
    fetchTestSeries();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('downloadedTests') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('downloadedTests', jsonEncode(downloadedFiles));
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

  Future<void> fetchTestSeries() async {
    if (!hasMoreData || isLoading) return; // Prevent unnecessary calls
    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });
    try {
      final response = await http
          .get(Uri.parse('$url/${widget.userID}?page=$page&data_per_page=10'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final newData = json.decode(response.body);
        setState(() {
          if (newData.isEmpty) {
            hasMoreData = false; // No more data available
          } else {
            testSeriesList.addAll(newData);
            page++; // Increment page for next fetch
          }
        });
      } else {
        throw Exception('Failed to load test series');
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

  Future<String> _getAppSpecificDownloadPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }

  Future<void> _downloadFile(String url, String filename) async {
    try {
      // Infer file extension from the URL or content type
      String fileExtension = _getFileExtensionFromUrl(url);
      String finalFilename = '$filename$fileExtension';

      final filePath = await _getAppSpecificDownloadPath(finalFilename);
      await _requestPermissions();
      await _requestNotificationPermission();
      final dio = Dio();
      await dio.download(url, filePath);

      setState(() {
        downloadedFiles[finalFilename] = filePath;
        downloadedFiles[filename] = filePath;
      });
      await _saveDownloadedFiles();
      showDownloadNotification(finalFilename, filePath);
    } catch (e) {
      setState(() {});

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
    final extension = url.split('.').last;
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

  Future<void> _openFile(String filename) async {
    final filePath = downloadedFiles[filename];
    OpenFile.open(filePath);
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
          child: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text(
                'Test Series',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Addtestseries(userID: widget.userID!),
            if (testSeriesList.isEmpty && !isLoading && initialLoadComplete)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No tests available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (testSeriesList.isNotEmpty)
              Column(
                children: testSeriesList.map<Widget>((test) {
                  int index = testSeriesList.indexOf(test);
                  return Padding(
                    padding:
                        const EdgeInsets.only(right: 16, left: 16, top: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,

                      decoration: BoxDecoration(
                        color: containerColors[index % containerColors.length],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: _buildTestCard(
                          test, index), // Encapsulated card logic
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (!hasMoreData && testSeriesList.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No more tests',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            else if (testSeriesList.isNotEmpty)
              TextButton(
                onPressed: fetchTestSeries,
                child: const Text('Load More'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(dynamic test, int index) {
    // Encapsulate your test card logic here for cleaner code
    String questionFilename = 'question_${test['test_name']}';
    String answerFilename = 'answer_${test['test_name']}';
    bool isQuestionDownloaded = downloadedFiles.containsKey(questionFilename);
    bool isAnswerDownloaded = downloadedFiles.containsKey(answerFilename);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['test_name'],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(test['subject'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(test['date'],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400)),
                        Text(test['time'],
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDownloadButton(
                  label: 'Question',
                  isDownloaded: isQuestionDownloaded,
                  onDownload: () =>
                      _downloadFile(test['question'], questionFilename),
                  inDownload: () => _openFile(questionFilename)),
              const SizedBox(width: 27),
              _buildDownloadButton(
                  label: 'Answer',
                  isDownloaded: isAnswerDownloaded,
                  onDownload: () =>
                      _downloadFile(test['answer'], answerFilename),
                  inDownload: () => _openFile(answerFilename)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required bool isDownloaded,
    required VoidCallback inDownload,
    required VoidCallback onDownload,
  }) {
    return InkWell(
      onTap: isDownloaded ? inDownload : onDownload,
      child: Container(
        width: 135,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.indigo.shade900, width: 1.2),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.indigo.shade900, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Icon(
                isDownloaded ? Icons.open_in_new : Icons.file_download_rounded,
                color: Colors.indigo.shade900,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
