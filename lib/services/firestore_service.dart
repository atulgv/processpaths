import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FirestoreService {
  // database in firestore
  static final db = FirebaseFirestore.instance;

  // configure database
  static void configure() {
    db.settings = const Settings(persistenceEnabled: true);
  }

  // user doc for firestore
  static DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      db.collection('users').doc(userId);

  // process doc for firestore
  static CollectionReference<Map<String, dynamic>> userProcesses(
    String userId,
  ) => userDoc(userId).collection('processes');

  // entries doc for firestore
  static CollectionReference<Map<String, dynamic>> processEntries({
    required String userId,
    required String processId,
  }) => userProcesses(userId).doc(processId).collection('entries');

  // entry orders doc for firestore
  static CollectionReference<Map<String, dynamic>> processEntryOrders({
    required String userId,
    required String processId,
  }) => userProcesses(userId).doc(processId).collection('entryOrders');

  // points doc for firestore
  static CollectionReference<Map<String, dynamic>> entryPoints({
    required String userId,
    required String processId,
    required String entryId,
  }) => processEntries(
    userId: userId,
    processId: processId,
  ).doc(entryId).collection('points');

  // delete collection by id
  static Future<void> deleteById(
    CollectionReference collection,
    String id,
  ) async {
    await collection.doc(id).delete();
  }

  // delete account from firestore
  static Future<void> deleteAccountFromFirestore(String userId) async {
    try {
      final processes = await userProcesses(userId).get();
      for (final processDoc in processes.docs) {
        final processId = processDoc.id;

        final entries = await processEntries(
          userId: userId,
          processId: processId,
        ).get();
        for (final entryDoc in entries.docs) {
          final entryId = entryDoc.id;

          final points = await entryPoints(
            userId: userId,
            processId: processId,
            entryId: entryId,
          ).get();
          for (final pointDoc in points.docs) {
            await pointDoc.reference.delete();
          }

          await entryDoc.reference.delete();
        }

        final snapshots = await processEntryOrders(
          userId: userId,
          processId: processId,
        ).get();
        for (final snapDoc in snapshots.docs) {
          await snapDoc.reference.delete();
        }

        await processDoc.reference.delete();
      }

      await userDoc(userId).delete();
      debugPrint('✅ Firestore account data deleted for user $userId');
    } catch (e) {
      debugPrint('❌ Failed to delete Firestore account: $e');
    }
  }

  // fetch entry orders from firestore
  static Future<Map<String, int>> fetchOrderFromFirestore(
    String userId,
    String processId,
  ) async {
    final orderMap = <String, int>{};
    final orderMapRef = await processEntryOrders(
      userId: userId,
      processId: processId,
    ).get();
    for (final orderDoc in orderMapRef.docs) {
      final data = orderDoc.data();
      orderMap[data['entryId']] = data['sortIndex'];
    }

    debugPrint(
      '📦 Fetched sort order for ${orderMap.length} entries from Firestore for process $processId',
    );
    return orderMap;
  }
}
