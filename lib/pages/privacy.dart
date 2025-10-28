import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'We value your privacy. This policy explains how we collect, use, and protect your data.\n\n'
            '1. We collect minimal personal information.\n'
            '2. Data is stored securely and never sold.\n'
            '3. You can request deletion of your data at any time.\n\n'
            'For questions, contact us via the support page.',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
