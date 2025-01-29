import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trusir/common/addtestseries.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/file_downloader.dart';

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
  String answerFileName = '';
  String questionFileName = '';

  @override
  void initState() {
    super.initState();
    fetchTestSeries();
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
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No tests available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            if (testSeriesList.isNotEmpty)
              Column(
                children: testSeriesList.map<Widget>((test) {
                  int index = testSeriesList.indexOf(test);
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      left: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,

                      decoration: BoxDecoration(
                        color: containerColors[index % containerColors.length],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildTestCard(
                          test, index), // Encapsulated card logic
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 10),
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
    return Padding(
      padding:
          const EdgeInsets.only(top: 10.0, left: 15, right: 15, bottom: 10),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formatDate(test['created_at']),
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                        Text(formatTime(test['created_at']),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 14)),
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
                  testName: test['test_name'],
                  label: 'Question',
                  isQuestion: true,
                  fileName: 'question_${test['test_name']}',
                  downloadFile: test['question']),
              const SizedBox(width: 27),
              _buildDownloadButton(
                  testName: test['test_name'],
                  label: 'Answer',
                  isQuestion: false,
                  fileName: 'answer_${test['test_name']}',
                  downloadFile: test['answer']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton({
    required String label,
    required bool isQuestion,
    required String testName,
    required String fileName,
    required String downloadFile,
  }) {
    return InkWell(
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (BuildContext context) {
          List<String> images = downloadFile.split(',');
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    physics: const NeverScrollableScrollPhysics(),
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
                          setState(() {
                            if (isQuestion) {
                              questionFileName = '${fileName}_$index';
                            } else {
                              answerFileName = '${fileName}_$index';
                            }
                          });
                          FileDownloader.downloadedFiles
                                  .containsKey('${fileName}_$index')
                              ? FileDownloader.openFile('${fileName}_$index')
                              : FileDownloader.downloadFile(
                                  context, image, '${fileName}_$index');
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${testName}_$index',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
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
      ),
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
                Icons.open_in_new,
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
