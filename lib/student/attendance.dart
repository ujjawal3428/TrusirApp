import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  Map<int, String> _attendanceData = {}; // Day: Status
  Map<String, int> _summaryData = {}; // Summary details
  List<String> weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

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
    _fetchAttendanceData();
  }

  void _fetchAttendanceData() {
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    fetchAttendanceData(month, year).then((apiResponse) {
      final monthKey = month.toString();
      if (apiResponse.containsKey(monthKey)) {
        final dataForMonth = apiResponse[monthKey] as Map<String, dynamic>;
        setState(() {
          _attendanceData = (dataForMonth['attendance'] as Map<String, dynamic>)
              .map<int, String>(
                  (key, value) => MapEntry(int.parse(key), value));
        });
        _updateSummary(); // Update summary after fetching data
      } else {
        print('No data available for month: $month, year: $year');
      }
    }).catchError((error) {
      print("Error fetching attendance data: $error");
    });
  }

  Future<Map<String, dynamic>> fetchAttendanceData(int month, int year) async {
    final url = Uri.parse(
        'https://trusirapi.onrender.com/attendance?year=$year&month=$month');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  Future<void> _submitAttendance(
      {required int day, required String status}) async {
    final url = Uri.parse('https://trusirapi.onrender.com/attendance/update');
    final payload = {
      "year": _selectedDate.year.toString(),
      "month": _selectedDate.month.toString(),
      "date": day.toString().padLeft(2, '0'),
      "status": status,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          _attendanceData[day] = status;
          _updateSummary(); // Update summary after submitting data
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
      _fetchAttendanceData();
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
      _fetchAttendanceData();
    });
  }

  void _updateSummary() {
    int totalClassesTaken = 0;
    int presentCount = 0;
    int absentCount = 0;
    int classNotTakenCount = 0;

    _attendanceData.forEach((_, status) {
      totalClassesTaken++;
      if (status == 'present') {
        presentCount++;
      } else if (status == 'absent') {
        absentCount++;
      } else if (status == 'class_not_taken') {
        classNotTakenCount++;
      }
    });

    setState(() {
      _summaryData = {
        'total_classes_taken': totalClassesTaken,
        'present': presentCount,
        'absent': absentCount,
        'class_not_taken': classNotTakenCount,
      };
    });
  }

  String getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  void _showAttendanceDialog(int day, String status) {
    String selectedStatus = status; // Default value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "Update Attendance for $day ${getMonthName(_selectedDate.month)}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Present"),
                value: "present",
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                  Navigator.of(context).pop();
                  _showAttendanceDialog(day, "present"); // Refresh dialog
                },
              ),
              RadioListTile<String>(
                title: const Text("Absent"),
                value: "absent",
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                  Navigator.of(context).pop();
                  _showAttendanceDialog(day, "absent"); // Refresh dialog
                },
              ),
              RadioListTile<String>(
                title: const Text("Class Not Taken"),
                value: "class_not_taken",
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                  });
                  Navigator.of(context).pop();
                  _showAttendanceDialog(
                      day, "class_not_taken"); // Refresh dialog
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitAttendance(day: day, status: selectedStatus);
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
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
                const SizedBox(width: 5),
                const Text(
                  'Attendance',
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
        
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
            child: Column(
                children: [
          // Calendar Section
          Padding(
            padding: const EdgeInsets.only(top: 30, left : 14.0, right: 14),
            child: Container(

              width: 386,
              height: 350,
              decoration: BoxDecoration(
              color: Colors.white70,
                borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // Shadow color
                  spreadRadius: 1, // Spread radius
                  blurRadius: 8,   // Blur radius
                  offset: const Offset(0, 3), // Only apply shadow on the bottom
                ),
              ],
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_left),
                          onPressed: _prevMonth,
                        ),
                        Text(
                          _monthYearString,
                          style: const TextStyle(fontSize: 15),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: _nextMonth,
                        ),
                        const SizedBox(width: 20,),
                        const Text('Today',
                        style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                         color: Color(0xFF48116A),),)
                      ],
                    ),
                  ),
                  // Day Headers
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekdays
                          .map((day) => Text(
                                day,
                                style: const TextStyle(
                                  color: Color(0xFF48116A),
                                    fontWeight: FontWeight.bold),
                              ))
                          .toList(),
                    ),
                  ),
                  // Calendar Dates
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _startingWeekday + _daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < _startingWeekday) {
                          return const SizedBox.shrink();
                        }
                        int day = index - _startingWeekday + 1;
                        String status = _attendanceData[day] ?? "no_data";
                        return GestureDetector(
                          onTap: () {
                            _showAttendanceDialog(day, status);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: status == "present"
                                  ? Colors.green
                                  : status == "absent"
                                      ? Colors.red
                                      : Colors.grey[400],
                              borderRadius: BorderRadius.circular(8),
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
                        );
                      },
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
                _buildSummaryCard('Total Classes Taken',
                    _summaryData['total_classes_taken'], Colors.yellow),
                _buildSummaryCard(
                    'Present', _summaryData['present'], Colors.green),
                _buildSummaryCard(
                    'Absent', _summaryData['absent'], Colors.red),
                _buildSummaryCard('Class not taken',
                    _summaryData['class_not_taken'], Colors.grey.shade200),  
              ],
            ),
          ),
           const SizedBox(height: 50,),
                     Padding(
                       padding: const EdgeInsets.only(left: 10.0, right: 10),
                       child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF045C19), Color(0xFF77D317)],
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                },
                                child: const Text(
                                  'Send Approval',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ),
                     ),
        ])
        )
        );
  }

  Widget _buildSummaryCard(
    String title,
    int? count,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 5),
      child: Container(
        width: 400,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Container(
                height: 39,
                width: 38,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    ' $count',
                    style: const TextStyle(color: Colors.black, fontSize: 20),
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
