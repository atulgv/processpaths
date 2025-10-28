import 'package:flutter/material.dart';
import '../services/sound_service.dart';

class DialogUtils {
  static Future<String?> showTextInputDialog(
    BuildContext context,
    String title,
    TextEditingController controller,
    String message,
  ) async {
    await SoundService.play('sounds/dialog.wav');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: message),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 🔊 Play click sound on save
              await SoundService.play('sounds/click.wav');

              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 🔊 Play click sound on save
              await SoundService.play('sounds/done.mp3');

              Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Future<bool> confirmDeleteDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    await SoundService.play('sounds/alert.wav');

    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              // 🔊 Play click sound on save
              await SoundService.play('sounds/click.wav');

              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 🔊 Play system click sound on delete
              await SoundService.play('sounds/done.mp3');

              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  static Future<void> showInfoDialog(
    BuildContext context,
    String title,
    String content,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
