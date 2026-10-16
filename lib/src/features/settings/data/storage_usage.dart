import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../data/database.dart';

/// What the app stores on this device.
class StorageUsage {
  const StorageUsage({
    required this.databaseBytes,
    required this.imageCacheBytes,
    required this.accounts,
    required this.records,
  });

  final int databaseBytes;
  final int imageCacheBytes;
  final int accounts;
  final int records;

  int get totalBytes => databaseBytes + imageCacheBytes;
}

/// Key of flutter_cache_manager's default store (CachedNetworkImage).
const imageCacheKey = 'libCachedImageData';

/// Total size of all files under [dir] (0 if it doesn't exist).
Future<int> directorySize(Directory dir) async {
  if (!await dir.exists()) return 0;
  var total = 0;
  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      try {
        total += await entity.length();
      } on FileSystemException {
        // File vanished mid-scan (cache eviction); ignore it.
      }
    }
  }
  return total;
}

/// Size of the SQLite file plus its WAL / shared-memory / journal siblings.
Future<int> databaseSize(Directory dir, {String name = databaseName}) async {
  var total = 0;
  for (final suffix in const [
    '.sqlite',
    '.sqlite-wal',
    '.sqlite-shm',
    '.sqlite-journal',
  ]) {
    final file = File(p.join(dir.path, '$name$suffix'));
    if (await file.exists()) total += await file.length();
  }
  return total;
}

/// Measures disk usage. Counts come from the caller (they need the database).
Future<StorageUsage> measureStorage({
  required int accounts,
  required int records,
}) async {
  final documents = await getApplicationDocumentsDirectory();
  final temp = await getTemporaryDirectory();
  return StorageUsage(
    databaseBytes: await databaseSize(documents),
    imageCacheBytes: await directorySize(
      Directory(p.join(temp.path, imageCacheKey)),
    ),
    accounts: accounts,
    records: records,
  );
}

/// Human-readable size using 1024-based units ("1.4 MB").
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes / 1024;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = value >= 100 || value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  return '$text ${units[unit]}';
}
