import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/data/convene_repository.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/features/backup/domain/backup_bundle.dart';

void main() {
  late AppDatabase db;
  late ConveneRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = ConveneRepository(db);
    for (final uid in ['100', '200', '300']) {
      await repo.upsertAccount(uid: uid, serverId: 'svr');
    }
  });

  tearDown(() => db.close());

  Future<List<String>> order() async => [
    for (final a in await repo.watchAccounts().first) a.uid,
  ];

  test('accounts start in the order they were added', () async {
    expect(await order(), ['100', '200', '300']);
  });

  test('reordering changes the list but not the "Account N" number', () async {
    await repo.reorderAccounts(['300', '100', '200']);

    final accounts = await repo.watchAccounts().first;
    expect([for (final a in accounts) a.uid], ['300', '100', '200']);
    expect(
      {for (final a in accounts) a.uid: a.number},
      {'100': 1, '200': 2, '300': 3},
    );
  });

  test('a new account goes after the reordered ones', () async {
    await repo.reorderAccounts(['300', '200', '100']);
    await repo.upsertAccount(uid: '400', serverId: 'svr');

    expect(await order(), ['300', '200', '100', '400']);
  });

  test('an account added by a backup import goes last', () async {
    await repo.reorderAccounts(['200', '300', '100']);
    await repo.importBundle(
      BackupBundle(
        exportedAt: DateTime.utc(2026),
        appVersion: '1.3.0',
        accounts: const [
          BackupAccount(uid: '500', serverId: 'svr', records: []),
          BackupAccount(uid: '100', serverId: 'svr', records: []),
        ],
      ),
    );

    expect(await order(), ['200', '300', '100', '500']);
  });

  test(
    'upgrading a v3 database keeps the order accounts were added in',
    () async {
      final old = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            raw.execute(
              'CREATE TABLE accounts (uid TEXT NOT NULL PRIMARY KEY, '
              'alias TEXT NULL, server_id TEXT NOT NULL, '
              'number INTEGER NOT NULL DEFAULT 0)',
            );
            raw.execute(
              "INSERT INTO accounts (uid, server_id, number) VALUES "
              "('900', 's', 2), ('800', 's', 1)",
            );
            raw.execute('PRAGMA user_version = 3');
          },
        ),
      );
      addTearDown(old.close);

      final accounts = await ConveneRepository(old).watchAccounts().first;
      expect([for (final a in accounts) a.uid], ['800', '900']);
    },
  );
}
