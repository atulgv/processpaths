import '../services/hive_service.dart';
import '../models/process.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class ProcessService {
  // saving the process according to login condition
  static Future<void> saveProcess(Process process) async {
    HiveService.processBox.put(process.id, process);
    if (AuthService.instance.isLoggedIn) {
      final userId = AuthService.instance.currentUser?.uid;
      if (userId != null) {
        FirestoreService.userProcesses(
          userId,
        ).doc(process.id).set({'title': process.title});
      }
    }
  }

  // updating the process according to login condition
  static Future<void> updateProcess(Process process) async {
    if (process.isInBox) {
      await process.save();
    } else {
      final box = HiveService.processBox;
      await box.put(process.id, process);
      await process.save();
    }
    if (AuthService.instance.isLoggedIn) {
      final userId = AuthService.instance.currentUser?.uid;
      if (userId != null) {
        FirestoreService.userProcesses(
          userId,
        ).doc(process.id).update({'title': process.title});
      }
    }
  }

  // deleting the process according to login condition
  static Future<void> removeProcess(Process process) async {
    HiveService.processBox.delete(process.id);
    if (AuthService.instance.isLoggedIn) {
      final userId = AuthService.instance.currentUser?.uid;
      if (userId != null) {
        FirestoreService.userProcesses(userId).doc(process.id).delete();
      }
    }
  }

  // loading processes from hive
  static Future<List<Process>> loadProcessesFromHive() async {
    final box = HiveService.processBox;
    return box.values.toList();
  }

  // loading processes from firestore
  static Future<List<Process>> loadProcessesFromFirestore() async {
    final userId = AuthService.instance.currentUser?.uid;
    if (userId == null) return [];

    final snapshot = await FirestoreService.userProcesses(userId).get();

    final processes = snapshot.docs
        .map((doc) => Process.fromFirestore(doc))
        .toList();

    return processes;
  }

  // syncing the processes from hive to firestore
  static Future<bool> syncProcessesHiveToFirestore() async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot sync: user not signed in');
      return false;
    }

    final box = HiveService.processBox;

    for (final process in box.values) {
      final processRef = FirestoreService.userProcesses(
        user.uid,
      ).doc(process.id);

      await processRef.set({
        ...process.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return true;
  }
}
