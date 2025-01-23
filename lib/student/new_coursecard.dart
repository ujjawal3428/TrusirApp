import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/student/course.dart';

class NewCourseCard extends StatefulWidget {
  final CourseDetail course;

  const NewCourseCard({super.key, required this.course});

  @override
  State<NewCourseCard> createState() => _NewCourseCardState();
}

class _NewCourseCardState extends State<NewCourseCard> {
  bool isWeb = false;
  @override
  void initState() {
    super.initState();
    initPhonePeSdk();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    isWeb = MediaQuery.of(context).size.width > 600;
    // double discount = int.parse(widget.course.price) /
    //     int.parse(widget.course.oldprice) *
    //     100;
    double discount = int.parse(widget.course.price) / int.parse('1000') * 100;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isWeb ? 30 : 16, vertical: isWeb ? 15 : 8),
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
        padding: EdgeInsets.all(isWeb ? 30 : 16.0),
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
                    height: isWeb ? 300 : 180,
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
                    child: Text(
                      'Best Seller',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isWeb ? 18 : 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.course.courseName,
              style: TextStyle(
                fontSize: isWeb ? 21 : 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.course.timeSlot,
              style: TextStyle(
                fontSize: isWeb ? 18 : 14,
                fontFamily: 'Poppins',
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                // Text(
                //   '₹${widget.course.newAmount}',
                //   style: const TextStyle(
                //     fontSize: 18,
                //     fontFamily: 'Poppins',
                //     fontWeight: FontWeight.bold,
                //     color: Colors.deepPurple,
                //   ),
                // ),
                const Text(
                  '₹1000',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  '₹${widget.course.price}', // Placeholder for original price
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Colors.grey,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  '$discount% OFF', // Placeholder for original price
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            widget.course.type == 'purchased' ||
                    widget.course.type == 'Purchased'
                ? Center(
                    child: SizedBox(
                      width: isWeb ? 200 : 300,
                      height: isWeb ? 40 : null,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Buy Now action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Know More',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  )
                : widget.course.type == 'demo'
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isWeb ? 200 : 142,
                            height: isWeb ? 40 : null,
                            child: ElevatedButton(
                              onPressed: () {
                                merchantTransactionID =
                                    generateUniqueTransactionId(userID!);
                                body = getChecksum(
                                        int.parse('${widget.course.price}00'))
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
                            width: isWeb ? 200 : 142,
                            height: isWeb ? 40 : null,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Buy Now action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Know More',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: isWeb ? 200 : 142,
                            height: isWeb ? 40 : null,
                            child: ElevatedButton(
                              onPressed: () {
                                merchantTransactionID =
                                    generateUniqueTransactionId(userID!);
                                body = getChecksum(
                                        int.parse('${widget.course.price}00'))
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
                            width: isWeb ? 200 : 142,
                            height: isWeb ? 40 : null,
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle Buy Now action
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 225, 143, 55),
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
    int randomNum = Random().nextInt(10000); // Random 4-digit number
    print("txn_${userHash}_$randomNum");
    // Combine components to ensure <= 38 characters
    return "txn_${userHash}_$randomNum";
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
          int adjustedAmount = (response["data"]['amount'] / 100).toInt();
          String transactiontype =
              response["data"]["paymentInstrument"]["type"] == 'CARD'
                  ? response["data"]["paymentInstrument"]["cardType"]
                  : response["data"]["paymentInstrument"]["type"];
          postTransaction(
              transactiontype,
              adjustedAmount,
              widget.course.courseName,
              response["data"]["merchantTransactionId"],
              widget.course.courseID);
          print(response);
        } else {
          Fluttertoast.showToast(msg: response["code"]);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "error");
      }
    });
  }

  Future<void> postTransaction(String transactionName, int amount,
      String transactionType, String transactionID, String courseID) async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    // Define the API URL
    String apiUrl =
        "$baseUrl/api/buy-course/$userID/$courseID"; // Replace with your API URL

    // Create a Transaction instance
    final Transaction transaction = Transaction(
      transactionName: transactionName,
      amount: amount,
      transactionType: transactionType,
      transactionID: transactionID,
    );

    try {
      // Make the POST request
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json", // Set headers if needed
          // Optional if authorization is required
        },
        body: jsonEncode(transaction.toJson()),
      );

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Transaction posted successfully: ${response.body}");
      } else {
        print(
            "Failed to post transaction: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }
}
