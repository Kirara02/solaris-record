import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Name given to `driftDatabase(name:)`; the file is `<name>.sqlite`.
const databaseName = 'solaris_record';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get uid => text()();
  TextColumn get alias => text().nullable()();
  TextColumn get serverId => text()();

  /// 1-based order in which the account was added; names it "Account N" while
  /// it has no alias. 0 only for rows inserted without one.
  IntColumn get number => integer().withDefault(const Constant(0))();

  /// Position in the account list, set by dragging (schema v4). Separate from
  /// [number] so reordering never renames an alias-less account.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {uid};
}

@DataClassName('ConveneRecordRow')
class ConveneRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().references(Accounts, #uid)();
  IntColumn get poolType => integer()();
  TextColumn get time => text()();
  TextColumn get name => text()();
  TextColumn get resourceType => text()();
  IntColumn get rarity => integer()();
  IntColumn get count => integer()();

  /// Chronological position among records sharing the same `time` (a 10-pull
  /// shares one timestamp). Makes the unique key below stable across imports.
  IntColumn get recordIndex => integer()();

  /// Game resource id (used to look up icons). 0 for rows imported before
  /// schema v2; a later import backfills it.
  IntColumn get resourceId => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {uid, poolType, time, name, recordIndex},
  ];
}

@DriftDatabase(tables: [Accounts, ConveneRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: databaseName));

  @override
  int get schemaVersion => 4;

  /// Lets an upgrade step re-run safely when the column already exists (e.g.
  /// a database touched by a build with a newer schema).
  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        if (!await _hasColumn('convene_records', 'resource_id')) {
          await m.addColumn(conveneRecords, conveneRecords.resourceId);
        }
      }
      if (from < 3) {
        if (!await _hasColumn('accounts', 'number')) {
          await m.addColumn(accounts, accounts.number);
        }
        // Existing accounts keep the order they were added in (insertion
        // order, which rowid still reflects at this point).
        final rows = await customSelect(
          'SELECT uid FROM accounts ORDER BY rowid',
        ).get();
        for (final (i, row) in rows.indexed) {
          await customStatement(
            'UPDATE accounts SET number = ? WHERE uid = ?',
            [i + 1, row.read<String>('uid')],
          );
        }
      }
      if (from < 4) {
        if (!await _hasColumn('accounts', 'sort_order')) {
          await m.addColumn(accounts, accounts.sortOrder);
        }
        // The list starts in the order accounts were added.
        await customStatement('UPDATE accounts SET sort_order = number');
      }
    },
  );
}
