import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusir/common/api.dart';
import 'package:trusir/common/phonepe_payment.dart';
import 'package:trusir/student/main_screen.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double balance = 0;
  List<Map<String, dynamic>> walletTransactions = [];
  PaymentService paymentService = PaymentService();
  @override
  void initState() {
    super.initState();
    fetchBalance();
    fetchWalletTransactions();
    paymentService.initPhonePeSdk();
  }

  Future<double> fetchBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    // Replace with your API URL
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/user/balance/$userID'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(double.parse(data['balance']));
        setState(() {
          balance = double.parse(data['balance']);
          prefs.setString('wallet_balance', '$balance');
        });
        return balance; // Convert balance to an integer
      } else {
        throw Exception('Failed to load balance');
      }
    } catch (e) {
      print('Error: $e');
      return 0; // Return 0 in case of an error
    }
  }

  Future<List<Map<String, dynamic>>> fetchWalletTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userID = prefs.getString('userID');
    final response =
        await http.get(Uri.parse('$baseUrl/get-fee-payment-info/$userID'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Filter transactions where transactionName is 'WALLET'
      setState(() {
        walletTransactions = data
            .where((transaction) => transaction['transactionName'] == 'WALLET')
            .map((transaction) => transaction as Map<String, dynamic>)
            .toList();
      });

      return walletTransactions;
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[50],
        title: const Text(
          "My Wallet",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        // actions: const [
        //   Icon(Icons.help_outline, size: 24),
        //   SizedBox(width: 16),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Balance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Icon(Icons.account_balance_wallet, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ $balance',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(Icons.add, "Add Money"),
                      _buildActionButton(Icons.history, "History"),
                      // _buildActionButton(Icons.card_giftcard, "Rewards"),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(
                              index: 1,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        ),
                        child: _buildQuickAction(
                            Icons.school, "Buy Course", Colors.blue),
                      ),
                      // _buildQuickAction(
                      //     Icons.card_giftcard, "Redeem", Colors.orange),
                      _buildQuickAction(Icons.share, "Share", Colors.green),
                    ],
                  ),
                ],
              ),
            ),

            // Recent Transactions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: walletTransactions.isEmpty
                  ? const Center(child: Text("No Wallet Transactions Found"))
                  : Column(
                      children: walletTransactions.map((transaction) {
                        return _buildTransactionItem(
                          transaction["transactionType"] ??
                              "Unknown Transaction",
                          double.tryParse(transaction["amount"] ?? "0.0") ??
                              0.0,
                          transaction["created_at"] ?? "Unknown Date",
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(String description, double amount, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: amount > 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              amount > 0 ? Icons.add : Icons.remove,
              color: amount > 0 ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${amount > 0 ? '+' : ''}₹${amount.abs().toStringAsFixed(2)}",
            style: TextStyle(
              color: amount > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
