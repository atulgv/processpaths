import 'package:flutter/material.dart';
import '../utils/dialog_utils.dart';
import '../models/process.dart';
import '../services/process_service.dart';
import '../services/auth_service.dart';

class ProcessController {
  // adding a process when add button is clicked
  static Future<Process?> addProcess(BuildContext context) async {
    final controller = TextEditingController();
    final result = await DialogUtils.showTextInputDialog(
      context,
      'New Process',
      controller,
      'Add a new process',
    );

    if (result != null && result.isNotEmpty) {
      final newProcess = Process(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: result,
        entries: [],
        timestamp: DateTime.now(),
      );

      await ProcessService.saveProcess(newProcess);
      return newProcess;
    }
    return null;
  }

  // adding a process when edit button is clicked
  static Future<Process?> editProcess(
    BuildContext context,
    int index,
    List<Process> processes,
  ) async {
    final controller = TextEditingController(text: processes[index].title);
    final result = await DialogUtils.showTextInputDialog(
      context,
      'Edit Process',
      controller,
      'Edit Process',
    );

    if (result != null && result.isNotEmpty) {
      final updated = processes[index].copyWith(title: result);
      await ProcessService.updateProcess(updated);
      return updated;
    }

    return null;
  }

  // adding a process when delete button is clicked
  static Future<Process?> deleteProcess(
    BuildContext context,
    int index,
    List<Process> processes,
  ) async {
    final confirm = await DialogUtils.confirmDeleteDialog(
      context,
      'Delete Process',
      'Are you sure you want to delete "${processes[index].title}"?',
    );

    if (confirm) {
      final deleted = processes[index];
      await ProcessService.removeProcess(deleted);
      return deleted;
    }

    return null;
  }

  // reloading processes
  static Future<List<Process>> reloadProcesses() async {
    return await loadProcesses();
  }

  // loading processes according to login condition
  static Future<List<Process>> loadProcesses() async {
    return AuthService.instance.isLoggedIn
        ? await ProcessService.loadProcessesFromFirestore()
        : await ProcessService.loadProcessesFromHive();
  }

  // syncing processes to cloud
  Future<void> syncProcessesToCloud(BuildContext context) async {
    final success = await ProcessService.syncProcessesHiveToFirestore();
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
}
