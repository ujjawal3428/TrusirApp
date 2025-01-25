import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/notificationhelper.dart';

class StudentDoubtsPage extends StatefulWidget {
  final String userID;
  const StudentDoubtsPage({super.key, required this.userID});

  @override
  State<StudentDoubtsPage> createState() => _StudentDoubtsPageState();
}

class _StudentDoubtsPageState extends State<StudentDoubtsPage> {
  List<Doubt> doubtsList = [];
  bool isDownloading = false;
  String downloadProgress = '';
  Map<String, String> downloadedFiles = {};
  String extension = '';
  int page = 1;
  bool isLoading = false;
  bool hasMoreData = true;
  bool initialLoadComplete = false;
  int? selectedDoubtId;
  String imageUrl = '';
  bool isimageUploading = false;
  bool isSolutionUploading = false;

  @override
  void initState() {
    super.initState();
    fetchDoubts();
    _loadDownloadedFiles();
  }

  Future<String> uploadImageSelective(XFile imageFile) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri);

    // Add the image file to the request
    request.files
        .add(await http.MultipartFile.fromPath('photo', imageFile.path));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 201) {
      // Parse the response to extract the download URL
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (jsonResponse.containsKey('download_url')) {
        return jsonResponse['download_url'] as String;
      } else {
        print('Download URL not found in the response.');
        return 'null';
      }
    } else {
      print('Failed to upload image: ${response.statusCode}');
      return 'null';
    }
  }

  Future<void> handleImageSelection(ImageSource source) async {
    setState(() {
      isimageUploading = true;
    });
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) {
        Fluttertoast.showToast(msg: 'No image selected.');
        setState(() {
          isimageUploading = false;
        });
        return;
      }

      // Compress the image
      final compressedImage = await compressImage(File(pickedFile.path));

      if (compressedImage == null) {
        Fluttertoast.showToast(msg: 'Failed to compress image.');
        setState(() {
          isimageUploading = false;
        });
        return;
      }

      // Upload the image and get the path
      final newuploadedPath =
          await uploadImageSelective(XFile(compressedImage.path));

      if (newuploadedPath != 'null') {
        setState(() {
          imageUrl = newuploadedPath;
          isimageUploading = false;
        });
        Fluttertoast.showToast(
            msg: 'Image uploaded successfully: $newuploadedPath');
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload the image.');
        setState(() {
          isimageUploading = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error during image selection: $e');
      setState(() {
        isimageUploading = false;
      });
    }
  }

// Function to compress image
  Future<XFile?> compressImage(File file) async {
    final String targetPath =
        '${file.parent.path}/compressed_${file.uri.pathSegments.last}';

    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85, // Adjust quality to achieve ~2MB size
        minWidth: 1920, // Adjust resolution as needed
        minHeight: 1080, // Adjust resolution as needed
      );

      return compressedFile;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error compressing image: $e');
      return null;
    }
  }

  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFiles = prefs.getString('downloadedStudentDoubts') ?? '{}';
    setState(() {
      downloadedFiles = Map<String, String>.from(jsonDecode(savedFiles));
    });
  }

  Future<void> _saveDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('downloadedStudentDoubts', jsonEncode(downloadedFiles));
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

  Future<void> uploadSolution() async {
    // Replace with your API endpoint
    String apiUrl = '$baseUrl/api/give-doubt-solution/$selectedDoubtId';

    // The data to be sent in the POST request
    final Map<String, String> data = {
      'image': imageUrl,
      'status': 'Solved',
    };
    if (imageUrl == '') {
      Fluttertoast.showToast(msg: 'Upload an Image first');
    }

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json', // Set the content type to JSON
        },
        body: jsonEncode(data), // Encode the data as JSON
      );

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
            msg: 'Solution uploaded successfully: ${response.body}');
        setState(() {
          isSolutionUploading = false;
        });
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    StudentDoubtsPage(userID: widget.userID)));
      } else {
        print('Failed to upload data. Status code: ${response.statusCode}');
        setState(() {
          isSolutionUploading = false;
        });
        Fluttertoast.showToast(msg: 'Response body: ${response.body}');
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred: $error');
      setState(() {
        isSolutionUploading = false;
      });
    }
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
    if (extension == 'jpg' || extension == 'jpeg') {
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

  Future<void> fetchDoubts() async {
    if (!hasMoreData || isLoading) return; // Prevent unnecessary calls

    setState(() {
      isLoading = true; // Show loading indicator while fetching data
    });

    try {
      // Get the stored userID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final storedUserID = prefs.getString('userID');

      if (storedUserID == null) {
        throw Exception('User ID not found in shared preferences');
      }

      final response = await http
          .get(Uri.parse(
              '$baseUrl/api/view-doubts/${widget.userID}/student?page=$page&data_per_page=10'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          if (data.isEmpty) {
            hasMoreData = false; // No more data available
          } else {
            // Filter doubts where teacheruserID matches the stored userID
            final filteredDoubts = data
                .map((json) => Doubt.fromJson(json))
                .where((doubt) => doubt.teacheruserID == storedUserID)
                .toList();
            doubtsList.addAll(filteredDoubts);
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
                'Student Doubts',
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
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  child: SizedBox(
                    height: (doubtsList.length * 130.0)
                        .clamp(0, MediaQuery.of(context).size.height * 0.65),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      itemCount: doubtsList.length,
                      itemBuilder: (context, index) {
                        final doubt = doubtsList[index];
                        final filename =
                            '${doubt.course}_student_doubt_${doubt.createdAt}';
                        final isDownloaded =
                            downloadedFiles.containsKey(filename);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Image.network(doubt.image),
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
                                      onPressed:
                                          doubt.status == 'Solved' &&
                                                  doubt.solution != 'N/A'
                                              ? () {
                                                  setState(() {
                                                    selectedDoubtId = doubt.id;
                                                  });
                                                  showDialog(
                                                    context: context,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        insetPadding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: StatefulBuilder(
                                                          builder: (context,
                                                              setDialogState) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Image.network(
                                                                    doubt
                                                                        .solution,
                                                                    height: 200,
                                                                    width: 200,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  isSolutionUploading
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator())
                                                                      : Container(
                                                                          width:
                                                                              200,
                                                                          height:
                                                                              50,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.purpleAccent.shade100,
                                                                            borderRadius:
                                                                                BorderRadius.circular(22),
                                                                          ),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                              showDialog(
                                                                                context: context,
                                                                                barrierColor: Colors.black.withOpacity(0.3),
                                                                                builder: (BuildContext context) {
                                                                                  return Dialog(
                                                                                    backgroundColor: Colors.transparent,
                                                                                    insetPadding: const EdgeInsets.all(16),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(20),
                                                                                    ),
                                                                                    child: StatefulBuilder(
                                                                                      builder: (context, setDialogState) {
                                                                                        return Container(
                                                                                          padding: const EdgeInsets.all(16.0),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.circular(20),
                                                                                          ),
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              isimageUploading
                                                                                                  ? const Center(
                                                                                                      child: CircularProgressIndicator(),
                                                                                                    )
                                                                                                  : imageUrl.isEmpty
                                                                                                      ? Column(
                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                          children: [
                                                                                                            Container(
                                                                                                              width: 200,
                                                                                                              height: 50,
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: Colors.lightBlue.shade100,
                                                                                                                borderRadius: BorderRadius.circular(22),
                                                                                                              ),
                                                                                                              child: TextButton(
                                                                                                                onPressed: () async {
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = true; // Show progress indicator
                                                                                                                  });
                                                                                                                  await handleImageSelection(ImageSource.camera);
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = false; // Hide progress indicator
                                                                                                                  });
                                                                                                                },
                                                                                                                child: const Text(
                                                                                                                  "Camera",
                                                                                                                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            const SizedBox(height: 16),
                                                                                                            Container(
                                                                                                              width: 200,
                                                                                                              height: 50,
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: Colors.orange.shade100,
                                                                                                                borderRadius: BorderRadius.circular(22),
                                                                                                              ),
                                                                                                              child: TextButton(
                                                                                                                onPressed: () async {
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = true; // Show progress indicator
                                                                                                                  });
                                                                                                                  await handleImageSelection(ImageSource.gallery);
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = false; // Hide progress indicator
                                                                                                                  });
                                                                                                                },
                                                                                                                child: const Text(
                                                                                                                  "Upload Image",
                                                                                                                  style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ],
                                                                                                        )
                                                                                                      : Image.network(
                                                                                                          imageUrl,
                                                                                                          height: 150,
                                                                                                          width: 150,
                                                                                                        ),
                                                                                              const SizedBox(height: 10),
                                                                                              isSolutionUploading
                                                                                                  ? const Center(child: CircularProgressIndicator())
                                                                                                  : Container(
                                                                                                      width: 200,
                                                                                                      height: 50,
                                                                                                      decoration: BoxDecoration(
                                                                                                        color: Colors.purpleAccent.shade100,
                                                                                                        borderRadius: BorderRadius.circular(22),
                                                                                                      ),
                                                                                                      child: TextButton(
                                                                                                        onPressed: () {
                                                                                                          setDialogState(() {
                                                                                                            isSolutionUploading = true;
                                                                                                          });
                                                                                                          uploadSolution();
                                                                                                          Navigator.pop(context);
                                                                                                        },
                                                                                                        child: const Text(
                                                                                                          "Upload Solution",
                                                                                                          style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                              const SizedBox(height: 20),
                                                                                              IconButton(
                                                                                                  onPressed: () {
                                                                                                    Navigator.pop(context);
                                                                                                  },
                                                                                                  icon: const Icon(Icons.cancel))
                                                                                            ],
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              "Change Solution",
                                                                              style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),
                                                                  IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .cancel))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }
                                              : () {
                                                  setState(() {
                                                    selectedDoubtId = doubt.id;
                                                  });
                                                  showDialog(
                                                    context: context,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.3),
                                                    builder:
                                                        (BuildContext context) {
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        insetPadding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: StatefulBuilder(
                                                          builder: (context,
                                                              setDialogState) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  isimageUploading
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        )
                                                                      : imageUrl
                                                                              .isEmpty
                                                                          ? Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Container(
                                                                                  width: 200,
                                                                                  height: 50,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.lightBlue.shade100,
                                                                                    borderRadius: BorderRadius.circular(22),
                                                                                  ),
                                                                                  child: TextButton(
                                                                                    onPressed: () async {
                                                                                      setDialogState(() {
                                                                                        isimageUploading = true; // Show progress indicator
                                                                                      });
                                                                                      await handleImageSelection(ImageSource.camera);
                                                                                      setDialogState(() {
                                                                                        isimageUploading = false; // Hide progress indicator
                                                                                      });
                                                                                    },
                                                                                    child: const Text(
                                                                                      "Camera",
                                                                                      style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 16),
                                                                                Container(
                                                                                  width: 200,
                                                                                  height: 50,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.orange.shade100,
                                                                                    borderRadius: BorderRadius.circular(22),
                                                                                  ),
                                                                                  child: TextButton(
                                                                                    onPressed: () async {
                                                                                      setDialogState(() {
                                                                                        isimageUploading = true; // Show progress indicator
                                                                                      });
                                                                                      await handleImageSelection(ImageSource.gallery);
                                                                                      setDialogState(() {
                                                                                        isimageUploading = false; // Hide progress indicator
                                                                                      });
                                                                                    },
                                                                                    child: const Text(
                                                                                      "Upload Image",
                                                                                      style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Image
                                                                              .network(
                                                                              imageUrl,
                                                                              height: 150,
                                                                              width: 150,
                                                                            ),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  isSolutionUploading
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator())
                                                                      : Container(
                                                                          width:
                                                                              200,
                                                                          height:
                                                                              50,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.purpleAccent.shade100,
                                                                            borderRadius:
                                                                                BorderRadius.circular(22),
                                                                          ),
                                                                          child:
                                                                              TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              setDialogState(() {
                                                                                isSolutionUploading = true;
                                                                              });
                                                                              uploadSolution();
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              "Upload Solution",
                                                                              style: TextStyle(fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),
                                                                  IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .cancel))
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                      icon: const Icon(Icons.upload, size: 17),
                                      label: Text(
                                          doubt.status == 'Solved'
                                              ? "Uploaded"
                                              : "Upload",
                                          style: const TextStyle(fontSize: 10)),
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
                    ),
                  ),
                ),
                if (isLoading)
                  const CircularProgressIndicator()
                else if (!hasMoreData && doubtsList.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'No more Doubts',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (doubtsList.isNotEmpty)
                  TextButton(
                    onPressed: fetchDoubts,
                    child: const Text('Load More'),
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
  final String solution;
  final String teacheruserID;

  Doubt(
      {required this.id,
      required this.title,
      required this.course,
      required this.image,
      required this.createdAt,
      required this.status,
      required this.solution,
      required this.teacheruserID});

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      image: json['image'],
      teacheruserID: json['teacher_userID'] ?? 'N/A',
      createdAt:
          DateTime.parse(json['created_at']).toIso8601String().split('T')[0],
      solution: json['solution'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
    );
  }
}
