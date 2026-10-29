import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/data/convene_repository.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/features/guide/data/guide_service.dart';
import 'package:solaris_record_app/src/features/guide/domain/guide_entry.dart';
import 'package:solaris_record_app/src/features/import/domain/convene_api.dart';
import 'package:solaris_record_app/src/features/settings/data/record_repair.dart';
import 'package:solaris_record_app/src/features/stats/domain/convene_record.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';

RemoteRecord _pull(
  String name,
  String time, {
  int id = 0,
  String type = '',
  int rarity = 5,
}) => RemoteRecord(
  poolType: '',
  resourceId: id,
  time: time,
  name: name,
  resourceType: type,
  rarity: rarity,
  count: 1,
);

void main() {
  late AppDatabase db;
  late ConveneRepository repo;
  late RecordRepair repair;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = ConveneRepository(db);
    await repo.upsertAccount(uid: '100', serverId: 'svr');
    final lists = {
      GuideService.listUrl(GuideKind.resonator, 'en'): '''
        {"roleList": [
          {"Id": 1404, "Name": "Jiyan", "QualityId": 5},
          {"Id": 5001, "Name": "Rover: Havoc", "QualityId": 5},
          {"Id": 5002, "Name": "Rover: Havoc", "QualityId": 5}
        ]}''',
      GuideService.listUrl(GuideKind.weapon, 'en'): '''
        {"weapons": [
          {"Id": 21010015, "Name": "Lustrous Razor", "QualityId": 5},
          {"Id": 21040016, "Name": "Verity's Handle", "QualityId": 5}
        ]}''',
    };
    repair = RecordRepair(
      repo,
      GuideService(loadJson: (url) async => lists[url]!),
    );
  });

  tearDown(() => db.close());

  Future<List<ConveneRecord>> rows(PoolType pool) =>
      repo.watchRecords('100', pool).first;

  test('fills the id and type of a record that has none', () async {
    await repo.mergeRecords('100', PoolType.featuredResonator, [
      _pull('Jiyan', '2024-05-25 12:38:44'),
    ]);
    await repo.mergeRecords('100', PoolType.featuredWeapon, [
      // A typographic apostrophe still matches the list's plain one.
      _pull('Verity’s Handle', '2024-09-12 20:53:29'),
    ]);

    final report = await repair.run();

    expect(report.fixed, 2);
    expect(report.remaining, 0);
    final jiyan = (await rows(PoolType.featuredResonator)).single;
    expect((jiyan.resourceId, jiyan.resourceType), (1404, 'Resonator'));
    final handle = (await rows(PoolType.featuredWeapon)).single;
    expect((handle.resourceId, handle.resourceType), (21040016, 'Weapon'));
  });

  test('never replaces an id the record already has', () async {
    await repo.mergeRecords('100', PoolType.featuredWeapon, [
      _pull('Lustrous Razor', '2024-07-03 15:11:06'),
      _pull('Lustrous Razor', '2025-01-01 00:00:00', id: 77, type: 'Weapon'),
    ]);

    final report = await repair.run();

    expect(report.fixed, 1);
    final byTime = {
      for (final r in await rows(PoolType.featuredWeapon)) r.time: r,
    };
    expect(byTime['2024-07-03 15:11:06']!.resourceId, 21010015);
    expect(byTime['2025-01-01 00:00:00']!.resourceId, 77);
  });

  test('leaves a name that more than one item carries alone', () async {
    await repo.mergeRecords('100', PoolType.featuredResonator, [
      _pull('Rover: Havoc', '2024-06-01 10:00:00'),
    ]);

    final report = await repair.run();

    expect(report.fixed, 0);
    expect(report.remaining, 1);
    final rover = (await rows(PoolType.featuredResonator)).single;
    expect((rover.resourceId, rover.resourceType), (0, ''));
  });

  test('a second run changes nothing', () async {
    await repo.mergeRecords('100', PoolType.featuredWeapon, [
      _pull('Lustrous Razor', '2024-07-03 15:11:06'),
    ]);

    expect((await repair.run()).fixed, 1);
    final again = await repair.run();

    expect(again.fixed, 0);
    expect(again.nothingToDo, isTrue);
  });
}
