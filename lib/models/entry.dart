import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'point.dart';

part 'entry.g.dart';

@HiveType(typeId: 1)
class Entry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  List<Point> points;

  @HiveField(4)
  bool isDone = false;

  @HiveField(5)
  int sortIndex;

  Entry({
    required this.id,
    required this.title,
    required this.timestamp,
    this.points = const [],
    this.isDone = false,
    required this.sortIndex,
  });

  Entry copyWith({
    String? id,
    String? title,
    DateTime? timestamp,
    List<Point>? points,
    bool? isDone,
    int? sortIndex,
  }) {
    return Entry(
      id: id ?? this.id,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      points: points ?? this.points,
      isDone: isDone ?? this.isDone,
      sortIndex: sortIndex ?? this.sortIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'isDone': isDone,
      'sortIndex': sortIndex,
    };
  }

  factory Entry.fromMap(String id, Map<String, dynamic> data) {
    return Entry(
      id: id,
      title: data['title'] ?? '',
      timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      isDone: data['isDone'] ?? false,
      sortIndex: data['sortIndex'] ?? 0,
      points: [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }

  factory Entry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Entry.fromMap(doc.id, data);
  }

  Map<String, dynamic> toHive() => toMap();

  factory Entry.fromHive(Map<String, dynamic> data) =>
      Entry.fromMap(data['id'] ?? '', data);
}
