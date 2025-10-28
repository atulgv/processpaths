import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'point.g.dart';

@HiveType(typeId: 2)
class Point extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;

  Point({required this.id, required this.content, required this.timestamp});

  Point copyWith({String? id, String? content, DateTime? timestamp}) {
    return Point(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Point.fromMap(String id, Map<String, dynamic> data) {
    return Point(
      id: id,
      content: data['content'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  factory Point.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Point.fromMap(doc.id, data);
  }

  Map<String, dynamic> toHive() => toMap();

  factory Point.fromHive(Map<String, dynamic> data) =>
      Point.fromMap(data['id'] ?? '', data);
}
