import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/routes.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Ways to give feedback'),
          FeedbackTile(
            title: 'On Play Store',
            url:
                'https://play.google.com/store/apps/details?id=com.atulgaurav.processpaths',
          ),

          FeedbackTile(
            title: 'Personal feedback',
            route: AppRoutes.personalFeedback,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}

class FeedbackTile extends StatelessWidget {
  final String title;
  final String? route; // Optional if using URL
  final String? url; // Optional if using route
  const FeedbackTile({required this.title, this.route, this.url});

  void _handleTap(BuildContext context) {
    if (url != null) {
      final uri = Uri.parse(url!);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (route != null) {
      Navigator.pushNamed(context, route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _handleTap(context),
    );
  }
}
