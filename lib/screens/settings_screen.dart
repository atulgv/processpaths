import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool get isDarkMode => ThemeService.themeMode.value == ThemeMode.dark;
  bool isSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final sound = await SettingsService.loadSoundPreference();

    setState(() {
      isSoundEnabled = sound;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) {
              ThemeService.toggleTheme(value);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('Sound'),
            value: isSoundEnabled,
            onChanged: (value) {
              setState(() {
                isSoundEnabled = value;
              });
              SettingsService.saveSoundPreference(value);
            },
          ),
        ],
      ),
    );
  }
}
