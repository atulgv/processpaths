import 'package:flutter/material.dart';

class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Copyright Notice')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'All content, designs, and code within this app are © Atul Gaurav unless otherwise stated.\n\n'
            'Unauthorized reproduction, distribution, or modification is prohibited.\n\n'
            'Third-party assets are used under appropriate licenses and credited where applicable.',
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
