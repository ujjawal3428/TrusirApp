import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

class StudentDoubts extends StatefulWidget {
  const StudentDoubts({super.key});

  @override
  State<StudentDoubts> createState() => _StudentDoubtsState();
}

class _StudentDoubtsState extends State<StudentDoubts> {
  late Future<List<Doubt>> doubts;

  @override
  void initState() {
    super.initState();
    doubts = fetchDoubts();
  }

  Future<List<Doubt>> fetchDoubts() async {
    // final prefs = await SharedPreferences.getInstance();
    // final userID = prefs.getString('userID');

    final response = await http.get(
      Uri.parse(
          'https://balvikasyojana.com:8899/api/view-doubts/2ca5fb8b-a252-41d5-b6e4-2bbe039594bb/student'), // Replace with your API endpoint
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
      body: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 30),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/dikshaback@2x.png',
                        width: 58,
                        height: 58,
                      ),
                      const SizedBox(width: 22),
                      const Text(
                        'Student Doubts',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                        padding: const EdgeInsets.all(10.0),
                        itemCount: doubts.length,
                        itemBuilder: (context, index) {
                          final doubt = doubts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(doubt.image),
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
                                trailing:
                                    const Icon(Icons.arrow_forward_ios_rounded),
                                onTap: () {
                                  // Handle tap on a doubt
                                },
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
