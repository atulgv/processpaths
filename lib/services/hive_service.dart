import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../models/process.dart';
import '../models/entry.dart';
import '../models/point.dart';
import '../models/entry_order.dart';
import 'package:flutter/widgets.dart';

class HiveService {
  static final Set<String> _openedPointBoxes = {};

  static Future<void> initialize() async {
    // initialize hive
    await Hive.initFlutter();

    // register process adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProcessAdapter());
    }

    // register entry adapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(EntryAdapter());
    }

    // register point adapter
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PointAdapter());
    }

    // register entry order adapter
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(EntryOrderAdapter());
    }

    await Hive.openBox<Process>(AppConstants.processBox);
    final processes = processBox.values.toList();

    if (processes.isNotEmpty) {
      await preloadEntryBoxes(processes);
    }
  }

  // hive processbox
  static Box<Process> get processBox =>
      Hive.box<Process>(AppConstants.processBox);

  // hive entrybox
  static Box<Entry> entryBoxFor(Process process) {
    final boxName = '${AppConstants.entryBoxPrefix}${process.id}';
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'Box "$boxName" is not open. Call Hive.openBox("$boxName") before accessing it.',
      );
    }
    return Hive.box<Entry>(boxName);
  }

  // hive pointbox
  static Box<Point> pointBoxFor(Entry entry) {
    final boxName = '${AppConstants.pointBoxPrefix}${entry.id}';
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'Box "$boxName" is not open. Call Hive.openBox("$boxName") before accessing it.',
      );
    }
    return Hive.box<Point>(boxName);
  }

  // hive entryorderbox
  static Box<EntryOrder> entryOrderBoxFor(Process process) {
    final boxName = '${AppConstants.entryOrderBoxPrefix}${process.id}';
    if (!Hive.isBoxOpen(boxName)) {
      throw HiveError(
        'Box "$boxName" is not open. Call Hive.openBox("$boxName") before accessing it.',
      );
    }
    return Hive.box<EntryOrder>(boxName);
  }

  // pre-load entrybox
  static Future<void> preloadEntryBoxes(List<Process> processes) async {
    for (final process in processes) {
      final boxName = '${AppConstants.entryBoxPrefix}${process.id}';
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Entry>(boxName);
      }
    }
  }

  // pre-load pointbox
  static Future<void> preloadPointBoxes(List<Entry> entries) async {
    for (final entry in entries) {
      final boxName = '${AppConstants.pointBoxPrefix}${entry.id}';
      if (_openedPointBoxes.contains(boxName)) {
        debugPrint('✅ Point box already open (cached): $boxName');
        continue;
      }

      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Point>(boxName);
        debugPrint('📦 Point box opened: $boxName');
      } else {
        debugPrint('✅ Point box already open: $boxName');
      }

      _openedPointBoxes.add(boxName);
    }
  }

  // ensure that process box is open
  static Future<void> ensureProcessBoxOpen() async {
    final boxName = AppConstants.processBox;
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Entry>(boxName);
    }
  }

  // ensure that entry box is open
  static Future<void> ensureEntryBoxOpen(Process process) async {
    final boxName = '${AppConstants.entryBoxPrefix}${process.id}';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Entry>(boxName);
    }
  }

  // ensure that point box is open
  static Future<void> ensurePointBoxOpen(Entry entry) async {
    final boxName = '${AppConstants.pointBoxPrefix}${entry.id}';
    if (_openedPointBoxes.contains(boxName)) return;

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Point>(boxName);
      debugPrint('📦 Point box opened: $boxName');
    } else {
      debugPrint('✅ Point box already open: $boxName');
    }

    _openedPointBoxes.add(boxName);
  }

  // ensure that entry order box is open
  static Future<void> ensureEntryOrderBoxOpen(Process process) async {
    final boxName = '${AppConstants.entryOrderBoxPrefix}${process.id}';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<EntryOrder>(boxName);
    }
  }

  // loading points
  static Future<List<Point>> loadPointsForEntry(Entry entry) async {
    await ensurePointBoxOpen(entry);
    final box = pointBoxFor(entry);
    final points = box.values.whereType<Point>().toList();
    debugPrint(
      '📦 Loaded ${points.length} points from Hive for entry ${entry.id}',
    );
    return points;
  }

  // save entry orders
  static Future<void> saveEntryOrderToHive(
    Process process,
    List<Entry> entries,
  ) async {
    await ensureProcessBoxOpen();
    await ensureEntryOrderBoxOpen(process);

    final snapshotBox = entryOrderBoxFor(process);
    snapshotBox.clear();

    for (final entry in entries) {
      snapshotBox.put(
        process.id,
        EntryOrder(
          id: process.id,
          entryId: entry.id,
          sortIndex: entry.sortIndex,
        ),
      );
    }

    debugPrint('✅ Sort snapshot saved for process ${process.id}');
  }

  // fetch entry orders from hive
  static Future<Map<String, int>> fetchOrderFromHive(Process process) async {
    await ensureProcessBoxOpen();
    await ensureEntryOrderBoxOpen(process);

    final snapshotBox = entryOrderBoxFor(process);
    final orderMap = <String, int>{};

    for (final snapshot in snapshotBox.values) {
      orderMap[snapshot.entryId] = snapshot.sortIndex;
    }

    debugPrint(
      '📦 Fetched sort order for ${orderMap.length} entries from snapshot for process ${process.id}',
    );
    return orderMap;
  }

  // delete entry orders from hive
  static Future<void> deleteAccountFromHive() async {
    try {
      await ensureProcessBoxOpen();
      final processes = processBox.values.toList();

      // Delete entry, point, and sort boxes
      for (final process in processes) {
        await ensureEntryBoxOpen(process);

        final entries = entryBoxFor(process).values.toList();

        for (final entry in entries) {
          await ensurePointBoxOpen(entry);
          if (pointBoxFor(entry).isOpen && pointBoxFor(entry).isNotEmpty) {
            await pointBoxFor(entry).deleteFromDisk();
          }
        }

        ensureEntryOrderBoxOpen(process);
        if (entryBoxFor(process).isOpen && entryBoxFor(process).isNotEmpty) {
          await entryBoxFor(process).deleteFromDisk();
        }

        // ✅ Now delete entry box
        await entryBoxFor(process).deleteFromDisk();
      }

      // ✅ Finally delete process box
      await processBox.deleteFromDisk();

      debugPrint('✅ Hive account data deleted successfully');
    } catch (e, st) {
      debugPrint('❌ Failed to delete Hive account: $e\n$st');
    }
  }

  // clear everything from hive
  static Future<void> clearAll() async {
    await deleteAccountFromHive();
    await Hive.close();
    _openedPointBoxes.clear();
  }
}
