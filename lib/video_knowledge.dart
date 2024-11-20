import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoKnowledge extends StatefulWidget {
  const VideoKnowledge({super.key});

  @override
  State<VideoKnowledge> createState() => _VideoKnowledgeState();
}

class _VideoKnowledgeState extends State<VideoKnowledge> {
  late final WebViewController _controller;

  final String url = 'https://www.youtube.com';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(url))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Color(0xFF48116A),
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 20),
              const Text(
                'Video Knowledge',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
