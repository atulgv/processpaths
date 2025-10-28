import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'These Terms & Conditions govern your use of the app. By accessing or using the app, you agree to be bound by these terms.\n\n'
            '1. Use of the app is at your own risk.\n'
            '2. You agree not to misuse or exploit any features.\n'
            '3. We reserve the right to update these terms at any time.\n\n'
            'Please review them periodically for changes.',
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
