import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routes/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/sound_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionTitle('About the Developer'),
                Text(
                  'Crafted with care by Atul—a full-stack Flutter architect focused on modular design, onboarding clarity, and expressive UI.',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                ListTile(
                  title: const Text('Visit the website'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    await SoundService.play('sounds/click.wav');

                    _launchURL('https://atulgaurav.com');
                  },
                ),
                const SizedBox(height: 16),

                const _SectionTitle('Follow Us'),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.facebook),
                      onPressed: () async {
                        await SoundService.play('sounds/click.wav');

                        _launchURL('https://facebook.com/theatulgaurav');
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.xTwitter),
                      onPressed: () async {
                        await SoundService.play('sounds/click.wav');

                        _launchURL('https://x.com/meetatulgaurav');
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.linkedin),
                      onPressed: () async {
                        await SoundService.play('sounds/click.wav');

                        _launchURL('https://linkedin.com/in/atulgv');
                      },
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.github),
                      onPressed: () async {
                        await SoundService.play('sounds/click.wav');

                        _launchURL('https://github.com/atulgv');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const _SectionTitle('Legal'),
                _LegalTile(title: 'Terms & Conditions', route: AppRoutes.terms),
                _LegalTile(title: 'Privacy Policy', route: AppRoutes.privacy),
                _LegalTile(
                  title: 'Copyright Notice',
                  route: AppRoutes.copyright,
                ),
                _LegalTile(
                  title: 'NDAs & Contracts',
                  route: AppRoutes.legalContracts,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            minimum: EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Version 1.0.1',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
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
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  final String title;
  final String route;
  const _LegalTile({required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
