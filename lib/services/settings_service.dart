import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _soundKey = 'sound_enabled';

  // 🔊 SOUND
  static Future<bool> loadSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  static Future<void> saveSoundPreference(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, isEnabled);
  }
}
