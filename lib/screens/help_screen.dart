import 'package:flutter/material.dart';
import '../routes/routes.dart';
import '../services/sound_service.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Support Options'),
          _HelpTile(title: 'Help Page', route: AppRoutes.helpPage),
          _HelpTile(
            title: 'Request a Feature',
            route: AppRoutes.featureRequest,
          ),
          _HelpTile(
            title: 'Delete Account / Data',
            route: AppRoutes.deleteData,
          ),
          _HelpTile(title: 'Report a bug', route: AppRoutes.reportBug),
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

class _HelpTile extends StatelessWidget {
  final String title;
  final String route;
  const _HelpTile({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await SoundService.play('sounds/click.wav');

        Navigator.pushNamed(context, route);
      },
    );
  }
}
