import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'entry.dart';

part 'process.g.dart';

@HiveType(typeId: 0)
class Process extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<Entry> entries;

  @HiveField(3)
  DateTime timestamp;

  Process({
    required this.id,
    required this.title,
    this.entries = const [],
    required this.timestamp,
  });

  int get entryCount => entries.length;

  Process copyWith({
    String? id,
    String? title,
    List<Entry>? entries,
    DateTime? timestamp,
  }) {
    return Process(
      id: id ?? this.id,
      title: title ?? this.title,
      entries: entries ?? this.entries,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'timestamp': timestamp.toIso8601String()};
  }

  factory Process.fromMap(String id, Map<String, dynamic> data) {
    return Process(
      id: id,
      title: data['title'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      entries: [],
    );
  }
  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  factory Process.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Process.fromMap(doc.id, data);
  }

  Map<String, dynamic> toHive() => toMap();

  factory Process.fromHive(Map<String, dynamic> data) =>
      Process.fromMap(data['id'] ?? '', data);
}
