import 'package:flutter/material.dart';
import '../models/process.dart';
import '../models/entry.dart';
import '../services/sound_service.dart';

class EntryTile extends StatelessWidget {
  final String userId;
  final Process process;
  final Entry entry;
  final VoidCallback onTap;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function() onToggleDone;

  const EntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.userId,
    required this.process,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await SoundService.play('sounds/click.wav');
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Title row with drag icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.drag_indicator, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          decoration: entry.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 🔹 Control row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ Leading controls
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            entry.isDone
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: () async {
                            await onToggleDone();
                          },
                        ),
                      ],
                    ),

                    // ✅ Trailing controls
                    Row(
                      children: [
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.red),
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
                                children: const [
                                  Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
