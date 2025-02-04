import 'package:flutter/material.dart';

class AddMoneyPopup extends StatefulWidget {
  const AddMoneyPopup({super.key});

  @override
  State<AddMoneyPopup> createState() => _AddMoneyPopupState();
}

class _AddMoneyPopupState extends State<AddMoneyPopup> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Money",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter amount",
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 25.0, top: 11),
                  child: Text(
                    "₹",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: Colors.deepPurpleAccent,
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
