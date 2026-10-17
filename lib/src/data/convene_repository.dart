import 'package:drift/drift.dart';

import '../features/accounts/domain/account.dart';
import '../features/backup/domain/backup_bundle.dart';
import '../features/import/domain/convene_api.dart';
import '../features/stats/domain/convene_record.dart';
import '../features/stats/domain/pool_type.dart';
import 'database.dart';

class ConveneRepository {
  ConveneRepository(this._db);

  final AppDatabase _db;

  /// Accounts in the order the user arranged them (new ones go last).
  Stream<List<Account>> watchAccounts() =>
      (_db.select(_db.accounts)..orderBy([
            (a) => OrderingTerm.asc(a.sortOrder),
            (a) => OrderingTerm.asc(a.number),
            (a) => OrderingTerm.asc(a.uid),
          ]))
          .watch()
          .map(
            (rows) => [
              for (final (i, r) in rows.indexed)
                Account(
                  uid: r.uid,
                  serverId: r.serverId,
                  alias: r.alias,
                  // Rows inserted without a number fall back to their place.
                  number: r.number > 0 ? r.number : i + 1,
                ),
            ],
          );

  /// The number the next new account gets.
  Future<int> _nextAccountNumber() async {
    final highest = _db.accounts.number.max();
    final row = await (_db.selectOnly(
      _db.accounts,
    )..addColumns([highest])).getSingle();
    return (row.read(highest) ?? 0) + 1;
  }

  /// The list position the next new account gets (after every existing one).
  Future<int> _nextSortOrder() async {
    final highest = _db.accounts.sortOrder.max();
    final row = await (_db.selectOnly(
      _db.accounts,
    )..addColumns([highest])).getSingle();
    return (row.read(highest) ?? 0) + 1;
  }

  /// Saves the account list order: [uidsInOrder] becomes positions 1..n.
  Future<void> reorderAccounts(List<String> uidsInOrder) =>
      _db.transaction(() async {
        for (final (i, uid) in uidsInOrder.indexed) {
          await (_db.update(_db.accounts)..where((a) => a.uid.equals(uid)))
              .write(AccountsCompanion(sortOrder: Value(i + 1)));
        }
      });

  Future<void> upsertAccount({required String uid, required String serverId}) =>
      _db.transaction(() async {
        final existing = await (_db.select(
          _db.accounts,
        )..where((a) => a.uid.equals(uid))).getSingleOrNull();
        if (existing == null) {
          await _db
              .into(_db.accounts)
              .insert(
                AccountsCompanion.insert(
                  uid: uid,
                  serverId: serverId,
                  number: Value(await _nextAccountNumber()),
                  sortOrder: Value(await _nextSortOrder()),
                ),
              );
        } else if (existing.serverId != serverId) {
          await (_db.update(_db.accounts)..where((a) => a.uid.equals(uid)))
              .write(AccountsCompanion(serverId: Value(serverId)));
        }
      });

  Future<void> setAlias(String uid, String? alias) {
    final trimmed = alias?.trim();
    return (_db.update(_db.accounts)..where((a) => a.uid.equals(uid))).write(
      AccountsCompanion(
        alias: Value(trimmed == null || trimmed.isEmpty ? null : trimmed),
      ),
    );
  }

  /// Row counts for the storage overview.
  Future<({int accounts, int records})> counts() async {
    Future<int> count(TableInfo table) async {
      final n = countAll();
      final row = await (_db.selectOnly(table)..addColumns([n])).getSingle();
      return row.read(n) ?? 0;
    }

    return (
      accounts: await count(_db.accounts),
      records: await count(_db.conveneRecords),
    );
  }

  Future<void> deleteAllData() => _db.transaction(() async {
    await _db.delete(_db.conveneRecords).go();
    await _db.delete(_db.accounts).go();
  });

  Future<void> deleteAccount(String uid) => _db.transaction(() async {
    await (_db.delete(
      _db.conveneRecords,
    )..where((r) => r.uid.equals(uid))).go();
    await (_db.delete(_db.accounts)..where((a) => a.uid.equals(uid))).go();
  });

  /// Every account with all of its records, for a backup file.
  Future<BackupBundle> exportBundle({
    required DateTime now,
    required String appVersion,
  }) async {
    final accounts = await (_db.select(
      _db.accounts,
    )..orderBy([(a) => OrderingTerm.asc(a.uid)])).get();
    final rows =
        await (_db.select(_db.conveneRecords)..orderBy([
              (r) => OrderingTerm.asc(r.poolType),
              (r) => OrderingTerm.asc(r.time),
              (r) => OrderingTerm.asc(r.recordIndex),
            ]))
            .get();
    final byUid = <String, List<BackupRecord>>{};
    for (final r in rows) {
      byUid
          .putIfAbsent(r.uid, () => [])
          .add(
            BackupRecord(
              poolType: r.poolType,
              time: r.time,
              name: r.name,
              resourceType: r.resourceType,
              resourceId: r.resourceId,
              rarity: r.rarity,
              count: r.count,
              recordIndex: r.recordIndex,
            ),
          );
    }
    return BackupBundle(
      exportedAt: now.toUtc(),
      appVersion: appVersion,
      accounts: [
        for (final a in accounts)
          BackupAccount(
            uid: a.uid,
            serverId: a.serverId,
            alias: a.alias,
            records: byUid[a.uid] ?? const [],
          ),
      ],
    );
  }

  /// Merges [bundle] into the local data without removing or overwriting
  /// anything: new accounts and records are added, an existing alias and
  /// server id are kept (blanks are filled), and a known row only gains a
  /// missing resourceId. Returns how many records were new.
  Future<({int accounts, int newRecords})> importBundle(
    BackupBundle bundle,
  ) => _db.transaction(() async {
    Future<int> total() async {
      final n = countAll();
      final row = await (_db.selectOnly(
        _db.conveneRecords,
      )..addColumns([n])).getSingle();
      return row.read(n) ?? 0;
    }

    final before = await total();
    for (final account in bundle.accounts) {
      final existing = await (_db.select(
        _db.accounts,
      )..where((a) => a.uid.equals(account.uid))).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.accounts)
            .insert(
              AccountsCompanion.insert(
                uid: account.uid,
                serverId: account.serverId,
                alias: Value(account.alias),
                number: Value(await _nextAccountNumber()),
                sortOrder: Value(await _nextSortOrder()),
              ),
            );
      } else {
        await (_db.update(
          _db.accounts,
        )..where((a) => a.uid.equals(account.uid))).write(
          AccountsCompanion(
            serverId: existing.serverId.isEmpty && account.serverId.isNotEmpty
                ? Value(account.serverId)
                : const Value.absent(),
            alias: existing.alias == null && account.alias != null
                ? Value(account.alias)
                : const Value.absent(),
          ),
        );
      }

      final target = [
        _db.conveneRecords.uid,
        _db.conveneRecords.poolType,
        _db.conveneRecords.time,
        _db.conveneRecords.name,
        _db.conveneRecords.recordIndex,
      ];
      // Known rows are left alone, except one still lacking its resourceId.
      UpsertClause<$ConveneRecordsTable, ConveneRecordRow> backfill(int id) =>
          DoUpdate<$ConveneRecordsTable, ConveneRecordRow>(
            (_) => ConveneRecordsCompanion(resourceId: Value(id)),
            target: target,
            where: (old) => old.resourceId.equals(0),
          );
      final skip = DoNothing<$ConveneRecordsTable, ConveneRecordRow>(
        target: target,
      );
      await _db.batch((batch) {
        for (final r in account.records) {
          batch.insert(
            _db.conveneRecords,
            ConveneRecordsCompanion.insert(
              uid: account.uid,
              poolType: r.poolType,
              time: r.time,
              name: r.name,
              resourceType: r.resourceType,
              rarity: r.rarity,
              count: r.count,
              recordIndex: r.recordIndex,
              resourceId: Value(r.resourceId),
            ),
            onConflict: r.resourceId > 0 ? backfill(r.resourceId) : skip,
          );
        }
      });
    }
    return (
      accounts: bundle.accounts.length,
      newRecords: await total() - before,
    );
  });

  /// Chronological (oldest first).
  Stream<List<ConveneRecord>> watchRecords(String uid, PoolType pool) =>
      (_db.select(_db.conveneRecords)
            ..where((r) => r.uid.equals(uid) & r.poolType.equals(pool.id))
            ..orderBy([
              (r) => OrderingTerm.asc(r.time),
              (r) => OrderingTerm.asc(r.recordIndex),
            ]))
          .watch()
          .map(
            (rows) => [
              for (final r in rows)
                ConveneRecord(
                  uid: r.uid,
                  poolType: r.poolType,
                  time: r.time,
                  name: r.name,
                  resourceType: r.resourceType,
                  rarity: r.rarity,
                  count: r.count,
                  recordIndex: r.recordIndex,
                  resourceId: r.resourceId,
                ),
            ],
          );

  /// Merges a freshly fetched [newestFirst] page into the local history.
  /// Existing rows are kept, so records the server already dropped survive.
  /// Returns the number of newly inserted rows.
  Future<int> mergeRecords(
    String uid,
    PoolType pool,
    List<RemoteRecord> newestFirst,
  ) async {
    final rows = assignIndexes(uid, pool, newestFirst);
    Future<int> count() async {
      final n = _db.conveneRecords.id.count();
      final query = _db.selectOnly(_db.conveneRecords)
        ..addColumns([n])
        ..where(
          _db.conveneRecords.uid.equals(uid) &
              _db.conveneRecords.poolType.equals(pool.id),
        );
      return (await query.map((r) => r.read(n)).getSingle()) ?? 0;
    }

    // Insert/upsert return values don't distinguish new rows, so diff the count.
    return _db.transaction(() async {
      final before = await count();
      for (final row in rows) {
        // New rows are inserted; existing ones only get their resourceId
        // backfilled (rows imported before schema v2 have 0).
        await _db
            .into(_db.conveneRecords)
            .insert(
              row,
              onConflict: DoUpdate(
                (_) => ConveneRecordsCompanion(resourceId: row.resourceId),
                target: [
                  _db.conveneRecords.uid,
                  _db.conveneRecords.poolType,
                  _db.conveneRecords.time,
                  _db.conveneRecords.name,
                  _db.conveneRecords.recordIndex,
                ],
              ),
            );
      }
      return await count() - before;
    });
  }

  static List<ConveneRecordsCompanion> assignIndexes(
    String uid,
    PoolType pool,
    List<RemoteRecord> newestFirst,
  ) {
    final seen = <String, int>{};
    return [
      for (final r in newestFirst.reversed)
        ConveneRecordsCompanion.insert(
          uid: uid,
          poolType: pool.id,
          time: r.time,
          name: r.name,
          resourceType: r.resourceType,
          rarity: r.rarity,
          count: r.count,
          recordIndex: seen.update(r.time, (v) => v + 1, ifAbsent: () => 0),
          resourceId: Value(r.resourceId),
        ),
    ];
  }
}
