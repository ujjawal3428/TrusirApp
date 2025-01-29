import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';

class AttendanceRecord {
  final int id;
  final String subjectID;
  final String subjectName;
  final String studentID;
  final String teacherID;
  final String year;
  final String month;
  final String date;
  final String slotID;
  final String status;

  AttendanceRecord({
    required this.id,
    required this.subjectID,
    required this.subjectName,
    required this.studentID,
    required this.teacherID,
    required this.year,
    required this.month,
    required this.date,
    required this.slotID,
    required this.status,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      subjectID: json['subjectID'],
      subjectName: json['subject_name'],
      studentID: json['studentID'],
      teacherID: json['teacherID'],
      year: json['year'],
      month: json['month'],
      date: json['date'],
      slotID: json['slotID'],
      status: json['status'],
    );
  }
}

class Course {
  final int id;
  final String courseID;
  final String courseName;
  final String teacherName;
  final String teacherID;
  final String studentID;
  final String image;
  final String studentName;
  final String timeSlot;

  Course({
    required this.id,
    required this.courseID,
    required this.courseName,
    required this.teacherName,
    required this.teacherID,
    required this.studentID,
    required this.image,
    required this.studentName,
    required this.timeSlot,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      courseID: json['courseID'],
      courseName: json['courseName'],
      teacherName: json['teacherName'],
      teacherID: json['teacherID'],
      studentID: json['StudentID'],
      image: json['image'],
      studentName: json['StudentName'],
      timeSlot: json['timeSlot'],
    );
  }
}

class AttendancePage extends StatefulWidget {
  final String userID;
  const AttendancePage({super.key, required this.userID});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  int selectedCourseIndex = 0;
  int selectedSlotIndex = 0;
  bool isWeb = false;
  Map<int, Map<String, String>> _attendanceData = {};
  // Day: Status
  Map<String, int> _summaryData = {}; // Summary details
  List<String> weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  List<Map<String, String>> slots = [];
  String? selectedslotID = '';

  Future<List<Course>> fetchCourses() async {
    final url = Uri.parse(
        '$baseUrl/get-courses/${widget.userID}'); // Replace with your API URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(data);
      if (mounted) {
        setState(() {
          slots = data.map((course) {
            return {
              'courseName': course['courseName'] as String,
              'timeSlot': course['timeSlot'] as String,
              'slotID': course['id']
                  .toString(), // Converting 'id' to String for uniformity
            };
          }).toList();
        });
      }
      setState(() {
        selectedslotID = slots[0]['slotID'];
      });
      print(selectedslotID);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  DateTime get _firstDayOfMonth {
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  int get _daysInMonth {
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
  }

  int get _startingWeekday {
    return _firstDayOfMonth.weekday % 7; // Adjust for week starting Sunday
  }

  List<int> get dates {
    return List.generate(_daysInMonth, (index) => index + 1);
  }

  String get _monthYearString {
    return "${getMonthName(_selectedDate.month)} ${_selectedDate.year}";
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      await fetchCourses(); // Wait for fetchCourses to complete
      _fetchAttendanceData(
          selectedslotID!); // Call _fetchAttendanceData after fetchCourses
    } catch (error) {
      print('Error during initialization: $error');
    }
  }

  Future<List<AttendanceRecord>> fetchAttendanceRecords({
    required String year,
    required String month,
    required String slotID,
  }) async {
    final url = Uri.parse(
        'https://admin.trusir.com/view-attendance/${widget.userID}/$year/$month/$slotID');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => AttendanceRecord.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load attendance records. Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching attendance records: $error');
    }
  }

// Function to convert fetched attendance data into a hierarchical structure
  Map<String, dynamic> attendancedata(List<AttendanceRecord> records) {
    // Define a hierarchical map to store attendance data
    Map<String, Map<String, Map<String, Map<String, String>>>>
        attendanceHierarchy = {};

    for (var record in records) {
      String year = record.year;
      String month = record.month;
      String date = record.date;
      String status = record.status;
      String id =
          record.id.toString(); // Convert id to a string for consistency

      // Ensure year exists in the map
      if (!attendanceHierarchy.containsKey(year)) {
        attendanceHierarchy[year] = {};
      }

      // Ensure month exists in the map
      if (!attendanceHierarchy[year]!.containsKey(month)) {
        attendanceHierarchy[year]![month] = {};
      }

      // Ensure date exists in the map
      if (!attendanceHierarchy[year]![month]!.containsKey(date)) {
        attendanceHierarchy[year]![month]![date] = {};
      }

      // Add both id and status to the date map
      attendanceHierarchy[year]![month]![date] = {"id": id, "status": status};
    }
    return attendanceHierarchy;
  }

  Future<Map<String, dynamic>> attendanceconvert(
      int month, String year, String slotID) async {
    final mon = getMonthName(month);
    final records =
        await fetchAttendanceRecords(year: year, month: mon, slotID: slotID);
    return attendancedata(records); // Return the hierarchical data
  }

  // Generate dropdown items by pairing courses with time slots

  void _fetchAttendanceData(String selectedslotID) {
    final month = _selectedDate.month;
    final year = _selectedDate.year.toString();

    setState(() {
      _attendanceData.clear(); // Clear old data before fetching new data
    });

    attendanceconvert(month, year, selectedslotID).then((apiResponse) {
      if (apiResponse.isEmpty || !apiResponse.containsKey(year)) {
        _showNoDataMessage();
        return;
      }

      final monthKey = getMonthName(month);
      if (apiResponse[year].containsKey(monthKey)) {
        setState(() {
          _attendanceData =
              (apiResponse[year][monthKey] as Map<String, dynamic>)
                  .map<int, Map<String, String>>((date, idAndStatus) {
            return MapEntry(
                int.parse(date), idAndStatus as Map<String, String>);
          });
        });

        _updateSummary(); // Update summary after fetching data
      } else {
        _showNoDataMessage();
      }
    }).catchError((error) {
      print("Error fetching attendance data: $error");
      _showNoDataMessage();
    });
  }

  void _showNoDataMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No attendance data available.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitAttendance({
    required String id,
    required String status,
  }) async {
    final payload = {
      "status": status,
    };

    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/api/update-attendance/$id'), // Append the ID as a parameter to the URL
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update the status locally
          _fetchAttendanceData(selectedslotID!);
          _updateSummary(); // Update the summary
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update attendance!")),
        );
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  void _navigateToYearMonthPicker(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YearMonthPicker(
          selectedYear: _selectedDate.year,
          selectedMonth: _selectedDate.month,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedDate =
            DateTime(result['year'], result['month'], _selectedDate.day);
        _fetchAttendanceData(selectedslotID!);
        _updateSummary();
      });
    }
  }

  void _prevMonth() {
    setState(() {
      if (_selectedDate.month == 1) {
        _selectedDate = DateTime(
            _selectedDate.year - 1, 12); // Go to December of the previous year
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
      print(_selectedDate.year);
      print(_selectedDate.month);
      _fetchAttendanceData(selectedslotID!);
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedDate.month == 12) {
        _selectedDate = DateTime(
            _selectedDate.year + 1, 1); // Go to January of the next year
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      }
      _fetchAttendanceData(selectedslotID!);
    });
  }

  void _updateSummary() {
    int totalClassesTaken = 0;
    int presentCount = 0;
    int absentCount = 0;
    int classNotTakenCount = 0;

    _attendanceData.forEach((_, dateData) {
      // Extract the status from the nested map
      String? status = dateData['status'];

      if (status != null) {
        totalClassesTaken++;
        if (status == 'present') {
          presentCount++;
        } else if (status == 'absent') {
          absentCount++;
        } else if (status == 'No class') {
          classNotTakenCount++;
        }
      }
    });

    setState(() {
      _summaryData = {
        'total_classes_taken': totalClassesTaken,
        'present': presentCount,
        'absent': absentCount,
        'No class': classNotTakenCount,
      };
    });
  }

  String getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
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
                      Navigator.pop(context);
                    },
                    child: Image.asset('assets/back_button.png', height: 50)),
                const SizedBox(width: 20),
                const Text(
                  'Attendance',
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
        body: SingleChildScrollView(
            child: isWeb
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 5, right: 15),
                          child: _buildSlotList(),
                        ),
                        // Calendar Section
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 15, bottom: 8, right: 20),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            width: 420,
                            height: 360,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withValues(alpha: 0.5), // Shadow color
                                  spreadRadius: 1, // Spread radius
                                  blurRadius: 8, // Blur radius
                                  offset: const Offset(
                                      0, 3), // Only apply shadow on the bottom
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Calendar Header
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios_outlined,
                                          size: 15,
                                        ),
                                        onPressed: _prevMonth,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            _navigateToYearMonthPicker(context);
                                          },
                                          child: Text(
                                            _monthYearString,
                                            style:
                                                const TextStyle(fontSize: 17),
                                          )),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          size: 15,
                                        ),
                                        onPressed: _nextMonth,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedDate = DateTime.now();
                                              _fetchAttendanceData(
                                                  selectedslotID!);
                                            });
                                          },
                                          child: const Text(
                                            'Today',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              color: Color(0xFF48116A),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                // Day Headers
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: weekdays
                                        .map((day) => Center(
                                              child: Text(
                                                day,
                                                style: const TextStyle(
                                                    color: Color(0xFF48116A),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                // Calendar Dates
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 7,
                                        childAspectRatio: 0.5,
                                        mainAxisSpacing: 5,
                                        crossAxisSpacing: 5,
                                        mainAxisExtent: 45,
                                      ),
                                      itemCount:
                                          _startingWeekday + _daysInMonth,
                                      itemBuilder: (context, index) {
                                        if (index < _startingWeekday) {
                                          return const SizedBox.shrink();
                                        }

                                        int day = index - _startingWeekday + 1;
                                        bool isToday =
                                            day == DateTime.now().day &&
                                                _selectedDate.month ==
                                                    DateTime.now().month &&
                                                _selectedDate.year ==
                                                    DateTime.now().year;

                                        // Check if the day exists in _attendanceData and extract status
                                        Map<String, String>? attendanceInfo =
                                            _attendanceData[day];
                                        String? id = attendanceInfo?['id'];
                                        String status =
                                            attendanceInfo?['status'] ??
                                                "no_data";

                                        return GestureDetector(
                                          onTap: () {
                                            if (id != null) {
                                              // Show a dialog to update the status
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text(
                                                      "Update Attendance for $day"),
                                                  content:
                                                      DropdownButton<String>(
                                                    value: status,
                                                    items: const [
                                                      DropdownMenuItem(
                                                          value: 'present',
                                                          child:
                                                              Text('Present')),
                                                      DropdownMenuItem(
                                                          value: 'absent',
                                                          child:
                                                              Text('Absent')),
                                                      DropdownMenuItem(
                                                          value: 'No class',
                                                          child:
                                                              Text('No class')),
                                                    ],
                                                    onChanged: (newStatus) {
                                                      if (newStatus != null) {
                                                        _submitAttendance(
                                                                id: id,
                                                                status:
                                                                    newStatus)
                                                            .then((_) {
                                                          Navigator.pop(
                                                              context); // Close the dialog after updating
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "No ID found for this date!")),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: status == "no_data"
                                                  ? Colors.transparent
                                                  : Colors.yellow,
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: status == "present"
                                                    ? Colors.green
                                                    : status == "absent"
                                                        ? Colors.red
                                                        : Colors.grey[400],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isToday
                                                      ? const Color(0xFF48116A)
                                                      : Colors.white,
                                                  width: isToday ? 3 : 0,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$day',
                                                  style: TextStyle(
                                                    color: status == "no_data"
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Attendance Summary Section
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildSummaryCard('Present',
                                  _summaryData['present'], Colors.green),
                              _buildSummaryCard(
                                  'Absent', _summaryData['absent'], Colors.red),
                              _buildSummaryCard(
                                  'Holiday',
                                  _summaryData['No class'],
                                  Colors.grey.shade400),
                              _buildSummaryCard(
                                  'Total Classes Taken',
                                  _summaryData['total_classes_taken'],
                                  Colors.yellow),
                            ],
                          ),
                        ),
                      ])
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 5, right: 15),
                          child: _buildSlotList(),
                        ),
                        // Calendar Section
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 15, bottom: 8, right: 20),
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            width: 380,
                            height: 330,
                            decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey
                                      .withValues(alpha: 0.5), // Shadow color
                                  spreadRadius: 1, // Spread radius
                                  blurRadius: 8, // Blur radius
                                  offset: const Offset(
                                      0, 3), // Only apply shadow on the bottom
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Calendar Header
                                Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_ios_outlined,
                                          size: 15,
                                        ),
                                        onPressed: _prevMonth,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            _navigateToYearMonthPicker(context);
                                          },
                                          child: Text(
                                            _monthYearString,
                                            style:
                                                const TextStyle(fontSize: 17),
                                          )),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          size: 15,
                                        ),
                                        onPressed: _nextMonth,
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedDate = DateTime.now();
                                              _fetchAttendanceData(
                                                  selectedslotID!);
                                            });
                                          },
                                          child: const Text(
                                            'Today',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 18,
                                              color: Color(0xFF48116A),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                // Day Headers
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: weekdays
                                        .map((day) => Center(
                                              child: Text(
                                                day,
                                                style: const TextStyle(
                                                    color: Color(0xFF48116A),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                // Calendar Dates
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 7,
                                        childAspectRatio: 0.5,
                                        mainAxisExtent: 45,
                                      ),
                                      itemCount:
                                          _startingWeekday + _daysInMonth,
                                      itemBuilder: (context, index) {
                                        if (index < _startingWeekday) {
                                          return const SizedBox.shrink();
                                        }

                                        int day = index - _startingWeekday + 1;
                                        bool isToday =
                                            day == DateTime.now().day &&
                                                _selectedDate.month ==
                                                    DateTime.now().month &&
                                                _selectedDate.year ==
                                                    DateTime.now().year;

                                        // Check if the day exists in _attendanceData and extract status
                                        Map<String, String>? attendanceInfo =
                                            _attendanceData[day];
                                        String? id = attendanceInfo?['id'];
                                        String status =
                                            attendanceInfo?['status'] ??
                                                "no_data";

                                        return GestureDetector(
                                          onTap: () {
                                            if (id != null) {
                                              // Show a dialog to update the status
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text(
                                                      "Update Attendance for $day"),
                                                  content: StatefulBuilder(
                                                    builder:
                                                        (context, setState) {
                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          RadioListTile<String>(
                                                            title: const Text(
                                                                'Present'),
                                                            value: 'present',
                                                            groupValue: status,
                                                            onChanged:
                                                                (newStatus) {
                                                              if (newStatus !=
                                                                  null) {
                                                                _submitAttendance(
                                                                        id: id,
                                                                        status:
                                                                            newStatus)
                                                                    .then((_) {
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              }
                                                            },
                                                          ),
                                                          RadioListTile<String>(
                                                            title: const Text(
                                                                'Absent'),
                                                            value: 'absent',
                                                            groupValue: status,
                                                            onChanged:
                                                                (newStatus) {
                                                              if (newStatus !=
                                                                  null) {
                                                                _submitAttendance(
                                                                        id: id,
                                                                        status:
                                                                            newStatus)
                                                                    .then((_) {
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              }
                                                            },
                                                          ),
                                                          RadioListTile<String>(
                                                            title: const Text(
                                                                'No class'),
                                                            value: 'No class',
                                                            groupValue: status,
                                                            onChanged:
                                                                (newStatus) {
                                                              if (newStatus !=
                                                                  null) {
                                                                _submitAttendance(
                                                                        id: id,
                                                                        status:
                                                                            newStatus)
                                                                    .then((_) {
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        "No ID found for this date!")),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: status == "no_data"
                                                  ? Colors.transparent
                                                  : Colors.yellow,
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: status == "present"
                                                    ? Colors.green
                                                    : status == "absent"
                                                        ? Colors.red
                                                        : Colors.grey[400],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isToday
                                                      ? const Color(0xFF48116A)
                                                      : Colors.white,
                                                  width: isToday ? 3 : 0,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$day',
                                                  style: TextStyle(
                                                    color: status == "no_data"
                                                        ? Colors.black
                                                        : Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Attendance Summary Section
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              _buildSummaryCard('Present',
                                  _summaryData['present'], Colors.green),
                              _buildSummaryCard(
                                  'Absent', _summaryData['absent'], Colors.red),
                              _buildSummaryCard(
                                  'Holiday',
                                  _summaryData['No class'],
                                  Colors.grey.shade400),
                              _buildSummaryCard(
                                  'Total Classes Taken',
                                  _summaryData['total_classes_taken'],
                                  Colors.yellow),
                            ],
                          ),
                        ),
                      ])));
  }

  Widget _buildSlotList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(slots.length, (index) {
          bool isSelected = selectedSlotIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSlotIndex = index;
                selectedslotID = slots[index]['slotID']!; // Get slotID
                _fetchAttendanceData(selectedslotID!); // Pass slotID
                _updateSummary();
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    '${slots[index]['courseName']!}, ', // Display slot name
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    slots[index]['timeSlot']!, // Display slot name
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    int? count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Container(
        width: 400,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.justify,
                    count == null ? '0' : ' $count ',
                    style: const TextStyle(color: Colors.black54, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                ' $title',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class YearMonthPicker extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;

  const YearMonthPicker(
      {super.key, required this.selectedYear, required this.selectedMonth});

  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final List<int> years =
        List.generate(currentYear - 2000 + 1, (index) => 2000 + index);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Year and Month'),
      ),
      body: ListView.builder(
        itemCount: years.length,
        itemBuilder: (context, index) {
          int year = years[index];
          return ExpansionTile(
            title: Text('$year'),
            children: List.generate(12, (monthIndex) {
              return ListTile(
                title: Text('Month: ${monthIndex + 1}'),
                onTap: () {
                  Navigator.pop(
                      context, {'year': year, 'month': monthIndex + 1});
                },
              );
            }),
          );
        },
      ),
    );
  }
}
