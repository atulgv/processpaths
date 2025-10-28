import 'package:flutter/widgets.dart';

import '../services/firestore_service.dart';
import '../models/entry.dart';
import '../models/process.dart';
import '../models/point.dart';
import '../models/entry_order.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/hive_service.dart';

class EntryService {
  // creating the entry according to login condition
  static Future<void> createEntry({
    required String title,
    required String userId,
    required Process process,
    required int sortIndex,
    required Entry newEntry,
  }) async {
    final newEntryRef = Entry(
      id: newEntry.id,
      title: title,
      timestamp: DateTime.now(),
      isDone: false,
      points: [],
      sortIndex: sortIndex,
    );
    await HiveService.ensureEntryBoxOpen(process);

    HiveService.entryBoxFor(process).put(newEntryRef.id, newEntryRef);
    if (AuthService.instance.isLoggedIn) {
      debugPrint('processId: ${process.id}');

      await FirestoreService.processEntries(
        userId: userId,
        processId: process.id,
      ).doc(newEntryRef.id).set(newEntryRef.toFirestore());
    }
  }

  // updating the entry according to login condition
  static Future<void> updateEntry(
    Entry entry,
    String title,
    int index,
    String userId,
    Process process,
  ) async {
    if (entry.isInBox) {
      await entry.save();
    } else {
      final box = HiveService.entryBoxFor(process);
      await box.put(entry.id, entry);
      await entry.save();
    }
    if (AuthService.instance.isLoggedIn) {
      await FirestoreService.processEntries(
        userId: userId,
        processId: process.id,
      ).doc(entry.id).update({
        'title': title,
        'isDone': entry.isDone,
        'updatedAt': FieldValue.serverTimestamp(),
        'sortIndex': index,
      });
    }
  }

  // removing the entry according to login condition
  static Future<void> removeEntry({
    required String entryId,
    required String userId,
    required String processId,
    required Process process,
  }) async {
    HiveService.entryBoxFor(process).delete(entryId);
    if (AuthService.instance.isLoggedIn) {
      await FirestoreService.deleteById(
        FirestoreService.processEntries(userId: userId, processId: processId),
        entryId,
      );
    }
  }

  // creating the entry order according to login condition
  static Future<void> createEntryOrder({
    required List<EntryOrder> oldEntryOrder,
    required String userId,
    required Process process,
  }) async {
    await HiveService.ensureEntryOrderBoxOpen(process);
    for (final entryOrder in oldEntryOrder) {
      HiveService.entryOrderBoxFor(process).put(entryOrder.id, entryOrder);
    }
    if (AuthService.instance.isLoggedIn) {
      for (final entryOrder in oldEntryOrder) {
        final newEntryOrderRef = EntryOrder(
          id: entryOrder.id,
          entryId: entryOrder.entryId,
          sortIndex: entryOrder.sortIndex,
        );
        await FirestoreService.processEntryOrders(
          userId: userId,
          processId: process.id,
        ).doc(newEntryOrderRef.id).set(newEntryOrderRef.toFirestore());
        entryOrder.toFirestore();
      }
    }
  }

  // after checking the checkbox according to login condition
  static Future<void> toggleEntryDone(
    int index,
    bool value,
    List<Entry> entries,
    String userId,
    Process process,
  ) async {
    if (index < 0 || index >= entries.length) return;

    final updated = entries[index].copyWith(isDone: value);
    entries[index] = updated;
    // await updated.save();
    final box = HiveService.entryBoxFor(process);
    final stored = box.get(updated.id);
    if (stored != null) {
      stored.isDone = value;
      await stored.save();
    } else {
      await box.put(updated.id, updated);
    }
    if (AuthService.instance.isLoggedIn) {
      final docRef = FirestoreService.processEntries(
        userId: userId,
        processId: process.id,
      ).doc(updated.id);

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        await docRef.set({'isDone': value}, SetOptions(merge: true));
      } else {
        await docRef.update({'isDone': value});
      }
    }
  }

  // loading the entries from hive
  static Future<List<Entry>> loadEntriesFromHive(Process process) async {
    await HiveService.ensureEntryBoxOpen(process);
    final entryBox = HiveService.entryBoxFor(process);
    final entries = entryBox.values.toList();

    if (entries.isEmpty) {
      debugPrint('🟡 No entries found in Hive for process ${process.id}');
      return [];
    }

    final orderMap = await HiveService.fetchOrderFromHive(process);

    for (final entry in entries) {
      if (orderMap.containsKey(entry.id)) {
        entry.sortIndex = orderMap[entry.id]!;
        await entry.save(); // persist updated sortIndex
      }
    }

    entries.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    debugPrint(
      '✅ Loaded and ordered ${entries.length} entries from Hive for process ${process.id}',
    );
    return entries;
  }

  // loading entries from firestore
  static Future<List<Entry>> loadEntriesFromFirestore(String processId) async {
    final userId = AuthService.instance.currentUser?.uid;
    if (userId == null) return [];

    final entriesSnapshot = await FirestoreService.processEntries(
      userId: userId,
      processId: processId,
    ).get();

    final entries = entriesSnapshot.docs.map((doc) {
      final data = doc.data();
      return Entry.fromMap(doc.id, data);
    }).toList();

    if (entries.isEmpty) {
      debugPrint('🟡 No entries found in Firestore for process $processId');
      return [];
    }

    final orderMap = await FirestoreService.fetchOrderFromFirestore(
      userId,
      processId,
    );

    for (final entry in entries) {
      if (orderMap.containsKey(entry.id)) {
        entry.sortIndex = orderMap[entry.id]!;
      }
    }

    entries.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    debugPrint(
      '✅ Loaded and ordered ${entries.length} entries from Firestore for process $processId',
    );

    return entries;
  }

  // syncing the entries from hive to firestore
  static Future<bool> syncEntriesHiveToFirestore(Process process) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot sync: user not signed in');
      return false;
    }

    final box = HiveService.entryBoxFor(process);

    for (final entry in box.values) {
      final entryRef = FirestoreService.processEntries(
        userId: user.uid,
        processId: process.id,
      ).doc(entry.id);

      await entryRef.set({
        ...entry.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return true;
  }

  // generating pdf from specific process
  static Future<bool> generatePdf(
    String userId,
    Process process,
    String outputPath,
  ) async {
    try {
      final pdf = pw.Document();
      final entryPointMap = <Entry, List<Point>>{};
      final safeTitle = process.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

      if (AuthService.instance.isLoggedIn) {
        // 🔹 Firestore: Load entries
        final entrySnapshots = await FirestoreService.processEntries(
          userId: userId,
          processId: process.id,
        ).get();

        final entries = entrySnapshots.docs.map((doc) {
          final data = doc.data();
          return Entry(
            id: doc.id,
            title: data['title'] ?? '',
            timestamp: _parseTimestamp(data['timestamp']),
            sortIndex: data['sortIndex'] ?? 0,
            points: [],
          );
        }).toList();

        // 🔹 Firestore: Load points for each entry
        for (final entry in entries) {
          final pointSnapshots = await FirestoreService.entryPoints(
            userId: userId,
            processId: process.id,
            entryId: entry.id,
          ).get();

          final points = pointSnapshots.docs.map((doc) {
            final data = doc.data();
            return Point(
              id: doc.id,
              content: data['content'] ?? '',
              timestamp: _parseTimestamp(data['timestamp']),
            );
          }).toList();

          entryPointMap[entry] = points;
        }
      } else {
        // 🔹 Hive: Load entries
        await HiveService.ensureEntryBoxOpen(process);
        final entryBox = HiveService.entryBoxFor(process);
        final entries = entryBox.values.toList();

        // 🔹 Hive: Load points for each entry
        for (final entry in entries) {
          await HiveService.ensurePointBoxOpen(entry);
          final pointBox = HiveService.pointBoxFor(entry);
          final points = pointBox.values.toList();
          entryPointMap[entry] = points;
        }
      }

      // 🔹 Build PDF
      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Process name - ${process.title}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Text(
              'Entries',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
            pw.SizedBox(height: 12),
            ...entryPointMap.entries.map(
              (entryPair) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Bullet(
                    text: entryPair.key.title,
                    style: pw.TextStyle(fontSize: 18),
                  ),
                  if (entryPair.value.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: entryPair.value
                            .map(
                              (point) => pw.Bullet(
                                text: point.content,
                                style: pw.TextStyle(fontSize: 14),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  pw.SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      );

      // 🔹 Save PDF
      final file = File('$outputPath/$safeTitle.pdf');
      await file.writeAsBytes(await pdf.save());
      return true;
    } catch (e) {
      debugPrint('[PDF Generation Error] $e');
      return false;
    }
  }

  // timestamp formating
  static DateTime _parseTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }
}
