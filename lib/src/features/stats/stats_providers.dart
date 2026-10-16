import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import 'domain/convene_record.dart';
import 'domain/overview_stats.dart';
import 'domain/pity_calculator.dart';
import 'domain/pool_type.dart';

part 'stats_providers.g.dart';

@riverpod
Stream<List<ConveneRecord>> records(Ref ref, String uid, PoolType pool) =>
    ref.watch(conveneRepositoryProvider).watchRecords(uid, pool);

@riverpod
AsyncValue<PoolStats> poolStats(Ref ref, String uid, PoolType pool) {
  return ref
      .watch(recordsProvider(uid, pool))
      .whenData(
        (rows) => calculatePoolStats(pool, [
          for (final r in rows)
            Pull(
              name: r.name,
              rarity: r.rarity,
              time: r.time,
              resourceId: r.resourceId,
              resourceType: r.resourceType,
            ),
        ]),
      );
}

/// Statistics over every pull type of [uid]; loading until all pools arrived.
@riverpod
AsyncValue<OverviewStats> overviewStats(Ref ref, String uid) {
  final byPool = <PoolType, List<ConveneRecord>>{};
  for (final pool in PoolType.values) {
    final records = ref.watch(recordsProvider(uid, pool));
    if (records.hasError) {
      return AsyncError(records.error!, records.stackTrace ?? StackTrace.empty);
    }
    if (!records.hasValue) return const AsyncLoading();
    byPool[pool] = records.requireValue;
  }
  return AsyncData(calculateOverview(byPool));
}
