import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/entry.dart';
import '../models/point.dart';
import 'firestore_service.dart';
import '../services/hive_service.dart';
import '../services/auth_service.dart';
import 'package:flutter/widgets.dart';

class PointService {
  // creating point according to login condition
  static Future<void> createPoint({
    required String content,
    required String userId,
    required String processId,
    required Entry entry,
    required Point newPoint,
  }) async {
    final newPointRef = Point(
      id: newPoint.id,
      content: content,
      timestamp: DateTime.now(),
    );
    await HiveService.ensurePointBoxOpen(entry);
    HiveService.pointBoxFor(entry).put(newPointRef.id, newPointRef);
    if (AuthService.instance.isLoggedIn) {
      debugPrint('entryId: ${entry.id}');

      await FirestoreService.entryPoints(
        userId: userId,
        processId: processId,
        entryId: entry.id,
      ).doc(newPointRef.id).set(newPointRef.toFirestore());
    }
  }

  // updating point according to login condition
  static Future<void> updatePoint(
    String userId,
    String processId,
    Entry entry,
    Point point,
  ) async {
    if (point.isInBox) {
      await point.save();
    } else {
      final box = HiveService.pointBoxFor(entry);
      await box.put(point.id, point);
      await point.save();
    }
    if (AuthService.instance.isLoggedIn) {
      final docRef = FirestoreService.entryPoints(
        userId: userId,
        processId: processId,
        entryId: entry.id,
      ).doc(point.id);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        debugPrint(
          '[updatePoint] Document not found: ${point.id}. Creating instead.',
        );
        await docRef.set({
          'content': point.content,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      await docRef.update({
        'content': point.content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // removing point according to login condition
  static Future<void> removePoint({
    required String userId,
    required String processId,
    required Entry entry,
    required Point point,
  }) async {
    HiveService.pointBoxFor(entry).delete(point.id);
    if (AuthService.instance.isLoggedIn) {
      await FirestoreService.deleteById(
        FirestoreService.entryPoints(
          userId: userId,
          processId: processId,
          entryId: entry.id,
        ),
        point.id,
      );
    }
  }

  // loading points from hive
  static Future<List<Point>> loadPointsFromHive(Entry entry) async {
    await HiveService.ensurePointBoxOpen(entry);
    final box = HiveService.pointBoxFor(entry);
    final points = box.values.whereType<Point>().toList();
    return points;
  }

  // loading points from firestore
  static Future<List<Point>> loadPointsFromFirestore(
    String processId,
    String entryId,
  ) async {
    final userId = AuthService.instance.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await FirestoreService.entryPoints(
      userId: userId,
      processId: processId,
      entryId: entryId,
    ).get();

    final points = snapshot.docs
        .map((doc) => Point.fromFirestore(doc))
        .toList();

    return points;
  }

  // syncing the point form hive to firestore
  static Future<bool> syncPointsHiveToFirestore(
    String processId,
    Entry entry,
  ) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot sync: user not signed in');
      return false;
    }

    final box = HiveService.pointBoxFor(entry);

    for (final point in box.values) {
      final pointRef = FirestoreService.entryPoints(
        userId: user.uid,
        processId: processId,
        entryId: entry.id,
      ).doc(point.id);

      await pointRef.set({
        ...point.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return true;
  }
}
