import 'convene_record.dart';
import 'pity_calculator.dart';
import 'pool_type.dart';

/// One pull type's contribution to the overview.
class PoolSummary {
  const PoolSummary({
    required this.pool,
    required this.total,
    required this.fiveStars,
    required this.pity5,
  });

  final PoolType pool;
  final int total;
  final int fiveStars;

  /// Pulls since this pool's last 5★.
  final int pity5;
}

/// A 5★ together with the pull type it came from.
class TimelineItem {
  const TimelineItem(this.entry, this.pool);

  final FiveStarEntry entry;
  final PoolType pool;
}

/// Statistics over every pull type of one account.
class OverviewStats {
  const OverviewStats({
    required this.total,
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.averagePullsPerFiveStar,
    required this.averagePullsPerFourStar,
    required this.typeCounts,
    required this.pools,
    required this.timeline,
    required this.pullsSinceLastFive,
  });

  final int total;
  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final double? averagePullsPerFiveStar;
  final double? averagePullsPerFourStar;

  /// Item types (API `resourceType`) with counts, most common first.
  final List<(String, int)> typeCounts;

  /// One entry per pull type, in [PoolType.values] order.
  final List<PoolSummary> pools;

  /// Every 5★ of every pull type, newest first.
  final List<TimelineItem> timeline;

  /// Pulls made, across all pull types, since the newest 5★ of any of them.
  final int pullsSinceLastFive;
}

/// [recordsByPool] holds each pool's records oldest first. Averages combine the
/// per-pool segments, so they match what each pool shows on its own.
OverviewStats calculateOverview(
  Map<PoolType, List<ConveneRecord>> recordsByPool,
) {
  var total = 0, five = 0, four = 0, three = 0;
  var spent5 = 0, spent4 = 0, hits4 = 0;
  final types = <String, int>{};
  final pools = <PoolSummary>[];
  final timeline = <(TimelineItem, int)>[];
  var order = 0;
  // Newest 5★ across pull types, for the "pulls since last 5★" count.
  ({String time, PoolType pool, int index})? newestFive;

  for (final pool in PoolType.values) {
    final records = recordsByPool[pool] ?? const <ConveneRecord>[];
    final stats = calculatePoolStats(pool, [
      for (final r in records)
        Pull(
          name: r.name,
          rarity: r.rarity,
          time: r.time,
          resourceId: r.resourceId,
          resourceType: r.resourceType,
        ),
    ]);
    total += stats.total;
    five += stats.fiveStars;
    four += stats.fourStars;
    three += stats.threeStars;
    spent5 += stats.fiveStarHistory.fold<int>(0, (s, e) => s + e.pullsUsed);
    spent4 += stats.total - stats.pity4;
    hits4 += stats.fourStars + stats.fiveStars;
    for (final r in records) {
      if (r.resourceType.isNotEmpty) {
        types[r.resourceType] = (types[r.resourceType] ?? 0) + 1;
      }
    }
    for (final e in stats.fiveStarHistory.reversed) {
      timeline.add((TimelineItem(e, pool), order++));
    }
    final lastFive = records.lastIndexWhere((r) => r.rarity >= 5);
    if (lastFive >= 0) {
      final time = records[lastFive].time;
      final n = newestFive;
      // Same second in two pull types: the higher pull type id counts newer.
      if (n == null ||
          time.compareTo(n.time) > 0 ||
          (time == n.time && pool.id > n.pool.id)) {
        newestFive = (time: time, pool: pool, index: lastFive);
      }
    }
    pools.add(
      PoolSummary(
        pool: pool,
        total: stats.total,
        fiveStars: stats.fiveStars,
        pity5: stats.pity5,
      ),
    );
  }

  timeline.sort((a, b) {
    final byTime = b.$1.entry.time.compareTo(a.$1.entry.time);
    if (byTime != 0) return byTime;
    final byPool = b.$1.pool.id.compareTo(a.$1.pool.id);
    return byPool != 0 ? byPool : a.$2.compareTo(b.$2);
  });

  var since = 0;
  for (final pool in PoolType.values) {
    final records = recordsByPool[pool] ?? const <ConveneRecord>[];
    final n = newestFive;
    if (n == null) {
      since += records.length;
    } else if (pool == n.pool) {
      since += records.length - n.index - 1;
    } else {
      since += records.where((r) => r.time.compareTo(n.time) > 0).length;
    }
  }

  return OverviewStats(
    total: total,
    fiveStars: five,
    fourStars: four,
    threeStars: three,
    averagePullsPerFiveStar: five == 0 ? null : spent5 / five,
    averagePullsPerFourStar: hits4 == 0 ? null : spent4 / hits4,
    typeCounts: (types.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2))),
    pools: pools,
    timeline: [for (final (item, _) in timeline) item],
    pullsSinceLastFive: since,
  );
}
