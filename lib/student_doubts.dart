import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDoubtsPage extends StatefulWidget {
  const StudentDoubtsPage({super.key});

  @override
  State<StudentDoubtsPage> createState() => _StudentDoubtsPageState();
}

class _StudentDoubtsPageState extends State<StudentDoubtsPage> {
  late Future<List<Doubt>> doubts;

  @override
  void initState() {
    super.initState();
    doubts = fetchDoubts();
  }

  Future<List<Doubt>> fetchDoubts() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');

    final response = await http.get(
      Uri.parse(
          'https://balvikasyojana.com:8899/api/view-doubts/67de3d12-184a-4ee2-8dff-baf376700f52/student'), // Replace with your API endpoint
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((json) => Doubt.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load doubts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 1.0),
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
              const SizedBox(width: 5),
              const Text(
                'Student Doubt',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Doubt>>(
                  future: doubts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No doubts available.'));
                    } else {
                      final doubts = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 15.0, right: 15),
                        itemCount: doubts.length,
                        itemBuilder: (context, index) {
                          final doubt = doubts[index];

                          // Generate a unique color for each container using index
                          final backgroundColor =
                              Color((0xFFE3E4E8 + index * 0x000C00) % 0xFFFFFF)
                                  .withOpacity(1.0);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(doubt.image),
                                  ),
                                ),
                                title: Text(
                                  doubt.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Course: ${doubt.course}'),
                                    Text(
                                        'Created at: ${doubt.createdAt.toLocal()}'),
                                  ],
                                ),
                                trailing: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 80,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle upload action
                                        },
                                        icon: const Icon(Icons.download,
                                            size: 17),
                                        label: const Text("Download",
                                            style: TextStyle(fontSize: 10)),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          foregroundColor: Colors
                                              .blue, // Set the button color
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height:
                                            8), // Small space between buttons
                                    SizedBox(
                                      height: 20,
                                      width: 80,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle upload action
                                        },
                                        icon:
                                            const Icon(Icons.upload, size: 17),
                                        label: const Text("Upload",
                                            style: TextStyle(fontSize: 10)),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          foregroundColor: Colors
                                              .blue, // Set the button color
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Doubt {
  final int id;
  final String title;
  final String course;
  final String image;
  final DateTime createdAt;

  Doubt({
    required this.id,
    required this.title,
    required this.course,
    required this.image,
    required this.createdAt,
  });

  factory Doubt.fromJson(Map<String, dynamic> json) {
    return Doubt(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      image: json['image'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
