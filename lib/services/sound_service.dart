import 'package:audioplayers/audioplayers.dart';
import 'settings_service.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play(String assetPath) async {
    final isEnabled = await SettingsService.loadSoundPreference();
    if (!isEnabled) return;

    try {
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Optional: log or handle playback errors
    }
  }
}
