import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class StudentPaymentPage extends StatefulWidget {
  const StudentPaymentPage({super.key});

  @override
  State<StudentPaymentPage> createState() => _StudentPaymentPageState();
}

class _StudentPaymentPageState extends State<StudentPaymentPage> {
  String environmentValue = 'SANDBOX'; // Use 'PRODUCTION' for live transactions
  String appId = ""; // Replace with your App ID
  String merchantId = "PGTESTPAYUAT86"; // Replace with your Merchant ID
  String packageName =
      "com.phonepe.simulator"; // Change to "com.phonepe.app" for production
  String body = ""; // Transaction details
  String checksum = ""; // Obtain this from your backend
  String apiEndPoint = "/pg/v1/pay";
  String callback = "TrusirApp";
  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  // String merchantId = "M1U6UCYTTPBT";
  //  String environmentValue =
  //     'PRODUCTION';
  // String saltKey = "77c97305-4c07-4586-829a-03767fea9e64";
  String saltIndex = "1";

  @override
  void initState() {
    super.initState();
    body = getChecksum().toString();
    initPhonePeSdk();
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
        } else {
          print("Payment Failed: ${response['error']}");
        }
      } else {
        print("Transaction Incomplete");
      }
    }).catchError((error) {
      print("Error during transaction: $error");
    });
  }

  getChecksum() {
    final reqData = {
      "merchantId": merchantId,
      "merchantTransactionId": "t_52554",
      "merchantUserId": "MUID123",
      "amount": 10,
      "callbackUrl": callback,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };
    String base64body = base64.encode(utf8.encode(json.encode(reqData)));
    checksum =
        '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
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
                    onTap: startTransaction,
                    child: Image.asset(
                      'assets/onlinepayment.png', // Ensure this path is correct
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Offline Payment Button
                Center(
                  child: GestureDetector(
                    onTap: _onofflinepayment,
                    child: Image.asset(
                      'assets/offlinepayment.png', // Ensure this path is correct
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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

  void _onofflinepayment() {
    print("Offline Payment selected");
    // Add your action here for offline payment
  }
}
