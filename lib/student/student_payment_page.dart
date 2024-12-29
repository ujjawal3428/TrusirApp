import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';

class StudentPaymentPage extends StatefulWidget {
  const StudentPaymentPage({super.key});

  @override
  State<StudentPaymentPage> createState() => _StudentPaymentPageState();
}

class _StudentPaymentPageState extends State<StudentPaymentPage> {
  @override
  void initState() {
    super.initState();
    initPhonePeSdk();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Top Image (Student Payment Info) touching the top of the screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/studenttopimage.png', // Ensure this path is correct
              fit: BoxFit.cover,
            ),
          ),

          // Main content below the top image
          Padding(
            padding: const EdgeInsets.only(
                top: 50.0,
                left: 20.0,
                right:
                    20.0), // Adjust padding to position content below the image
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => _goBack(context),
                  child: Image.asset(
                    "assets/back_button.png", // Ensure this path is correct
                    width: 58, // Adjust based on your image dimensions
                    height: 58,
                  ),
                ),
                const SizedBox(height: 290),

                // Online Payment Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      merchantTransactionID =
                          generateUniqueTransactionId(userID!);
                      body = getChecksum().toString();
                      startTransaction();
                    },
                    child: Image.asset(
                      'assets/onlinepayment.png', // Ensure this path is correct
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // const SizedBox(height: 20),

                //// Offline Payment Button
                // Center(
                //   child: GestureDetector(
                //     onTap: _onofflinepayment,
                //     child: Image.asset(
                //       'assets/offlinepayment.png', // Ensure this path is correct
                //       fit: BoxFit.cover,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Go back function
  void _goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // void _onofflinepayment() {
  //   print("Offline Payment selected");
  //   // Add your action here for offline payment
  // }

  String body = ""; // Transaction details
  String checksum = ""; // Obtain this from your backend
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

  getChecksum() {
    final reqData = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionID,
      "merchantUserId": userID,
      "amount": 29900,
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
