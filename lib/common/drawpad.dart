import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:trusir/common/api.dart';

class DrawPadPainter extends CustomPainter {
  final List<DrawPoint> points;

  DrawPadPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].offset != null && points[i + 1].offset != null) {
        final paint = Paint()
          ..color = points[i].color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = points[i].strokeWidth;
        canvas.drawLine(points[i].offset!, points[i + 1].offset!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawPoint {
  final Offset? offset;
  final Color color;
  final double strokeWidth;

  DrawPoint(this.offset, this.color, this.strokeWidth);
}

class ColorPickerDialog extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  static const List<Color> colorOptions = [
    Colors.black,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  const ColorPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Color'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: colorOptions.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onColorSelected(colorOptions[index]);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colorOptions[index],
                  border: Border.all(
                    color: currentColor == colorOptions[index]
                        ? Colors.white
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DrawPad extends StatefulWidget {
  const DrawPad({super.key});

  @override
  DrawPadState createState() => DrawPadState();
}

class DrawPadState extends State<DrawPad> {
  final List<DrawPoint> _points = [];
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  Color _currentColor = Colors.black;
  double _strokeWidth = 4.0;
  bool _isEraser = false;

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileSize = await imageFile.length(); // File size in bytes
      if (fileSize > 2 * 1024 * 1024) {
        // 2 MB limit

        Fluttertoast.showToast(
            msg: 'File size exceeds 2MB. Please select a smaller image.');
        return 'null'; // Return early
      }
      final uri = Uri.parse('$baseUrl/api/upload-profile');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        return jsonResponse['download_url'] ?? 'null';
      } else {
        Fluttertoast.showToast(msg: 'Upload Failed ${response.statusCode}');
        return 'null';
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error uploading image: $e');
      return 'null';
    }
  }

  Future<void> _uploadDrawing(BuildContext context) async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Boundary not found");

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        Fluttertoast.showToast(msg: 'Failed to convert image');
        return;
      }

      final imageBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, 'drawing.png');
      final file = File(filePath)..writeAsBytesSync(imageBytes);
      final fileSize = imageBytes.length; // Byte size of the image
      if (fileSize > 2 * 1024 * 1024) {
        // 2 MB limit
        Fluttertoast.showToast(msg: 'File size exceeds 2MB');
        return; // Exit if file is too large
      }

      final downloadUrl = await _uploadImage(file);

      if (downloadUrl != 'null') {
        Fluttertoast.showToast(msg: 'Uploaded Successfully');
        Navigator.pop(context, downloadUrl); // Return the link
      } else {
        Fluttertoast.showToast(msg: 'Failed to upload drawing');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          backgroundColor: Colors.grey[50],
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text('Draw Pad',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 25)),
            ],
          )),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Left sidebar with tool buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.brush),
                      color: _isEraser ? Colors.grey : _currentColor,
                      onPressed: () => setState(() => _isEraser = false),
                    ),
                    IconButton(
                      icon: const Icon(Icons.circle_outlined),
                      color: _isEraser ? Colors.red : Colors.grey,
                      onPressed: () => setState(() => _isEraser = true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => ColorPickerDialog(
                            currentColor: _currentColor,
                            onColorSelected: (color) {
                              setState(() => _currentColor = color);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Drawing canvas
                Expanded(
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            final box = _repaintBoundaryKey.currentContext
                                ?.findRenderObject() as RenderBox?;
                            if (box == null) return;

                            final localPosition =
                                box.globalToLocal(details.globalPosition);
                            if (localPosition.dx >= 0 &&
                                localPosition.dy >= 0 &&
                                localPosition.dx <= box.size.width &&
                                localPosition.dy <= box.size.height) {
                              _points.add(DrawPoint(
                                localPosition,
                                _isEraser ? Colors.grey[50]! : _currentColor,
                                _strokeWidth,
                              ));
                            }
                          });
                        },
                        onPanEnd: (details) => _points
                            .add(DrawPoint(null, _currentColor, _strokeWidth)),
                        child: CustomPaint(
                          painter: DrawPadPainter(_points),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
                // Stroke width slider
                RotatedBox(
                  quarterTurns: 1,
                  child: Slider(
                    value: _strokeWidth,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: _strokeWidth.round().toString(),
                    onChanged: (value) => setState(() => _strokeWidth = value),
                  ),
                ),
              ],
            ),
          ),
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _points.clear()),
                  child: const Text("Clear"),
                ),
                ElevatedButton(
                  onPressed:
                      _points.isEmpty ? null : () => _uploadDrawing(context),
                  child: const Text("Upload"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showDrawPad(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DrawPad(),
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DrawPad(),
    );
  }
}
