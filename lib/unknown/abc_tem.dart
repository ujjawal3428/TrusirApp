// get_in_touch_page.dart
import 'package:flutter/material.dart';

class GetInTouchPage extends StatelessWidget {
  const GetInTouchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get in Touch'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContactInfoRow(
              imagePath: 'callimage.png',
              label: 'Call',
              info: '+123 456 7890', // replace with actual phone number
            ),
            Divider(),
            ContactInfoRow(
              imagePath: 'whatsappimage.png',
              label: 'WhatsApp',
              info: '+123 456 7890', // replace with actual WhatsApp number
            ),
            Divider(),
            ContactInfoRow(
              imagePath: 'locationimage.png',
              label: 'Location',
              info:
                  '123 Main Street, City, Country', // replace with actual location
            ),
            Divider(),
            ContactInfoRow(
              imagePath: 'mailimage.png',
              label: 'Mail',
              info: 'email@example.com', // replace with actual email
            ),
          ],
        ),
      ),
    );
  }
}

class ContactInfoRow extends StatelessWidget {
  final String imagePath;
  final String label;
  final String info;

  const ContactInfoRow(
      {super.key, required this.imagePath, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(imagePath, width: 40.0, height: 40.0),
        const SizedBox(width: 16.0),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            info,
            style: const TextStyle(fontSize: 18.0),
          ),
        ),
      ],
    );
  }
}
