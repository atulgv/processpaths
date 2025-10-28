import 'package:flutter/material.dart';
import 'package:processpath/models/entry_order.dart';
import '../utils/dialog_utils.dart';
import '../services/entry_service.dart';
import '../models/process.dart';
import '../models/entry.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class EntryController {
  // adding an entry when add button is clicked
  static Future<Entry?> addEntry(
    BuildContext context,
    String userId,
    Process process,
    int index,
    List<Entry> entries,
  ) async {
    final controller = TextEditingController();
    final result = await DialogUtils.showTextInputDialog(
      context,
      'New Entry',
      controller,
      'Add new Entry',
    );

    if (result != null && result.isNotEmpty) {
      final newEntry = Entry(
        id: const Uuid().v4(),
        title: result,
        timestamp: DateTime.now(),
        isDone: false,
        points: [],
        sortIndex: index,
      );

      await EntryService.createEntry(
        title: result,
        userId: userId,
        process: process,
        sortIndex: index,
        newEntry: newEntry,
      );
      return newEntry;
    }
    return null;
  }

  // editing an entry when edit button is clicked
  static Future<Entry?> editEntry(
    BuildContext context,
    int index,
    String userId,
    Process process,
    List<Entry> entries,
  ) async {
    final entry = entries[index];
    final controller = TextEditingController(text: entry.title);

    final result = await DialogUtils.showTextInputDialog(
      context,
      'Edit Entry',
      controller,
      'Update the Entry',
    );

    if (result != null && result.isNotEmpty) {
      entry.title = result;
      final updated = entries[index].copyWith(title: result);
      await EntryService.updateEntry(entry, result, index, userId, process);
      return updated;
    }
    return null;
  }

  // deleting an entry when delete button is clicked
  static Future<Entry?> deleteEntry(
    BuildContext context,
    Process process,
    List<Entry> entries,
    int index,
    String userId,
    String processId,
  ) async {
    final confirmed = await DialogUtils.confirmDeleteDialog(
      context,
      'Delete Entry',
      'Are you sure you want to delete ${entries[index].title}?',
    );

    if (confirmed == true) {
      final deleted = entries[index];
      await EntryService.removeEntry(
        entryId: entries[index].id,
        process: process,
        userId: userId,
        processId: processId,
      );
      return deleted;
    }
    return null;
  }

  // handling reorder events
  static Future<List<Entry>> onReorder(
    String userId,
    Process process,
    List<Entry> entries,
    int newIndex,
    int oldIndex,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;

    final entry = entries.removeAt(oldIndex);
    entries.insert(newIndex, entry);

    for (int i = 0; i < entries.length; i++) {
      entries[i].sortIndex = i;
    }

    final order = <EntryOrder>[];
    for (final entry in entries) {
      final entryOrder = EntryOrder(
        id: const Uuid().v4(),
        entryId: entry.id,
        sortIndex: entry.sortIndex,
      );

      order.add(entryOrder);
    }
    await EntryService.createEntryOrder(
      userId: userId,
      process: process,
      oldEntryOrder: order,
    );
    return entries;
  }

  // handling when check box is pressed
  static Future<Entry?> handleCheckBoxPressed(
    int index,
    String userId,
    Process process,
    List<Entry> entries,
  ) async {
    final currentValue = entries[index].isDone;
    final newValue = !currentValue;

    final updated = entries[index].copyWith(isDone: newValue);

    await EntryService.toggleEntryDone(
      index,
      newValue,
      entries,
      userId,
      process,
    );

    return updated;
  }

  // reloading entries
  static Future<List<Entry>> reloadEntries(Process process) async {
    return await loadEntries(process);
  }

  // loading entries according to login condition
  static Future<List<Entry>> loadEntries(Process process) async {
    return AuthService.instance.isLoggedIn
        ? await EntryService.loadEntriesFromFirestore(process.id)
        : await EntryService.loadEntriesFromHive(process);
  }

  // syncing entries to cloud
  Future<void> syncEntriesToCloud(BuildContext context, Process process) async {
    final success = await EntryService.syncEntriesHiveToFirestore(process);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synced to cloud successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync failed: user not signed in')),
      );
    }
  }

  // exporting a process to pdf
  Future<void> exportToPdf(
    BuildContext context,
    String userId,
    Process process,
  ) async {
    final outputPath = await FilePicker.platform.getDirectoryPath();
    if (outputPath == null) return;

    final success = await EntryService.generatePdf(userId, process, outputPath);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Exported "${process.title}" to PDF'
              : 'Failed to export PDF',
        ),
      ),
    );
  }
}
