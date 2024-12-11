import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/student_doubt.dart';

class DrawPadPainter extends CustomPainter {
  final List<Offset?> points;

  DrawPadPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawPad extends StatefulWidget {
  const DrawPad({super.key});

  @override
  DrawPadState createState() => DrawPadState();
}

class DrawPadState extends State<DrawPad> {
  final List<Offset?> _points = [];
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<String> uploadImage(File imageFile) async {
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

  Future<void> _uploadDrawing(BuildContext context) async {
    try {
      final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData!.buffer.asUint8List();

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final filePath = join(tempDir.path, 'drawing.png');
      final file = File(filePath)..writeAsBytesSync(imageBytes);

      // Upload the image using the provided method
      final downloadUrl = await uploadImage(file);

      if (downloadUrl != 'null') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploaded successfully!')),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => StudentDoubtScreen(
                      drawing: downloadUrl,
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload drawing')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Container(
              width: 700,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(22),
              ),
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);
                    _points.add(localPosition);
                  });
                },
                onPanEnd: (details) => _points.add(null),
                child: CustomPaint(
                  painter: DrawPadPainter(_points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
            child: TextButton(
              onPressed: () => _uploadDrawing(context),
              child: const Text("Upload"),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _points.clear();
                });
              },
              child: const Text("Clear"),
            ),
          ),
        ],
      ),
    );
  }
}

void showDrawPad(BuildContext context) {
  showDialog(
    barrierColor: Colors.white,
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: const DrawPad(),
        ),
      );
    },
  );
}
