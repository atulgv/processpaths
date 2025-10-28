import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'entry_order.g.dart';

@HiveType(typeId: 3)
class EntryOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(2)
  String entryId;

  @HiveField(3)
  int sortIndex;

  EntryOrder({
    required this.id,
    required this.entryId,
    required this.sortIndex,
  });

  EntryOrder copyWith({
    String? id,
    String? processId,
    String? entryId,
    int? sortIndex,
  }) {
    return EntryOrder(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'entryId': entryId, 'sortIndex': sortIndex};
  }

  factory EntryOrder.fromMap(String id, Map<String, dynamic> data) {
    return EntryOrder(
      id: id,
      entryId: data['entryId'] ?? '',
      sortIndex: data['sortIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  factory EntryOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EntryOrder.fromMap(doc.id, data);
  }

  Map<String, dynamic> toHive() => toMap();

  factory EntryOrder.fromHive(Map<String, dynamic> data) =>
      EntryOrder.fromMap(data['id'] ?? '', data);
}
