import 'package:flutter/material.dart';

class Addtestseries extends StatefulWidget {
  const Addtestseries({super.key});

  @override
  State<Addtestseries> createState() => _AddtestseriesState();
}

class _AddtestseriesState extends State<Addtestseries> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final List<String> subjects = ['Mathematics', 'Science', 'English', 'History'];

  void _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
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
                'Test Series',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Test Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Test Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the test name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject Dropdown
              DropdownButtonFormField<String>(
                value: selectedSubject,
                items: subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (String? value) {
                  setState(() {
                    selectedSubject = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                        : 'No date selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Picker
              InkWell(
                onTap: _pickTime,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Time',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    selectedTime != null
                        ? '${selectedTime!.hour}:${selectedTime!.minute} ${selectedTime!.period == DayPeriod.am ? 'AM' : 'PM'}'
                        : 'No time selected',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 40,
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Here, implement the file picker logic for questions
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Questions', style: 
                      TextStyle(fontSize: 12),),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 150,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Here, implement the file picker logic for answers
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Answers',style: 
                      TextStyle(fontSize: 12),),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission (No API integration)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test uploaded successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF48116A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Upload Test',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
