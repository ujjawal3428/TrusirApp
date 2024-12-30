import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CameraPopupScreen extends StatelessWidget {
  final String phone;
  final String userID;
  const CameraPopupScreen(
      {super.key, required this.phone, required this.userID});

  Future<void> openDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openDialer(phone);
                },
                child: const Text(
                  "Call Teacher",
                  style: TextStyle(
                      fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Button for "I'm a Teacher"
            Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "View Profile",
                  style: TextStyle(
                      fontSize: 18, color: Colors.black, fontFamily: 'Poppins'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showPopupDialog(BuildContext context, String phone, String userID) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (BuildContext context) {
      return CameraPopupScreen(phone: phone, userID: userID);
    },
  );
}
