import 'package:flutter/material.dart';

class PaymentMethod {
  static Widget buildDialog({
    required VoidCallback onPhonePayment,
    required VoidCallback onWalletPayment,
  }) {
    final ValueNotifier<bool> walletSelected = ValueNotifier(false);
    final ValueNotifier<bool> phoneSelected = ValueNotifier(false);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 174, 141, 70),
              Color.fromARGB(255, 201, 74, 49),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Payment",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {}
                  // => Navigator.pop(onPhonePayment.hashCode.context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Type",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        "Course Purchase",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        "₹ 2.00",
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: walletSelected,
              builder: (context, isSelected, child) {
                bool isChecked = false;

return _buildPaymentOption(
  title: "Pay with wallet",
  subtitle: null, // No subtitle provided
  amount: "₹ 98.42",
  onTap: () => walletSelected.value = !isSelected,
  gradient: LinearGradient(
    colors: [
      Colors.orange.shade200,
      Colors.orange.shade300,
    ],
  ),
  isSelected: isSelected,
  isChecked: isChecked,
  onChanged: (value) {
    isChecked = value ?? false;
    walletSelected.value = isChecked;
  },
);

              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: phoneSelected,
              builder: (context, isSelected, child) {
                bool isChecked = false;

return _buildPaymentOption(
  title: "Pay via Phone",
  subtitle: "UPI, Cards, NetBanking",
  amount: null, // If no amount is needed
  onTap: () => phoneSelected.value = !isSelected,
  gradient: LinearGradient(
    colors: [
      Colors.blue.shade200,
      Colors.blue.shade300,
    ],
  ),
  isSelected: isSelected,
  isChecked: isChecked,
  onChanged: (value) {
    isChecked = value ?? false;
    phoneSelected.value = isChecked;
  },
);

              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ValueListenableBuilder(
                valueListenable: ValueNotifier<bool>(
                    walletSelected.value || phoneSelected.value),
                builder: (context, anySelected, child) {
                  return ElevatedButton(
                      onPressed: (walletSelected.value || phoneSelected.value)
      ? () {
          if (phoneSelected.value) {
            onPhonePayment();
          }
          if (walletSelected.value) {
            onWalletPayment();
          }
        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: anySelected ? Colors.amber : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Pay",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              },
            ),
        )],
        ),
      ),
    );
  }

static Widget _buildPaymentOption({
  required String title,
  String? subtitle,
  String? amount,
  required VoidCallback onTap,
  required Gradient gradient,
  required bool isSelected,
  required bool isChecked,
  required ValueChanged<bool?> onChanged,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isSelected
            ? gradient
            : LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: gradient.colors.first,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withOpacity(0.7) : Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
              ],
            ),
          ),
          if (amount != null)
            Text(
              amount,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
        ],
      ),
    ),
  );
}
}