import 'package:flutter/material.dart';

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

  List<int> get _dates {
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

    // Simulating an API request with the selected month and year
    final apiResponse = {
      "month": getMonthName(month), // Get month name based on selected date
      "year": year,
      "attendance": {
        "01": "present",
        "02": "absent",
        "03": "absent",
        "04": "present",
        "05": "present",
        "06": "absent",
        "07": "present",
        "08": "present",
        "09": "present",
        "10": "present",
        "11": "present",
        "12": "present",
        "13": "absent",
        "14": "present",
        "15": "present",
        "16": "present",
        "17": "absent",
        "18": "absent",
        "19": "present",
        "20": "absent",
        "21": "present",
        "22": "present",
        "23": "present",
        "24": "class_not_taken",
        "25": "class_not_taken",
        "26": "present",
        "27": "present",
        "28": "present",
        "29": "present",
        "30": "present",
        "31": "present"
      },
      "summary": {
        "total_classes_taken": 25,
        "present": 21,
        "absent": 4,
        "class_not_taken": 2
      }
    };

    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        // Map the attendance data to the desired type
        _attendanceData = (apiResponse["attendance"] as Map<String, dynamic>)
            .map<int, String>(
                (key, value) => MapEntry(int.parse(key), value as String));

        // Convert summary data safely
        _summaryData = Map<String, int>.from(apiResponse["summary"] as Map);
      });
    });
  }

  void _prevMonth() {
    setState(() {
      if (_selectedDate.month == 1) {
        _selectedDate = DateTime(
            _selectedDate.year - 1, 12); // Go to December of the previous year
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Calendar Section
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 14),
                child: Container(
                  width: 386,
                  height: 400,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/whitebg@4x.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      // Calendar Header
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: _prevMonth,
                            ),
                            Text(
                              _monthYearString,
                              style: const TextStyle(fontSize: 20),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: _nextMonth,
                            ),
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
                            int date = _dates[index - _startingWeekday];
                            String? attendanceStatus = _attendanceData[date];
                            Color statusColor = attendanceStatus == "present"
                                ? Colors.green
                                : attendanceStatus == "absent"
                                    ? Colors.red
                                    : attendanceStatus == "class_not_taken"
                                        ? Colors.grey
                                        : Colors.transparent;
                
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = DateTime(_selectedDate.year,
                                      _selectedDate.month, date);
                                });
                              },
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _selectedDate.day == date
                                          ? Colors.blueAccent
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$date',
                                      style: TextStyle(
                                        color: _selectedDate.day == date
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (attendanceStatus != null)
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor: statusColor,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Attendance Summary
             Padding(
                padding: const EdgeInsets.all(16.0),
                child:  Expanded(
                  child: SizedBox(
                    height: 150,
                    width: 350,
                    child: Column(
                         children: [
                          Row(
                            children: [
                              Container(
                                color: Colors.yellow,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                ),
                                child: const Center(child: Text("25")),
                              ),
                              const SizedBox(width: 10,),
                              const Text('Total Classes'),
                            ],
                          ),
                          const SizedBox(height: 5,),
                          Row(
                            children: [
                              Container(
                                color: Colors.green,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                ),
                                child: const Center(child: Text("24")),
                              ),
                              const SizedBox(width: 10,),
                              const Text('Present'),
                            ],
                          ),
                           const SizedBox(height: 5,),
                          Row(
                            children: [
                              Container(
                                color: Colors.red,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                ),
                                child: const Center(child: Text("4")),
                              ),
                              const SizedBox(width: 10,),
                              const Text('Absent'),
                            ],
                          ),
                           const SizedBox(height: 5,),
                          Row(
                            children: [
                              Container(
                                color: Colors.grey.shade300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),

                                ),
                                child: const Center(child: Text("2")),
                              ),
                              const SizedBox(width: 10,),
                              const Text('Class not taken'),
                            ],
                          ),
                         ],
                    ),
                  
                  ),)
                ),

                 const SizedBox(height: 10),
                        Center(
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
                                 ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Approval Text Sent!"),
                      ),
                    );
                              },
                              child: const Text(
                                'Send Approval',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        )]))));
              
  }}