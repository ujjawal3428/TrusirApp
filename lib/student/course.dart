import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/toggle_button.dart';
import 'package:trusir/student/main_screen.dart';

class Course {
  final int id;
  final String amount;
  final String name;
  final String subject;
  final String image;

  Course({
    required this.id,
    required this.amount,
    required this.name,
    required this.subject,
    required this.image,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      amount: json['amount'],
      name: json['name'],
      subject: json['class'],
      image: json['image'],
    );
  }
}

class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  @override
  void initState() {
    super.initState();
    initPhonePeSdk();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.course.image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error,
                          size: 40,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Best Seller',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.course.name,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.course.subject,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '₹${widget.course.amount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                const Text(
                  '₹5000', // Placeholder for original price
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                const Text(
                  '50% OFF', // Placeholder for original price
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 142,
                  child: ElevatedButton(
                    onPressed: () {
                      merchantTransactionID =
                          generateUniqueTransactionId(userID!);
                      body = getChecksum(int.parse('${widget.course.amount}00'))
                          .toString();
                      startTransaction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Buy Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 142,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Buy Now action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 225, 143, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Book Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String body = "";
  // Transaction details
  String checksum = "";
  // Obtain this from your backend
  String? userID;

  String? phone;

  String merchantTransactionID = '';

  Future<void> fetchProfileData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID');
      phone = prefs.getString('phone_number');
    });
  }

  String generateUniqueTransactionId(String userId) {
    // Hash the user ID to a shorter fixed length
    String userHash = sha256
        .convert(utf8.encode(userId))
        .toString()
        .substring(0, 8); // 8 characters
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/
        1000; // Unix timestamp in seconds
    int randomNum = Random().nextInt(10000); // Random 4-digit number
    print("txn_${userHash}_${timestamp}_$randomNum");
    // Combine components to ensure <= 38 characters
    return "txn_${userHash}_${timestamp}_$randomNum";
  }

  void initPhonePeSdk() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, true)
        .then((isInitialized) {
      print("PhonePe SDK Initialized: $isInitialized");
    }).catchError((error) {
      print("Error initializing PhonePe SDK: $error");
    });
  }

  void startTransaction() {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) {
      if (response != null) {
        String status = response['status'].toString();
        if (status == 'SUCCESS') {
          print("Payment Successful");
          checkStatus();
        } else {
          print("Payment Failed: ${response['error']}");
          Fluttertoast.showToast(msg: "Payment Failed");
        }
      } else {
        print("Transaction Incomplete");
        Fluttertoast.showToast(msg: 'Transaction Incomplete');
      }
    }).catchError((error) {
      print("Error during transaction: $error");
    });
  }

  getChecksum(int am) {
    final reqData = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionID,
      "merchantUserId": userID,
      "amount": am,
      "callbackUrl": callback,
      "mobileNumber": "+91$phone",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };
    String base64body = base64.encode(utf8.encode(json.encode(reqData)));
    checksum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
  }

  void checkStatus() async {
    String url =
        "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$merchantTransactionID";

    String concat = "/pg/v1/status/$merchantId/$merchantTransactionID$saltKey";

    var bytes = utf8.encode(concat);

    var digest = sha256.convert(bytes).toString();

    String xVerify = "$digest###$saltIndex";

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-VERIFY": xVerify,
      "X-MERCHANT-ID": merchantId
    };

    await http.get(Uri.parse(url), headers: headers).then((value) {
      Map<String, dynamic> response = jsonDecode(value.body);

      try {
        if (response["success"] &&
            response["code"] == "PAYMENT_SUCCESS" &&
            response["data"]["state"] == "COMPLETED") {
          Fluttertoast.showToast(msg: response["code"]);
          print(response);
        } else {
          Fluttertoast.showToast(msg: response["code"]);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "error");
      }
    });
  }
}

class CoursePage extends StatefulWidget {
  const CoursePage({super.key});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Future<List<Course>> fetchCourses() async {
    final url = Uri.parse('$baseUrl/all-course');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch courses');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                  );
                },
                child: Image.asset('assets/back_button.png', height: 50),
              ),
              const SizedBox(width: 20),
              const Text(
                'Course',
                style: TextStyle(
                  color: Color(0xFF48116A),
                  fontSize: 25,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          FilterSwitch(
            option1: 'My Courses',
            option2: 'Demo Courses',
            option3: 'More Courses',
            initialSelectedIndex: 0, // Start with Option 1 selected
            onChanged: (selectedIndex) {},
          ),
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: fetchCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load courses: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No courses available'),
                  );
                } else {
                  final courses = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return CourseCard(course: course);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
