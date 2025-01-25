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

  static Future<String> uploadImagesFromGallery() async {
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
  static Future<String> uploadImagesFromCamera() async {
    await requestPermissions();
    final ImagePicker picker = ImagePicker();

    List<String> downloadUrls = [];
    bool continueCapturing = true;

    while (continueCapturing) {
      // Capture an image using the camera
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        Fluttertoast.showToast(msg: 'Image selection canceled.');
        continue;
      }

      // Compress the image
      final compressedImage = await compressImage(File(image.path));
      if (compressedImage == null) {
        Fluttertoast.showToast(msg: 'Failed to compress image.');
        continue;
      }

      // Upload the image and get the download URL
      final String downloadUrl = await _uploadImage(compressedImage);
      if (downloadUrl != 'null') {
        downloadUrls.add(downloadUrl);
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload image.');
      }

      // Ask the user if they want to continue capturing images
      continueCapturing = await _askToContinue();
    }

    // Combine all download URLs into a single string
    String result = downloadUrls.join(',');
    return result.isEmpty ? 'null' : result;
  }

// Helper method to display a confirmation dialog
  static Future<bool> _askToContinue() async {
    return await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Capture More Images?'),
              content: const Text('Do you want to capture another image?'),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false), // Stop capturing
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, true), // Continue capturing
                  child: const Text('Yes'),
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
