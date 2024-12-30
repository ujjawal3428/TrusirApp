import 'package:flutter/material.dart';
import 'package:trusir/student/student_homepage.dart';
import 'package:trusir/teacher/teacher_homepage.dart';

class PopupScreen extends StatelessWidget {
  const PopupScreen({super.key});

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentHomepage(
                        enablephone: true,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "I'm a Student",
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Teacherhomepage(),
                    ),
                  );
                },
                child: const Text(
                  "I'm a Teacher",
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

void showPopupDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (BuildContext context) {
      return const PopupScreen();
    },
  );
}
