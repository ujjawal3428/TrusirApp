import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trusir/common/api.dart';

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
  String? course = 'English\n(8-9 AM)';
  List<String> _courses = [];
  List<String> combinedItems = [];
  final List<String> timeSlots = [
    '8-9 AM',
    '9-10 AM',
    '10-11 AM',
    '11-12 PM',
    '12-1 PM',
    '1-2 PM',
    '2-3 PM',
    '3-4 PM',
    '4-5PM',
    '5-6 PM',
    '6-7 PM',
    '7-8 PM'
  ];

  Future<void> fetchCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-course/testID'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _courses = List<String>.from(data);
            combinedItems = generateDropdownItems(_courses, timeSlots);
            print(generateDropdownItems(_courses, timeSlots));
          });
        }
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      print('Error fetching courses: $e');
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
    _fetchAttendanceData();
    fetchCourses();
  }

  // Generate dropdown items by pairing courses with time slots
  List<String> generateDropdownItems(
      List<String> courses, List<String> timeSlots) {
    final List<String> dropdownItems = [];
    for (final course in courses) {
      for (final slot in timeSlots) {
        dropdownItems
            .add('$course\n($slot)'); // Pair course with each time slot
      }
    }
    return dropdownItems;
  }

  void _fetchAttendanceData() {
    final month = _selectedDate.month;
    final year = _selectedDate.year;

    setState(() {
      _attendanceData.clear(); // Clear old data before fetching new data
    });

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
        _fetchAttendanceData();
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
            child: Column(children: [
          // Calendar Section
          Padding(
            padding:
                const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 15),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Shadow color
                    spreadRadius: 1, // Spread radius
                    blurRadius: 8, // Blur radius
                    offset:
                        const Offset(0, 3), // Only apply shadow on the bottom
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_outlined),
                          onPressed: _prevMonth,
                        ),
                        Text(
                          _monthYearString,
                          style: const TextStyle(fontSize: 17),
                        ),
                        IconButton(
                            icon:
                                const Icon(Icons.keyboard_arrow_down_outlined),
                            onPressed: () {
                              _navigateToYearMonthPicker(context);
                            }),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_outlined),
                          onPressed: _nextMonth,
                        ),
                        _buildDropdownField('Course', selectedValue: course,
                            onChanged: (value) {
                          setState(() {
                            course = value;
                            _fetchAttendanceData();
                            _updateSummary();
                          });
                        }, items: combinedItems),
                      ],
                    ),
                  ),
                  // Day Headers
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: weekdays
                          .map((day) => Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                      color: Color(0xFF48116A),
                                      fontWeight: FontWeight.bold),
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
                                mainAxisExtent: 45),
                        itemCount: _startingWeekday + _daysInMonth,
                        itemBuilder: (context, index) {
                          if (index < _startingWeekday) {
                            return const SizedBox.shrink();
                          }
                          int day = index - _startingWeekday + 1;
                          bool isToday = day == DateTime.now().day &&
                              _selectedDate.month == DateTime.now().month &&
                              _selectedDate.year == DateTime.now().year;
                          String status = _attendanceData[day] ?? "no_data";
                          return GestureDetector(
                            onTap: () {
                              _showAttendanceDialog(day, status);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: isToday
                                            ? const Color(0xFF48116A)
                                            : Colors.white,
                                        width: isToday ? 3 : 0)),
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
                _buildSummaryCard('Total Classes Taken',
                    _summaryData['total_classes_taken'], Colors.yellow),
                _buildSummaryCard(
                    'Present', _summaryData['present'], Colors.green),
                _buildSummaryCard('Absent', _summaryData['absent'], Colors.red),
                _buildSummaryCard('Class not taken',
                    _summaryData['class_not_taken'], Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ])));
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
                    ' $count',
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

Widget _buildDropdownField(
  String hintText, {
  String? selectedValue,
  required ValueChanged<String?> onChanged,
  required List<String> items,
}) {
  return SizedBox(
    height: 50,
    width: 110,
    child: DropdownButtonFormField<String>(
      value: selectedValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: hintText,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.only(left: 13),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
    ),
  );
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
