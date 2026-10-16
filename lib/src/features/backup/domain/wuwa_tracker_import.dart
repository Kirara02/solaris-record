import '../../stats/domain/pool_type.dart';
import 'backup_bundle.dart';

/// WuWa Tracker exports times as UTC instants; the game's servers all run on
/// UTC+8, and the API (hence this app's database) stores that wall clock.
const _serverOffset = Duration(hours: 8);

String _wallClock(String isoTime) {
  // A time without a zone is treated as UTC, like the tracker's own exports.
  final hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(isoTime);
  final t = DateTime.parse(hasZone ? isoTime : '${isoTime}Z')
      .toUtc()
      .add(_serverOffset);
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

String _typeForId(int id) {
  final digits = id.toString().length;
  return digits == 4
      ? 'Resonator'
      : digits == 8
      ? 'Weapon'
      : '';
}

/// Whether [json] looks like a WuWa Tracker (wuwatracker.com) pulls export.
bool isWuwaTrackerFile(Map<String, dynamic> json) =>
    json['playerId'] is String && json['pulls'] is List;

/// Converts a WuWa Tracker export (`{playerId, pulls: [...]}`) to a bundle.
///
/// Pulls of pools this app doesn't know are skipped. Records missing a
/// `resourceId` borrow it from another pull of the same name in the file, and
/// otherwise stay 0 (a later URL import backfills them).
BackupBundle parseWuwaTracker(Map<String, dynamic> json) {
  final uid = json['playerId'] as String;
  final pulls = json['pulls'] as List<dynamic>;

  final idByName = <String, int>{};
  for (final p in pulls) {
    if (p is! Map<String, dynamic>) continue;
    final id = p['resourceId'];
    final name = p['name'];
    if (id is num && name is String && id.toInt() > 0) {
      idByName.putIfAbsent(name, () => id.toInt());
    }
  }

  final byPool = <int, List<Map<String, dynamic>>>{};
  for (final p in pulls) {
    if (p is! Map<String, dynamic>) {
      throw const FormatException('pulls entry');
    }
    final pool = (p['cardPoolType'] as num).toInt();
    if (!PoolType.values.any((t) => t.id == pool)) continue;
    byPool.putIfAbsent(pool, () => []).add(p);
  }

  final records = <BackupRecord>[];
  for (final MapEntry(key: pool, value: entries) in byPool.entries) {
    final withTime = [
      for (final p in entries) (p, _wallClock(p['time'] as String)),
    ];
    // Newest first; file order breaks ties, the same order the API returns
    // within a 10-pull, so indexes line up with later URL imports.
    final indexed = withTime.indexed.toList()
      ..sort((a, b) {
        final byTime = b.$2.$2.compareTo(a.$2.$2);
        return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
      });
    final seen = <String, int>{};
    for (final (_, (p, time)) in indexed.reversed) {
      final name = p['name'] as String;
      final rawId = p['resourceId'];
      final id = rawId is num && rawId.toInt() > 0
          ? rawId.toInt()
          : (idByName[name] ?? 0);
      records.add(
        BackupRecord(
          poolType: pool,
          time: time,
          name: name,
          resourceType: _typeForId(id),
          resourceId: id,
          rarity: (p['qualityLevel'] as num).toInt(),
          count: 1,
          recordIndex: seen.update(time, (v) => v + 1, ifAbsent: () => 0),
        ),
      );
    }
  }

  return BackupBundle(
    exportedAt:
        DateTime.tryParse(json['date'] as String? ?? '')?.toUtc() ??
        DateTime.now().toUtc(),
    appVersion: '',
    accounts: [BackupAccount(uid: uid, serverId: '', records: records)],
  );
}
