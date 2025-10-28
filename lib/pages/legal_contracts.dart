import 'package:flutter/material.dart';
// import '../widgets/app_scaffold.dart';

class LegalContractsScreen extends StatelessWidget {
  const LegalContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NDAs & Contracts')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NDAs & Contracts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'To protect your ideas, collaborations, and business relationships, we recommend using the following legal tools:',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildBulletPoint(
              context: context,
              title: 'Non-Disclosure Agreements (NDAs)',
              description:
                  'Use NDAs when working with collaborators, testers, or contractors to ensure sensitive information stays private.',
            ),
            const SizedBox(height: 16),
            _buildBulletPoint(
              context: context,
              title: 'Freelance & Partnership Contracts',
              description:
                  'Draft clear contracts for freelance work, partnerships, or client projects. Define scope, deliverables, timelines, and payment terms.',
            ),
            const SizedBox(height: 32),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     // TODO: Link to sample templates or upload feature
            //   },
            //   icon: const Icon(Icons.description),
            //   label: const Text('View Sample Templates'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
