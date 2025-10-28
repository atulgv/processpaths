import 'package:flutter/material.dart';
import '../models/process.dart';
import '../services/sound_service.dart';

class ProcessTile extends StatelessWidget {
  final Process process;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProcessTile({
    super.key,
    required this.process,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(process.title, style: TextStyle(fontSize: 16)),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.red),

              // 🎯 Handle menu selection
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ],
        ),
        onTap: () async {
          await SoundService.play('sounds/click.wav');
          onTap();
        },
      ),
    );
  }
}
