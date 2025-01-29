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

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Image.network(
                                doubt.image.split(',').first,
                                fit: BoxFit.cover,
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
                                  Text(
                                      'Posted on: ${formatDate(doubt.createdAt)}'),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 80,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierColor:
                                              Colors.black.withOpacity(0.3),
                                          builder: (BuildContext context) {
                                            List<String> images =
                                                doubt.image.split(',');
                                            return Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding:
                                                  const EdgeInsets.all(16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "Images",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    GridView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                        crossAxisCount: 3,
                                                        crossAxisSpacing: 10,
                                                        mainAxisSpacing: 10,
                                                      ),
                                                      itemCount: images.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final image =
                                                            images[index];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            FileDownloader
                                                                    .downloadedFiles
                                                                    .containsKey(
                                                                        '${filename}_$index')
                                                                ? FileDownloader
                                                                    .openFile(
                                                                        '${filename}_$index')
                                                                : FileDownloader
                                                                    .downloadFile(
                                                                        context,
                                                                        image,
                                                                        '${filename}_$index');
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                child: Image
                                                                    .network(
                                                                  image,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 5),
                                                              Text(
                                                                '${doubt.title}_$index',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 8,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 17,
                                      ),
                                      label: const Text(
                                        "Open",
                                        style: TextStyle(fontSize: 10),
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
      createdAt: json['created_at'],
      solution: json['solution'] ?? 'N/A',
      status: json['status'] ?? 'N/A',
    );
  }
}
