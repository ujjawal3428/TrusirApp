import 'package:flutter/material.dart';

void main() {
  runApp(const AttendancePage());
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();
  List<String> weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  DateTime get _firstDayOfMonth {
    return DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  int get _daysInMonth {
    return DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
  }

  int get _startingWeekday {
    return _firstDayOfMonth.weekday;
  }

  List<int> get _dates {
    List<int> dates = List.generate(_daysInMonth, (index) => index + 1);
    return dates;
  }

  String get _monthYearString {
    return "${getMonthName(_selectedDate.month)} ${_selectedDate.year}";
  }

  void _prevMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
    });
  }

  void _showMonthYearPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Month Selector
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    int month = index + 1;
                    bool isSelected = month == _selectedDate.month;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedDate = DateTime(_selectedDate.year, month, 1);
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          getMonthName(month),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              // Year Selector
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      int year = DateTime.now().year - 25 + index;
                      bool isSelected = year == _selectedDate.year;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime(year, _selectedDate.month, 1);
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
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
              ),
              Container(
                width: 386,
                height: 397,
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
                          GestureDetector(
                            onTap: _showMonthYearPicker,
                            child: Row(
                              children: [
                                Text(
                                  _monthYearString,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_right, color: Colors.white),
                              onPressed: _nextMonth,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                            },
                            child: const Text(
                              'Today',
                              style: TextStyle(fontSize: 16, color: Colors.blue),
                            ),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ))
                            .toList(),
                      ),
                    ),
                    // Calendar Dates
                    SizedBox(
                      height: 280,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _startingWeekday + _daysInMonth,
                        itemBuilder: (context, index) {
                          if (index < _startingWeekday) {
                            return const SizedBox.shrink();
                          }
                          int date = _dates[index - _startingWeekday];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, date);
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedDate.day == date
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                // Removed the border here
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
      ),
    );
  }
}




