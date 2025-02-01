import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/drawpad.dart';
import 'package:trusir/common/file_downloader.dart';

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
    FileDownloader.loadDownloadedFiles();
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
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
                      padding: const EdgeInsets.all(10.0),
                      itemCount: doubtsList.length,
                      itemBuilder: (context, index) {
                        final gk = doubtsList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StudentDoubtsDetailPage(
                                      gk: gk,
                                      onUpload:
                                          gk.status == 'Solved' &&
                                                  gk.solution != 'N/A'
                                              ? () {
                                                  setState(() {
                                                    selectedDoubtId = gk.id;
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
                                                                    gk.solution,
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
                                                                                                            const SizedBox(height: 16),
                                                                                                            Container(
                                                                                                              width: 200,
                                                                                                              height: 50,
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: Colors.lightGreen.shade100,
                                                                                                                borderRadius: BorderRadius.circular(22),
                                                                                                              ),
                                                                                                              child: TextButton(
                                                                                                                onPressed: () async {
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = true; // Show progress indicator
                                                                                                                  });
                                                                                                                  imageUrl = await Navigator.push(
                                                                                                                    context,
                                                                                                                    MaterialPageRoute(
                                                                                                                      builder: (context) => const DrawPad(),
                                                                                                                    ),
                                                                                                                  );
                                                                                                                  setDialogState(() {
                                                                                                                    isimageUploading = false; // Hide progress indicator
                                                                                                                  });
                                                                                                                },
                                                                                                                child: const Text(
                                                                                                                  "Draw",
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
                                                    selectedDoubtId = gk.id;
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
                                                                                Container(
                                                                                  width: 200,
                                                                                  height: 50,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.lightGreen.shade100,
                                                                                    borderRadius: BorderRadius.circular(22),
                                                                                  ),
                                                                                  child: TextButton(
                                                                                    onPressed: () async {
                                                                                      setDialogState(() {
                                                                                        isimageUploading = true; // Show progress indicator
                                                                                      });
                                                                                      imageUrl = await Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => const DrawPad(),
                                                                                        ),
                                                                                      );
                                                                                      setDialogState(() {
                                                                                        isimageUploading = false; // Hide progress indicator
                                                                                      });
                                                                                    },
                                                                                    child: const Text(
                                                                                      "Draw",
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
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          gk.image.split(',').first,
                                          width: 75,
                                          height: 75,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                                size: 50);
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              gk.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontFamily: "Poppins",
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              gk.course,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Status: ${gk.status}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Posted on: ${formatDate(gk.createdAt)}',
                                              style: TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
      title: json['title'] ?? 'No data',
      course: json['course'] ?? 'No data',
      image: json['image'],
      teacheruserID: json['teacher_userID'] ?? 'N/A',
      createdAt: json['created_at'],
      solution: json['solution'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
    );
  }
}

class StudentDoubtsDetailPage extends StatelessWidget {
  final Doubt gk;
  final VoidCallback onUpload;

  const StudentDoubtsDetailPage(
      {super.key, required this.gk, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    String formatDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    }

    List<String> imageUrls = gk.image.split(',').map((e) => e.trim()).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/back_button.png', height: 50),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          gk.title,
          style: const TextStyle(
            color: Color(0xFF48116A),
            fontSize: 25,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Adjust columns as needed
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                gk.title,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                gk.course,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  'Posted on: ${formatDate(gk.createdAt)}',
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              gk.status == 'Solved'
                  ? const Text('Uploaded Solution')
                  : const Text('Upload Solution'),
              gk.status == 'Solved'
                  ? Image.network(gk.solution)
                  : ElevatedButton.icon(
                      onPressed: onUpload,
                      icon: const Icon(Icons.upload, size: 17),
                      label:
                          const Text("Upload", style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        foregroundColor: Colors.blue,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
