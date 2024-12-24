import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trusir/student/student_payment_page.dart';

class Fees {
  final String paymenttype;
  final String date;
  final String transactionid;
  final String paymentmethod;
  final String amount;
  final String time;

  Fees({
    required this.paymenttype,
    required this.paymentmethod,
    required this.transactionid,
    required this.date,
    required this.time,
    required this.amount,
  });

  factory Fees.fromJson(Map<String, dynamic> json) {
    return Fees(
      paymenttype: json['payment_type'],
      paymentmethod: json['payment_method'],
      date: json['date'],
      time: json['time'],
      amount: json['amount'],
      transactionid: json['transaction_id'],
    );
  }
}

class FeePaymentScreen extends StatefulWidget {
  const FeePaymentScreen({super.key});

  @override
  State<FeePaymentScreen> createState() => _FeePaymentScreenState();
}

class _FeePaymentScreenState extends State<FeePaymentScreen> {
  List<Fees> feepayment = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;

  final apiBase = '$baseUrl/fee-report/';

  Future<void> fetchFeeDetails({int page = 1}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    final url = '$apiBase$userID?page=$page&data_per_page=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        if (page == 1) {
          // Initial fetch
          feepayment = data.map((json) => Fees.fromJson(json)).toList();
        } else {
          // Append new data
          feepayment.addAll(data.map((json) => Fees.fromJson(json)));
        }

        isLoading = false;
        isLoadingMore = false;

        // Check if more data is available
        if (data.isEmpty) {
          hasMore = false;
        }
      });
    } else {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      throw Exception('Failed to load fees');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFeeDetails();
  }

  final List<Color> cardColors = [
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.pink.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/back_button.png', height: 50)),
          const SizedBox(width: 20),
          const Text(
            'Fee Payment',
            style: TextStyle(
              color: Color(0xFF48116A),
              fontSize: 25,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wallet_rounded,
                size: 20,
                color: Color.fromARGB(255, 28, 37, 136),
              ),
              SizedBox(width: 1),
              Text(
                '₹ 10,000.00',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ]),
        toolbarHeight: 70,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0, right: 17),
                        child: Container(
                          width: 386,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC22054),
                                Color(0xFF48116A),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10.0, top: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Current Month',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          '24 Jan 2025 - Today',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Total No. of Classes: 09',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Image.asset(
                                    'assets/money@3x.png',
                                    width: 130,
                                    height: 130,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0, left: 23),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Previous month',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...feepayment.asMap().entries.map((entry) {
                        int index = entry.key;
                        Fees payment = entry.value;

                        // Cycle through colors using the modulus operator
                        Color cardColor = cardColors[index % cardColors.length];

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20, bottom: 14),
                          child: Container(
                            width: 386,
                            height: 136,
                            decoration: BoxDecoration(
                              color: cardColor, // Apply dynamic color
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, top: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            payment.paymenttype,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            payment.transactionid,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            payment.paymentmethod,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '₹ ${payment.amount}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            payment.date,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            payment.time,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (hasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: isLoadingMore
                              ? const CircularProgressIndicator()
                              : TextButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoadingMore = true;
                                      currentPage++;
                                    });
                                    fetchFeeDetails(page: currentPage);
                                  },
                                  child: const Text('Load More...'),
                                ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: _buildPayButton(context),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentPaymentPage(),
            ),
          );
        },
        child: Image.asset(
          'assets/pay_fee.png',
          width: double.infinity,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
