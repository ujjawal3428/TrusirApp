import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GKPage extends StatefulWidget {
  const GKPage({super.key});

  @override
  State<GKPage> createState() => _GKPageState();
}

class _GKPageState extends State<GKPage> {
  late final WebViewController _controller;

  final String url = 'https://balvikasyojana.com:8899/all-course/testid';

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
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 20),
              const Text(
                'Courses',
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
