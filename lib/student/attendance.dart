import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  AttendancePageState createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  late Map<DateTime, String> attendanceData; // To store attendance status
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize attendance data (this will be fetched from API in real use case)
    attendanceData = {
      DateTime(2022, 12, 1): "present",
      DateTime(2022, 12, 2): "absent",
      DateTime(2022, 12, 3): "present",
      DateTime(2022, 12, 4): "not_taken",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 1, 1),
            focusedDay: selectedDate,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                String? status = attendanceData[date];
                Color color;
                switch (status) {
                  case "present":
                    color = Colors.green;
                    break;
                  case "absent":
                    color = Colors.red;
                    break;
                  case "not_taken":
                    color = Colors.grey;
                    break;
                  default:
                    color = Colors.transparent;
                }
                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              attendanceInfo("Total classes taken", "25", Colors.orange),
              attendanceInfo("Present", "21", Colors.green),
              attendanceInfo("Absent", "4", Colors.red),
              attendanceInfo("Class not taken", "2", Colors.grey),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text("Send Approval"),
          ),
        ],
      ),
    );
  }

  Widget attendanceInfo(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }
}
