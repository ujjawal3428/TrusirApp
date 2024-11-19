import 'package:flutter/material.dart';

class FeePaymentScreen extends StatelessWidget {
  const FeePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                       onTap: () {
                          Navigator.pop(context);
                        },
                      child: Image.asset(
                        'assets/dikshaback@2x.png',
                        width: 58,
                        height: 58,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fee Payments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 30),
                        Row(
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
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
                        color: Colors.black.withOpacity(0.25),
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
                            padding: EdgeInsets.only(left: 20.0, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Month',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '24 Jan 2025 - Today',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Total No. of Classes: 09',
                                  style: TextStyle(
                                    fontSize: 16,
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
                            width: 143,
                            height: 143,
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
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 386,
                  height: 136,
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course enrollment fee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'CB0s8dk0d00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Debit Card',
                                style: TextStyle(
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
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(children: [
                            Text(
                              '₹ 2500.00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 Feb 2025',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 18),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                '10:42',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 386,
                  height: 136,
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course enrollment fee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'CB0s8dk0d00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Debit Card',
                                style: TextStyle(
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
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(children: [
                            Text(
                              '₹ 2500.00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 Feb 2025',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 18),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                '10:42',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 386,
                  height: 136,
                  decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course enrollment fee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'CB0s8dk0d00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Debit Card',
                                style: TextStyle(
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
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(children: [
                            Text(
                              '₹ 2500.00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 Feb 2025',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 18),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                '10:42',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 386,
                  height: 136,
                  decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course enrollment fee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'CB0s8dk0d00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Debit Card',
                                style: TextStyle(
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
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(children: [
                            Text(
                              '₹ 2500.00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 Feb 2025',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 18),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                '10:42',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 386,
                  height: 136,
                  decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course enrollment fee',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'CB0s8dk0d00',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Debit Card',
                                style: TextStyle(
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
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(children: [
                            Text(
                              '₹ 2500.00',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '12 Feb 2025',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            SizedBox(height: 18),
                            Padding(
                              padding: EdgeInsets.only(left: 25.0),
                              child: Text(
                                '10:42',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
             
            ]),
          ),
           Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: InkWell(
                  onTap: () {   
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF045C19),
                          Color(0xFF77D317),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Create Test',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins'
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
