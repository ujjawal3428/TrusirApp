import 'package:flutter/material.dart';

class SpecificExtraKnowledge extends StatefulWidget {
  final String title;
  final String imagePath;
  final String content;

  const SpecificExtraKnowledge({
    super.key,
    required this.title,
    required this.imagePath,
    required this.content,
  });

  @override
  SpecificExtraKnowledgeState createState() => SpecificExtraKnowledgeState();
}

class SpecificExtraKnowledgeState extends State<SpecificExtraKnowledge> {
  bool _showFullContent = false;

  // This function is triggered when the "Read More" button is pressed
  void _toggleContentVisibility() {
    setState(() {
      _showFullContent = !_showFullContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 10),
              Text(widget.title)
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full-width Image before Title
          Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Title
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF48116A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Article Content (Show full content after 'Read More' is clicked)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.content,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                  // Read More Button (Only visible when content is collapsed)
                  if (!_showFullContent)
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: _toggleContentVisibility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48116A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Read More',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
