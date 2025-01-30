import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';
import 'package:trusir/main.dart';

class ImageUploadUtils {
  static Future<void> requestPermissions() async {
    if (await Permission.storage.isGranted &&
        await Permission.camera.isGranted) {
      return;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt < 30) {
        return;
      }

      if (await Permission.photos.isGranted ||
          await Permission.videos.isGranted ||
          await Permission.camera.isGranted) {
        return;
      }

      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.videos,
        Permission.camera
      ].request();

      if (statuses.values.any((status) => !status.isGranted)) {
        openAppSettings();
      }
    }
  }

  static Future<XFile?> compressImage(File file) async {
    final String targetPath =
        '${file.parent.path}/compressed_${file.uri.pathSegments.last}';

    try {
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1080,
      );

      return compressedFile;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error compressing image: $e');
      return null;
    }
  }

  static Future<String> uploadSingleImageFromGallery() async {
    await requestPermissions();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      Fluttertoast.showToast(msg: 'No image selected.');
      return 'null';
    }

    final compressedImage = await compressImage(File(image.path));
    if (compressedImage == null) {
      Fluttertoast.showToast(msg: 'Failed to compress image.');
      return 'null';
    }

    return await _uploadImage(compressedImage);
  }

  static Future<String> uploadSingleImageFromCamera() async {
    await requestPermissions();

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      Fluttertoast.showToast(msg: 'No image captured.');
      return 'null';
    }

    final compressedImage = await compressImage(File(image.path));
    if (compressedImage == null) {
      Fluttertoast.showToast(msg: 'Failed to compress image.');
      return 'null';
    }

    return await _uploadImage(compressedImage);
  }

  static Future<String> uploadMultipleImagesFromGallery() async {
    await requestPermissions();

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isEmpty) {
      Fluttertoast.showToast(msg: 'No images selected.');
      return 'null';
    }

    List<String> downloadUrls = [];

    for (var image in images) {
      final compressedImage = await compressImage(File(image.path));

      if (compressedImage == null) {
        Fluttertoast.showToast(msg: 'Failed to compress an image. Skipping.');
        continue;
      }

      final String downloadUrl = await _uploadImage(compressedImage);

      if (downloadUrl != 'null') {
        downloadUrls.add(downloadUrl);
      }
    }

    if (downloadUrls.isEmpty) {
      Fluttertoast.showToast(msg: 'No images were successfully uploaded.');
      return 'null';
    }

    return downloadUrls.join(',');
  }

  // Function to upload multiple images from the camera
  static Future<String> uploadMultipleImagesFromCamera() async {
    await requestPermissions();
    final ImagePicker picker = ImagePicker();
    List<XFile> capturedImages = [];

    bool continueCapturing = true;

    while (continueCapturing) {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        capturedImages.add(image);
      }

      continueCapturing = await _showImageDialog(capturedImages);
    }

    if (capturedImages.isEmpty) {
      Fluttertoast.showToast(msg: 'No images selected.');
      return 'null';
    }

    List<String> downloadUrls = [];
    for (var image in capturedImages) {
      final compressedImage = await compressImage(File(image.path));
      if (compressedImage == null) {
        Fluttertoast.showToast(msg: 'Failed to compress an image. Skipping.');
        continue;
      }

      final String downloadUrl = await _uploadImage(compressedImage);
      if (downloadUrl != 'null') {
        downloadUrls.add(downloadUrl);
      }
    }

    return downloadUrls.isEmpty ? 'null' : downloadUrls.join(',');
  }

  static Future<bool> _showImageDialog(List<XFile> images) async {
    return await showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Captured Images'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(images[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Done
                  child: const Text('Done'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), // Add More
                  child: const Text('Add More'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  static Future<String> _uploadImage(XFile image) async {
    final uri = Uri.parse('$baseUrl/api/upload-profile');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('photo', image.path));

    final response = await request.send();

    if (response.statusCode == 201) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (jsonResponse.containsKey('download_url')) {
        return jsonResponse['download_url'] as String;
      } else {
        Fluttertoast.showToast(msg: 'Download URL not found in the response.');
        return 'null';
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to upload image: ${response.statusCode}');
      return 'null';
    }
  }
}
