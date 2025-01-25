import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:trusir/student/student_payment_page.dart';

class Fees {
  final String paymentType;
  final String transactionId;
  final String paymentMethod;
  final String amount;
  final String date;
  final String time;

  Fees({
    required this.paymentType,
    required this.transactionId,
    required this.paymentMethod,
    required this.amount,
    required this.date,
    required this.time,
  });

  factory Fees.fromJson(Map<String, dynamic> json) {
    // Extract date and time from the created_at field
    final createdAt = json['created_at'] ?? '';
    final dateTime = DateTime.tryParse(createdAt);

    // Format date and time
    final formattedDate =
        dateTime != null ? DateFormat('yyyy-MM-dd').format(dateTime) : '';
    final formattedTime = dateTime != null
        ? DateFormat('h:mm a').format(dateTime) // 12-hour format with AM/PM
        : '';

    return Fees(
      paymentType: json['transactionType'] ?? '',
      transactionId: json['transactionID'] ?? '',
      paymentMethod: json['transactionName'] ?? '',
      amount: json['amount'] ?? '0', // Ensure a default value is provided
      date: formattedDate,
      time: formattedTime,
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
  double totalAmount = 0;

  final apiBase = '$baseUrl/get-fee-payment-info/';

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

        // Calculate total amount while filtering out non-numeric values
        totalAmount = feepayment.fold<double>(
          0.0,
          (sum, fee) {
            final feeAmount = double.tryParse(fee.amount) ?? 0.0;
            return sum + feeAmount;
          },
        );

        print(totalAmount);
        print(response.body);

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
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset('assets/back_button.png', height: 50)),
              const SizedBox(width: 10),
              const Text(
                'Fee Payment',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.08,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wallet_rounded,
                size: 20,
                color: Color.fromARGB(255, 28, 37, 136),
              ),
              Text(
                '₹ $totalAmount',
                style: const TextStyle(
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
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 900;

          return isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: isWideScreen
                      ? Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCurrentMonthCard(
                                    MediaQuery.of(context).size.width * 0.4,
                                    isWideScreen),
                                // _buildPayButton(context),
                              ],
                            ),
                            const SizedBox(width: 40),
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(top: 20.0, left: 23),
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
                                  const SizedBox(height: 20),
                                  ...feepayment.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Fees payment = entry.value;

                                    // Cycle through colors using the modulus operator
                                    Color cardColor =
                                        cardColors[index % cardColors.length];

                                    // Extract transaction ID before the comma
                                    String displayedTransactionId =
                                        payment.transactionId.contains(',')
                                            ? payment.transactionId
                                                .split(',')
                                                .first
                                                .trim()
                                            : payment.transactionId.trim();

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, bottom: 15),
                                      child: Container(
                                        width: 386,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color:
                                              cardColor, // Apply dynamic color
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0, top: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        payment.paymentType,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      // Display only the part of transactionId before the comma
                                                      Text(
                                                        displayedTransactionId,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Text(
                                                        payment.paymentMethod,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '₹ ${payment.amount}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        payment.date,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Text(
                                                        payment.time,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: isLoadingMore
                                          ? const CircularProgressIndicator()
                                          : TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLoadingMore = true;
                                                  currentPage++;
                                                });
                                                fetchFeeDetails(
                                                    page: currentPage);
                                              },
                                              child: const Text('Load More...'),
                                            ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 10),
                                  _buildCurrentMonthCard(
                                      MediaQuery.of(context).size.width * 0.9,
                                      isWideScreen),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 15.0,
                                    ),
                                    child: Center(
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
                                  const SizedBox(height: 15),
                                  ...feepayment.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    Fees payment = entry.value;
                                    String displayedTransactionId =
                                        payment.transactionId.contains(',')
                                            ? payment.transactionId
                                                .split(',')
                                                .first
                                                .trim()
                                            : payment.transactionId.trim();

                                    // Cycle through colors using the modulus operator
                                    Color cardColor =
                                        cardColors[index % cardColors.length];

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5, bottom: 15),
                                      child: Container(
                                        width: 386,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color:
                                              cardColor, // Apply dynamic color
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0, top: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        payment.paymentType,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        displayedTransactionId,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Text(
                                                        payment.paymentMethod,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        '₹ ${payment.amount}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        payment.date,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 18),
                                                      Text(
                                                        payment.time,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: isLoadingMore
                                          ? const CircularProgressIndicator()
                                          : TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  isLoadingMore = true;
                                                  currentPage++;
                                                });
                                                fetchFeeDetails(
                                                    page: currentPage);
                                              },
                                              child: const Text('Load More...'),
                                            ),
                                    ),
                                ],
                              ),
                            ),
                            // Positioned(
                            //     bottom: -22,
                            //     left: 0,
                            //     right: 0,
                            //     child: _buildPayButton(context)),
                          ],
                        ),
                );
        }),
      ),
    );
  }

  Widget _buildCurrentMonthCard(double width, bool isLargeScreen) {
    return Container(
      width: width,
      height: isLargeScreen ? 150 : 110,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF48116A), Color(0xFFC22054)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color.fromARGB(255, 160, 40, 176).withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 3,
              offset: const Offset(2, 2)),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Month',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '24 Jan 2025 - Today',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                Text(
                  'Total No. of Classes: 09',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/money@3x.png',
            width: 130,
            height: 130,
          ),
        ],
      ),
    );
  }

  // Widget _buildPayButton(BuildContext context) {
  //   return Center(
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => const StudentPaymentPage(),
  //           ),
  //         );
  //       },
  //       child: Image.asset(
  //         'assets/pay_fee.png',
  //         width: 300,
  //         height: 100,
  //         fit: BoxFit.contain,
  //       ),
  //     ),
  //   );
  // }
}
