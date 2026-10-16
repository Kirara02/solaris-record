import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/features/stats/domain/convene_record.dart';
import 'package:solaris_record_app/src/features/stats/domain/overview_stats.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';
import 'package:solaris_record_app/src/features/stats/pool_selection.dart';
import 'package:solaris_record_app/src/features/stats/stats_providers.dart';
import 'package:solaris_record_app/src/shared/widgets/donut_chart.dart';
import 'package:solaris_record_app/src/shared/widgets/settings_group.dart';

import '../../support/app_harness.dart';

ConveneRecord rec(
  PoolType pool,
  int i,
  int rarity, {
  String type = 'Weapon',
  String name = 'Item',
}) => ConveneRecord(
  uid: '100',
  poolType: pool.id,
  time: '2025-01-01 00:00:${(i % 60).toString().padLeft(2, '0')}',
  name: rarity == 5 ? 'Jinhsi' : name,
  resourceType: type,
  rarity: rarity,
  count: 1,
  recordIndex: i,
);

/// Featured resonator: 30 pulls, a 5★ at #10 and a 4★ at #20 (10 pulls
/// since the 5★ at the end... pity5 = 20). Featured weapon: 10 weapons, no 5★.
Map<PoolType, List<ConveneRecord>> sample() => {
  PoolType.featuredResonator: [
    for (var i = 1; i <= 30; i++)
      rec(
        PoolType.featuredResonator,
        i,
        i == 10 ? 5 : (i == 20 ? 4 : 3),
        type: (i == 10 || i == 20) ? 'Resonator' : 'Weapon',
      ),
  ],
  PoolType.featuredWeapon: [
    for (var i = 1; i <= 10; i++) rec(PoolType.featuredWeapon, i, 3),
  ],
};

List<Override> overrides(Map<PoolType, List<ConveneRecord>> data) => [
  for (final p in PoolType.values)
    recordsProvider(
      '100',
      p,
    ).overrideWith((ref) => Stream.value(data[p] ?? const [])),
];

void main() {
  setUpAll(loadInterFont);

  group('calculateOverview', () {
    final stats = calculateOverview(sample());

    test('totals and rarity counts span every pull type', () {
      expect(stats.total, 40);
      expect(stats.fiveStars, 1);
      expect(stats.fourStars, 1);
      expect(stats.threeStars, 38);
    });

    test('averages combine each pool\'s completed segments', () {
      // One 5★ after 10 pulls.
      expect(stats.averagePullsPerFiveStar, 10);
      // Resonator pool: pulls 1-20 contain two 4★-or-better hits (10 and 20);
      // pity4 at the end is 10 (pulls 21-30), so (30 - 10) / 2 = 10.
      // The weapon pool has none (pity4 = 10, hits = 0) and adds (10 - 10) / 0.
      expect(stats.averagePullsPerFourStar, closeTo((20 + 0) / 2, 1e-9));
    });

    test('type counts are most common first', () {
      expect(stats.typeCounts, [('Weapon', 38), ('Resonator', 2)]);
    });

    test('one summary per pool in order, with pity and 5★ counts', () {
      expect(stats.pools.map((p) => p.pool), PoolType.values);
      final fr = stats.pools.first;
      expect((fr.total, fr.fiveStars, fr.pity5), (30, 1, 20));
      final fw = stats.pools[1];
      expect((fw.total, fw.fiveStars, fw.pity5), (10, 0, 10));
      expect(stats.pools.last.total, 0);
    });

    test('empty input', () {
      final empty = calculateOverview(const {});
      expect(empty.total, 0);
      expect(empty.averagePullsPerFiveStar, isNull);
      expect(empty.averagePullsPerFourStar, isNull);
      expect(empty.typeCounts, isEmpty);
      expect(empty.pools, hasLength(PoolType.values.length));
    });
  });

  group('DonutChart', () {
    testWidgets('legend shows counts and shares', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DonutChart(
              segments: const [
                DonutSegment(label: '5★', value: 28, color: Colors.amber),
                DonutSegment(label: '4★', value: 216, color: Colors.purple),
                DonutSegment(label: '3★', value: 1547, color: Colors.blue),
              ],
            ),
          ),
        ),
      );
      expect(find.text('28'), findsOneWidget);
      expect(find.text('1.56%'), findsOneWidget);
      expect(find.text('12.06%'), findsOneWidget);
      expect(find.text('86.38%'), findsOneWidget);
    });

    test('percentOf uses two decimals', () {
      expect(DonutChart.percentOf(1, 3), '33.33');
    });
  });

  testWidgets('desktop opens on the overview with all its sections', (
    tester,
  ) async {
    late AppDatabase database;
    await pumpApp(
      tester,
      size: const Size(1360, 860),
      onDatabase: (db) => database = db,
      extraOverrides: overrides(sample()),
    );
    await tester.runAsync(
      () => database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(uid: '100', serverId: 's')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Title and stat cards (labels are upper-cased by the card).
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Overview')),
      findsOneWidget,
    );
    expect(find.text('TOTAL PULLS'), findsOneWidget);
    expect(find.text('40'), findsWidgets);
    expect(find.text('5★ COUNT'), findsOneWidget);
    expect(find.text('4★ COUNT'), findsOneWidget);
    // 1 of 40 = 2.50% for both the 5★ and the 4★ card, avg 10 pulls each.
    expect(find.text('2.50% of total · Avg 10.00 pulls'), findsNWidgets(2));

    expect(find.text('Rarity distribution'), findsOneWidget);
    expect(find.text('Type distribution'), findsOneWidget);
    expect(find.text('Pity per pull type'), findsOneWidget);
    // Per-pool pity rows: shown in the 5★-per-pull-type card and the pity card.
    expect(
      find.text('20 pulls since last 5★', skipOffstage: false),
      findsNWidgets(2),
    );
    expect(
      find.text('No 5★ yet', skipOffstage: false),
      findsOneWidget,
    ); // featured weapon
    expect(
      find.text('No pulls in this pool yet.', skipOffstage: false),
      findsWidgets,
    ); // untouched pools

    // The overview has no pull-type selector chips on desktop.
    expect(find.byType(SettingsChoiceChip), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('selecting a pull type leaves the overview and back', (
    tester,
  ) async {
    late AppDatabase database;
    await pumpApp(
      tester,
      size: const Size(1360, 860),
      onDatabase: (db) => database = db,
      extraOverrides: overrides(sample()),
    );
    await tester.runAsync(
      () => database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(uid: '100', serverId: 's')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    Finder inRail(String text) => find.descendant(
      of: find.byType(M3ENavigationRail),
      matching: find.text(text),
    );
    PoolType? selected() =>
        ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
            .read(selectedPoolProvider);

    await tester.tap(inRail('Featured Resonator'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(selected(), PoolType.featuredResonator);
    expect(find.text('Rarity distribution'), findsNothing);
    expect(find.text('5★ pity'), findsOneWidget);

    await tester.tap(inRail('Overview'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(selected(), isNull);
    expect(find.text('Rarity distribution'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('an account with no pulls shows the empty overview message', (
    tester,
  ) async {
    late AppDatabase database;
    await pumpApp(
      tester,
      size: const Size(1360, 860),
      onDatabase: (db) => database = db,
      extraOverrides: overrides(const {}),
    );
    await tester.runAsync(
      () => database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(uid: '100', serverId: 's')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('No pulls yet. Import your records to see the overview.'),
      findsOneWidget,
    );
    await disposeApp(tester);
  });
}
