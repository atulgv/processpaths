import 'package:flutter/material.dart';
import 'package:processpath/controllers/point_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/point_tile.dart';
import '../models/entry.dart';
import '../models/point.dart';
import '../services/sound_service.dart';

class EntryScreen extends StatefulWidget {
  final String userId;
  final String processId;
  final Entry entry;
  final String entryId;

  const EntryScreen({
    super.key,
    required this.userId,
    required this.processId,
    required this.entry,
    required this.entryId,
  });
  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late List<Point> points = [];

  @override
  void initState() {
    super.initState();
    _loadPointData();
  }

  void _loadPointData() async {
    final loaded = await PointController.loadPoints(
      widget.processId,
      widget.entry,
    );
    setState(() {
      points = loaded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Points for ${widget.entry.title}',
      body: Column(
        children: [
          Expanded(
            child: points.isEmpty
                ? const Center(child: Text('No points yet'))
                : ListView.builder(
                    itemCount: points.length,
                    itemBuilder: (_, index) {
                      final point = points[index];
                      return PointTile(
                        point: point,
                        onEdit: () async {
                          final updated = await PointController.editPoint(
                            context,
                            widget.userId,
                            widget.processId,
                            widget.entry,
                            points,
                            index,
                          );
                          if (updated != null) {
                            setState(() {
                              points[index] = updated;
                            });
                          }
                        },
                        onDelete: () async {
                          final deleted = await PointController.deletePoint(
                            context,
                            widget.entry,
                            points,
                            index,
                            widget.userId,
                            widget.processId,
                          );
                          if (deleted != null) {
                            setState(() {
                              points.removeAt(index);
                            });
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      fab: FloatingActionButton(
        onPressed: () async {
          await SoundService.play('sounds/click.wav');

          final newPoint = await PointController.addPoint(
            context,
            widget.userId,
            widget.processId,
            widget.entry,
            points,
          );
          if (newPoint != null) {
            setState(() {
              points.add(newPoint);
            });
          }
        },
        tooltip: 'Add Point',
        child: const Icon(Icons.add),
      ),
    );
  }
}
