import 'package:flutter/material.dart';

class AddDoubt extends StatelessWidget {
  final List<Map<String, String>> doubtsList = [
    {"subject": "Mathematics", "date": "01/12/2024"},
    {"subject": "Physics", "date": "28/11/2024"},
    {"subject": "Chemistry", "date": "25/11/2024"},
    {"subject": "Biology", "date": "20/11/2024"},
    {"subject": "English", "date": "15/11/2024"},
  ];

   AddDoubt({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
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
            const SizedBox(width: 5),
            const Text(
              'Add Doubt',
              style: TextStyle(
                color: Color(0xFF48116A),
                fontSize: 22,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: doubtsList.length,
          itemBuilder: (context, index) {
            final item = doubtsList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                 
                   Image.asset(
                      'assets/jpg@3x.png',
                      
                    
                    ),
                    const SizedBox(width: 15),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["subject"] ?? "Unknown Subject",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            " ${item["date"] ?? "Unknown Date"}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

