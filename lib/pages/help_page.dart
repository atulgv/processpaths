import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'How can we help you?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          const _HelpTopic(
            title: 'Getting Started',
            qa: [
              {
                'q': 'How do I create an account?',
                'a':
                    'Tap “Sign Up” on the login screen, enter your email and password, then follow the verification steps to activate your account.',
              },
              {
                'q': 'How do I reset my password?',
                'a':
                    'On the login screen, tap “Forgot Password?” and enter your registered email. You’ll receive a reset link via email.',
              },
            ],
          ),
          const _HelpTopic(
            title: 'App Features',
            qa: [
              {
                'q': 'How do I export my data?',
                'a':
                    'Go to the process you want to export. In the AppBar click on the export to pdf button. You can save it wherever you want.',
              },
              {
                'q': 'What does the timeline view show?',
                'a':
                    'The timeline view displays your activity history, milestones, and progress in chronological order. It helps you track your journey visually.',
              },
            ],
          ),
          const _HelpTopic(
            title: 'Troubleshooting',
            qa: [
              {
                'q': 'Why is my data not syncing?',
                'a':
                    'Check your internet connection and ensure you’re signed in. If the issue persists, try restarting the app or checking for updates.',
              },
              {
                'q': 'How do I report a bug?',
                'a':
                    'Go to Help & Support > Report a Bug. You can describe the issue and optionally attach a screenshot. We’ll review and respond promptly.',
              },
              {
                'q': 'App crashes on launch—what should I do?',
                'a':
                    'Ensure you’re using the latest version of the app. If the problem continues, clear cache or reinstall the app. Contact support if needed.',
              },
            ],
          ),
          const _HelpTopic(
            title: 'Privacy & Security',
            qa: [
              {
                'q': 'How is my data stored?',
                'a':
                    'Your data is securely stored using encrypted cloud storage. We follow industry best practices to protect your privacy.',
              },
              {
                'q': 'Can I delete my account?',
                'a':
                    'Yes. Go to Help & Support > Delete Account. This will permanently remove your data and cannot be undone.',
              },
              {
                'q': 'What third-party services are used?',
                'a':
                    'We use trusted services like Firebase for authentication and analytics, and Stripe for secure payments. See our Privacy Policy for details.',
              },
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpTopic extends StatelessWidget {
  final String title;
  final List<Map<String, String>> qa;
  const _HelpTopic({required this.title, required this.qa});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      children: qa
          .map(
            (item) => ExpansionTile(
              title: Text(
                item['q']!,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    item['a']!,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
