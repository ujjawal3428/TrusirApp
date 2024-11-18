import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class PracticePage extends StatelessWidget {
  const PracticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Downloader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}

class OpenImageButton extends StatefulWidget {
  const OpenImageButton({super.key});

  @override
  State<OpenImageButton> createState() => _OpenImageButtonState();
}

class _OpenImageButtonState extends State<OpenImageButton> {
  bool _isDownloading = false;
  final String imageUrl =
      'https://letsenhance.io/static/73136da51c245e80edc6ccfe44888a99/1015f/MainBefore.jpg';

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't need storage permission for app documents directory
  }

  Future<String> _getDownloadPath() async {
    if (Platform.isAndroid) {
      // For Android, save to Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } else {
      // For iOS, save to app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<void> _downloadImage() async {
    if (_isDownloading) return;

    // Request storage permission
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download images'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading image...')),
        );
      }

      // Fetch the image data
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get the directory to store the image
        final downloadPath = await _getDownloadPath();
        final fileName = 'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '$downloadPath/$fileName';

        // Save the image
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          // Dismiss loading indicator and show success message
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved to: $filePath'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw 'Failed to download image: ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        // Dismiss loading indicator and show error message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Downloader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadImage,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Download Image'),
            ),
            const SizedBox(height: 20),
            if (_isDownloading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}