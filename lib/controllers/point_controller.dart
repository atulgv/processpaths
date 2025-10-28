import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/point.dart';
import '../services/point_service.dart';
import '../utils/dialog_utils.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class PointController {
  // adding a point when add point button is clicked
  static Future<Point?> addPoint(
    BuildContext context,
    String userId,
    String processId,
    Entry entry,
    List<Point> points,
  ) async {
    final controller = TextEditingController();
    final result = await DialogUtils.showTextInputDialog(
      context,
      'New Point',
      controller,
      'Add Point',
    );
    if (result != null && result.isNotEmpty) {
      final newPoint = Point(
        id: const Uuid().v4(),
        content: result,
        timestamp: DateTime.now(),
      );
      await PointService.createPoint(
        content: result,
        userId: userId,
        processId: processId,
        entry: entry,
        newPoint: newPoint,
      );
      return newPoint;
    }
    return null;
  }

  // editing a point when edit point button is clicked
  static Future<Point?> editPoint(
    BuildContext context,
    String userId,
    String processId,
    Entry entry,
    List<Point> points,
    int index,
  ) async {
    final point = points[index];
    final controller = TextEditingController(text: point.content);

    final result = await DialogUtils.showTextInputDialog(
      context,
      'Edit Entry',
      controller,
      'Update the Entry',
    );

    if (result != null && result.isNotEmpty) {
      point.content = result;
      final updated = point.copyWith(content: result);
      points[index] = updated;

      await PointService.updatePoint(userId, processId, entry, point);
      return updated;
    }
    return null;
  }

  // deleting a point when delete point button is clicked
  static Future<Point?> deletePoint(
    BuildContext context,
    Entry entry,
    List<Point> points,
    int index,
    String userId,
    String processId,
  ) async {
    final confirmed = await DialogUtils.confirmDeleteDialog(
      context,
      'Delete Point',
      'Are you sure you want to delete ${points[index].content}?',
    );

    if (confirmed == true) {
      final deleted = points[index];
      await PointService.removePoint(
        entry: entry,
        userId: userId,
        processId: processId,
        point: points[index],
      );
      return deleted;
    }
    return null;
  }

  // reloading points
  static Future<List<Point>> reloadPoints(String processId, Entry entry) async {
    return await loadPoints(processId, entry);
  }

  // loading points according to login condition
  static Future<List<Point>> loadPoints(String processId, Entry entry) async {
    return AuthService.instance.isLoggedIn
        ? await PointService.loadPointsFromFirestore(processId, entry.id)
        : await PointService.loadPointsFromHive(entry);
  }

  // syncing points to cloud
  Future<void> syncPointsToCloud(
    BuildContext context,
    String processId,
    Entry entry,
  ) async {
    final success = await PointService.syncPointsHiveToFirestore(
      processId,
      entry,
    );
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
