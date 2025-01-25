import 'package:fluttertoast/fluttertoast.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PaymentService {
  final String environmentValue =
      'SANDBOX'; // Use 'PRODUCTION' for live transactions
  final String appId = ""; // Replace with your App ID
  final String merchantId = "PGTESTPAYUAT86"; // Replace with your Merchant ID
  final String packageName =
      "com.phonepe.simulator"; // Change to "com.phonepe.app" for production
  final String apiEndPoint = "/pg/v1/pay";
  final String callback = "TrusirApp";
  final String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  final String saltIndex = "1";

  /// Initialize the PhonePe SDK
  Future<void> initPhonePeSdk() async {
    try {
      bool isInitialized = await PhonePePaymentSdk.init(
          environmentValue, appId, merchantId, true);
      print("PhonePe SDK Initialized: $isInitialized");
    } catch (error) {
      print("Error initializing PhonePe SDK: $error");
      rethrow;
    }
  }

  /// Generate checksum and return request body

  /// Start a transaction
  void startTransaction(String body, String checksum, final checkStatus,
      final showLoadingDialog, final paymentstatusnavigation) {
    showLoadingDialog();
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) {
      if (response != null) {
        String status = response['status'].toString();
        if (status == 'SUCCESS') {
          print("Payment Successful");
          checkStatus();
        } else {
          print("Payment Failed: ${response['error']}");
          paymentstatusnavigation();
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
}
