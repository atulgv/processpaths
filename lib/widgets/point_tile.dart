import 'package:flutter/material.dart';
import '../models/point.dart';

class PointTile extends StatelessWidget {
  final Point point;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PointTile({
    super.key,
    required this.point,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.arrow_circle_right_outlined,
        color: Colors.purpleAccent,
      ),
      title: Text(point.content),
      trailing: PopupMenuButton<String>(
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
    );
  }
}
