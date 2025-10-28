import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/entry_service.dart';
import '../models/process.dart';
import '../models/entry.dart';
import '../widgets/entry_tile.dart';
import '../controllers/entry_controller.dart';
import '../widgets/app_scaffold.dart';
import '../routes/routes.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../services/sound_service.dart';

class ProcessScreen extends StatefulWidget {
  final String userId;
  final Process process;
  const ProcessScreen({super.key, required this.userId, required this.process});

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  late List<Entry> entries = [];
  Directory? selectedFolder;

  @override
  void initState() {
    super.initState();
    _loadEntryData();
  }

  Future<void> _loadEntryData() async {
    final loaded = await EntryController.loadEntries(widget.process);
    setState(() {
      entries = loaded;
    });
  }

  Future<void> pickFolderAndExportPdf() async {
    // Launch native folder picker dialog
    final String? folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath != null) {
      final Directory folder = Directory(folderPath);
      setState(() => selectedFolder = folder);

      try {
        await EntryService.generatePdf(
          widget.userId,
          widget.process,
          folder.path,
        );
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF exported to ${folder.path}')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to export PDF: $e')));
      }
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No folder selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = entries.length;
    final done = entries.where((e) => e.isDone).length;
    final progress = total == 0 ? 0.0 : done / total;

    return AppScaffold(
      title: 'Entries for ${widget.process.title}',
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Export to PDF',
          onPressed: pickFolderAndExportPdf,
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              '$done of $total entries done',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 12),

          // 👇 Timeline view using timeline_tile
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ReorderableListView.builder(
                key: ValueKey(entries.map((e) => e.id).join(',')),
                itemCount: entries.length,
                onReorder: (oldIndex, newIndex) async {
                  final reordered = await EntryController.onReorder(
                    widget.userId,
                    widget.process,
                    entries,
                    newIndex,
                    oldIndex,
                  );
                  setState(() {
                    entries = List.from(reordered)
                      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
                  });
                },
                buildDefaultDragHandles: true,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final isFirst = index == 0;
                  final isLast = index == entries.length - 1;

                  return TimelineTile(
                    key: ValueKey(entry.id),
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: isFirst,
                    isLast: isLast,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: entry.isDone ? Colors.green : Colors.blueAccent,
                      iconStyle: IconStyle(
                        iconData: entry.isDone
                            ? Icons.check
                            : Icons.radio_button_unchecked,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    beforeLineStyle: const LineStyle(
                      color: Colors.redAccent,
                      thickness: 2,
                    ),
                    endChild: EntryTile(
                      key: ValueKey(entry.id),
                      entry: entry,
                      index: index,
                      userId: widget.userId,
                      process: widget.process,
                      onTap: () async {
                        await SoundService.play('sounds/done.mp3');

                        Navigator.pushNamed(
                          context,
                          AppRoutes.entry,
                          arguments: {
                            'userId': widget.userId,
                            'processId': widget.process.id,
                            'entry': entry,
                            'entryId': entry.id,
                          },
                        );
                      },
                      onEdit: () async {
                        final updated = await EntryController.editEntry(
                          context,
                          index,
                          widget.userId,
                          widget.process,
                          entries,
                        );
                        if (updated != null) {
                          setState(() {
                            entries[index] = updated;
                          });
                        }
                      },
                      onDelete: () async {
                        final deleted = await EntryController.deleteEntry(
                          context,
                          widget.process,
                          entries,
                          index,
                          widget.userId,
                          widget.process.id,
                        );
                        if (deleted != null) {
                          setState(() {
                            entries.removeAt(index);
                          });
                        }
                      },
                      onToggleDone: () async {
                        await SoundService.play('sounds/tick.mp3');
                        final updated =
                            await EntryController.handleCheckBoxPressed(
                              index,
                              widget.userId,
                              widget.process,
                              entries,
                            );
                        if (updated != null) {
                          setState(() {
                            entries[index] = updated;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      fab: FloatingActionButton(
        onPressed: () async {
          await SoundService.play('sounds/click.wav');

          final newEntry = await EntryController.addEntry(
            context,
            widget.userId,
            widget.process,
            entries.length,
            entries,
          );
          if (newEntry != null) {
            setState(() {
              entries.add(newEntry);
            });
          }
        },
        tooltip: 'Add Entry',
        child: const Text(
          '+',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
