import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
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
      appBar: AppBar(
        title: const Text("Payment Page"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: startTransaction,
          child: const Text("Buy Now"),
        ),
      ),
    );
  }
}
