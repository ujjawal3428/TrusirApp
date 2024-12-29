import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

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

  @override
  void initState() {
    super.initState();
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
    PhonePePaymentSdk.startTransaction(body, "TrusirApp", checksum, packageName)
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
