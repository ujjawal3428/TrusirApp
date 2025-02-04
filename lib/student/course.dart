import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/toggle_button.dart';
import 'package:trusir/student/all_courses.dart';
import 'package:trusir/student/main_screen.dart';
import 'package:trusir/student/demo_courses.dart';
import 'package:trusir/student/my_courses.dart';

class Course {
  final int id;
  final int active;
  final String amount;
  final String name;
  final String courseClass;
  final String subject;
  final String pincode;
  final String newAmount;
  final String image;

  Course({
    required this.id,
    required this.amount,
    required this.active,
    required this.name,
    required this.subject,
    required this.pincode,
    required this.courseClass,
    required this.newAmount,
    required this.image,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      amount: json['amount'],
      active: json['active'],
      name: json['name'],
      subject: json['subject'],
      courseClass: json['class'],
      pincode: json['pincode'],
      newAmount: json['new_amount'],
      image: json['image'],
    );
  }
}

class Transaction {
  final String transactionName;
  final int amount;
  final String transactionType;
  final String transactionID;

  Transaction({
    required this.transactionName,
    required this.amount,
    required this.transactionType,
    required this.transactionID,
  });

  // Convert the Transaction object to JSON
  Map<String, dynamic> toJson() {
    return {
      "transactionName": transactionName,
      "amount": amount,
      "transactionType": transactionType,
      "transactionID": transactionID,
    };
  }
}

class MyCourseModel {
  final int id;
  final String courseID;
  final String teacherID;
  final String type;
  MyCourseModel({
    required this.id,
    required this.courseID,
    required this.teacherID,
    required this.type,
  });

  // Factory method for creating an instance from JSON
  factory MyCourseModel.fromJson(Map<String, dynamic> json) {
    return MyCourseModel(
        id: json['id'],
        courseID: json['courseID'],
        teacherID: json['teacherID'],
        type: json['type']);
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final PageController _pageController = PageController();
  final GlobalKey<FilterSwitchState> _filterSwitchKey =
      GlobalKey<FilterSwitchState>();
  bool isLoading = true;
  double balance = 0;

  Future<List<Course>> fetchAllCourses() async {
    final url = Uri.parse('$baseUrl/get-courses');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final responseData = data.map((json) => Course.fromJson(json)).toList();
      _courses = responseData;
      return _courses;
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  Future<double> fetchBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    // Replace with your API URL
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/user/balance/$userID'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(double.parse(data['balance']));
        setState(() {
          balance = double.parse(data['balance']);
          prefs.setString('wallet_balance', '$balance');
        });
        return balance; // Convert balance to an integer
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      print('Error: $e');
      return 0; // Return 0 in case of an error
    }
  }

  Future<List<MyCourseModel>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    final url = Uri.parse('$baseUrl/get-courses/$userID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final responseData =
          data.map((json) => MyCourseModel.fromJson(json)).toList();
      _courseDetails = responseData;
      return _courseDetails;
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  List<Course> _courses = [];
  List<MyCourseModel> _courseDetails = [];
  List<Course> allCourses = [];
  List<MyCourseModel> myCourses = [];
  List<MyCourseModel> demoCourses = [];
  int _selectedIndex = 0;
  List<Map<String, dynamic>> mycourses = [];
  List<Map<String, dynamic>> democourses = [];
  bool isWeb = false;

  Future<void> fetchCoursesByIds(List<MyCourseModel> data, int index) async {
    try {
      for (int i = 0; i < data.length; i++) {
        String courseId = data[i].courseID;
        String teacherId = data[i].teacherID;
        int slotID = data[i].id;
        Map<String, dynamic>? courseData = await fetchCourseById((courseId));
        if (courseData != null) {
          courseData['teacherID'] = teacherId;
          courseData['slotID'] = slotID;
          setState(() {
            if (index == 0) {
              mycourses.add(courseData);
            } else {
              democourses.add(courseData);
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching courses by IDs: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchCourseById(String courseId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/get-course-by-id/$courseId"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      } else {
        throw Exception("Failed to load course data for ID $courseId");
      }
    } catch (e) {
      print("Error fetching course with ID $courseId: $e");
    }
    return null;
  }

  Future<void> _filterCourses(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userPincode = prefs.getString('pincode');
    final String? userClass = prefs.getString('class');
    setState(() {
      isLoading = true;
    });
    try {
      await fetchCourses();
      await fetchAllCourses();

      setState(() {
        final filteredAllCourses = _courses.where((course) {
          final noMatchingDetail = !_courseDetails.any((detail) =>
              int.parse(detail.courseID) == course.id); // No match for courseID
          return noMatchingDetail &&
              course.pincode == userPincode &&
              course.active == 1 && // Match pincode
              course.courseClass == userClass; // Match class
        }).toList();
        if (index == 0) {
          myCourses = _courseDetails
              .where((course) =>
                  course.type == 'purchased' || course.type == 'Purchased')
              .toList();
        } else if (index == 1) {
          demoCourses =
              _courseDetails.where((course) => course.type == 'demo').toList();
        } else if (index == 2) {
          allCourses = filteredAllCourses;
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _filterSwitchKey.currentState?.setSelectedIndex(index);
  }

  @override
  void initState() {
    super.initState();
    initialize();
    fetchBalance();
  }

  void initialize() async {
    await _filterCourses(0);
    await _filterCourses(1);
    await _filterCourses(2);
    await fetchCoursesByIds(myCourses, 0);
    await fetchCoursesByIds(demoCourses, 1);
  }

  @override
  Widget build(BuildContext context) {
    isWeb = MediaQuery.of(context).size.width > 600;

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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(
                        index: 0,
                      ),
                    ),
                  );
                },
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 20),
              const Text(
                'Course',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FilterSwitch(
                  key: _filterSwitchKey,
                  option1: 'My Courses',
                  option2: 'Demo Courses',
                  option3: 'All Courses',
                  initialSelectedIndex: _selectedIndex,
                  onChanged: (index) {
                    _pageController.jumpToPage(
                      index,
                    );
                  },
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged, // Update index on swipe
                    children: [
                      Mycourses(
                        courses: mycourses,
                      ),
                      Democourses(courses: democourses),
                      AllCourses(
                        courses: allCourses,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
