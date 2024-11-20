import 'package:flutter/material.dart';

class Notice {
  final String paymenttype;
  final String date;
  final String transactionid;
  final String paymentmethod;
  final String amount;
  final String time;

  Notice({
    required this.paymenttype,
    required this.paymentmethod,
    required this.transactionid,
    required this.date,
    required this.time,
    required this.amount,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      paymenttype: json['payment_type'],
      paymentmethod: json['payment_method'],
      date: json['date'],
      time: json['time'],
      amount: json['amount'],
      transactionid: json['transaction_id'],
    );
  }
}

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
                'Notice',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 15, top: 0),
              child: Column(
                children: [
                  _buildnoticetile(
                      'Republic Day Holiday',
                      'January 26, 2023',
                      'The class will have a off on 26th Jan 20233 on occasion of Republic Day',
                      const Color.fromARGB(255, 251, 202, 218),
                      'assets/bell.png'),
                  _buildnoticetile(
                      'Republic Day Holiday',
                      'January 26, 2023',
                      'The class will have a off on 26th Jan 20233 on occasion of Republic Day',
                      const Color.fromARGB(255, 182, 211, 255),
                      'assets/bell.png'),
                  _buildnoticetile(
                      'Republic Day Holiday',
                      'January 26, 2023',
                      'The class will have a off on 26th Jan 20233 on occasion of Republic Day',
                      const Color.fromARGB(255, 255, 229, 142),
                      'assets/bell.png'),
                  TextButton(
                      onPressed: () {}, child: const Text('Load More...'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildnoticetile(String title, String date, String notice,
      Color bgcolor, String iconPath) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20, right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 386,
            height: 136,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bgcolor,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 55, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Posted on : $date',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notice,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Image.asset(
              iconPath,
              width: 36,
              height: 36,
            ),
          ),
        ],
      ),
    );
  }
}
