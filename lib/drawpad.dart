import 'package:flutter/material.dart';

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
  bool _isDrawingEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(22),
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                if (_isDrawingEnabled) {
                  setState(() {
                    RenderBox box = context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);

                    // Check if the point is within bounds
                    if (localPosition.dx >= 0 &&
                        localPosition.dx <= box.size.width &&
                        localPosition.dy >= 0 &&
                        localPosition.dy <= box.size.height) {
                      _points.add(localPosition);
                    }
                  });
                }
              },
              onPanEnd: (details) {
                if (_isDrawingEnabled) {
                  _points.add(null); // To break lines
                }
              },
              child: CustomPaint(
                painter: DrawPadPainter(_points),
                size: Size.infinite,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isDrawingEnabled = !_isDrawingEnabled;
                });
              },
              child: Text(_isDrawingEnabled ? "Stop" : "Draw"),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 120,
            child: TextButton(
              onPressed: () {
                // Upload logic goes here
              },
              child: const Text("Upload"),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 10,
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
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.3,
          child: const DrawPad(),
        ),
      );
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDrawPad(context);
          },
          child: const Text("Open DrawPad"),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
