import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  Map<int, String> _attendanceData = {}; // Simulated API data (day: status)
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
    // Simulated API call
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _attendanceData = {
          1: "Present",
          2: "Absent",
          3: "Holiday",
          5: "Present",
          7: "Absent",
          10: "Holiday",
          12: "Half-Day",
          15: "Present",
          18: "Absent",
          20: "Half-Day",
          25: "Holiday",
        };
      });
    });
  }

  void _prevMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      _fetchAttendanceData(); // Refresh data for the new month
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      _fetchAttendanceData(); // Refresh data for the new month
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
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/dikshaback@2x.png',
                    width: 58,
                    height: 58,
                  ),
                  const Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30.0),
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          color: Color(0xFF48116A),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 386,
              height: 450,
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
                        Color statusColor = attendanceStatus == "Present"
                            ? Colors.green
                            : attendanceStatus == "Absent"
                                ? Colors.red
                                : attendanceStatus == "Holiday"
                                    ? Colors.orange
                                    : attendanceStatus == "Half-Day"
                                        ? Colors.blue
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
          ],
        ),
      ),
    );
  }
}
