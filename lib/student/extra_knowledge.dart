import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExtraKnowledge extends StatefulWidget {
  const ExtraKnowledge({super.key});

  @override
  State<ExtraKnowledge> createState() => _ExtraKnowledgeState();
}

class _ExtraKnowledgeState extends State<ExtraKnowledge> {
  late final WebViewController _controller;

  final String url = 'https://www.wikipedia.org';

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
      backgroundColor: Colors.grey[50],
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
                'Extra Knowledge',
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
