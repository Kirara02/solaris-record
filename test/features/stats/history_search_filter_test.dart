import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/data/providers.dart';
import 'package:solaris_record_app/src/features/info/domain/item_info.dart';
import 'package:solaris_record_app/src/features/info/domain/item_kind.dart';
import 'package:solaris_record_app/src/features/stats/domain/convene_record.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';
import 'package:solaris_record_app/src/features/stats/pool_selection.dart';
import 'package:solaris_record_app/src/features/stats/stats_providers.dart';

import '../../support/app_harness.dart';

/// 36 pulls: 30 "Training Sword" 3★ weapons, 4 "Danjin" 4★ and 2 "Jinhsi" 5★
/// resonators.
List<ConveneRecord> records() => [
  for (var i = 0; i < 36; i++)
    ConveneRecord(
      uid: '100',
      poolType: 1,
      time:
          '2025-01-01 00:${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}',
      name: i == 10 || i == 25
          ? 'Jinhsi'
          : (i % 9 == 0 ? 'Danjin' : 'Training Sword'),
      resourceType: (i == 10 || i == 25 || i % 9 == 0) ? 'Resonator' : 'Weapon',
      rarity: i == 10 || i == 25 ? 5 : (i % 9 == 0 ? 4 : 3),
      count: 1,
      recordIndex: i,
      resourceId: i == 10 || i == 25 ? 1105 : (i % 9 == 0 ? 1402 : 21010011),
    ),
];

const jinhsi = ItemInfo(
  kind: ItemKind.resonator,
  name: 'Jinhsi',
  rarity: 5,
  elementName: 'Spectro',
  typeName: 'Broadblade',
  description: 'Magistrate of Jinzhou.',
  skills: [ItemSkill('Normal Attack', 'Slash')],
  stats: [ItemStat('HP', '1000')],
);

Future<void> openConvene(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  late AppDatabase database;
  await pumpApp(
    tester,
    size: const Size(412, 915),
    onDatabase: (db) => database = db,
    extraOverrides: [
      recordsProvider(
        '100',
        PoolType.featuredResonator,
      ).overrideWith((ref) => Stream.value(records())),
      ...overrides,
    ],
  );
  // These tests exercise one pull type's history, not the overview.
  ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
      .read(selectedPoolProvider.notifier)
      .select(PoolType.featuredResonator);
  await tester.runAsync(
    () => database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(uid: '100', serverId: 's')),
  );
  // Let drift's stream deliver the account (real I/O), then rebuild.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 300)),
  );
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await tester.ensureVisible(find.byIcon(Icons.search, skipOffstage: false));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Invokes the row's tap handler directly: hit-testing inside the nested
/// sliver group is unreliable in widget tests.
void tapHistoryRow(WidgetTester tester, String name) {
  final row = find.ancestor(
    of: find.text(name).last,
    matching: find.byType(InkWell),
  );
  tester.widget<InkWell>(row.first).onTap!();
}

Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  // Real glyph widths: the default test font is about twice as wide.
  setUpAll(loadInterFont);

  testWidgets('search narrows the history by name', (tester) async {
    await openConvene(tester);
    expect(find.text('36 results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jin');
    await tester.pump();
    // 'Danjin' (4) + 'Jinhsi' (2) contain "jin".
    expect(find.text('6 results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'dan');
    await tester.pump();
    expect(find.text('4 results'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('0 results'), findsOneWidget);
    expect(find.text('No records match this filter.'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a multi-word search matches the full name', (tester) async {
    await openConvene(tester);
    await tester.enterText(find.byType(TextField), 'training sword');
    await tester.pump();
    expect(find.text('30 results'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('pager: range, next page, rows per page', (tester) async {
    await openConvene(tester);
    await tester.ensureVisible(
      find.byTooltip('Rows per page', skipOffstage: false),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1–30 of 36'), findsOneWidget);

    await tester.tap(find.byTooltip('Next page'));
    await settle(tester);
    expect(find.text('31–36 of 36'), findsOneWidget);

    await tester.ensureVisible(
      find.byTooltip('Rows per page', skipOffstage: false),
    );
    await tester.tap(find.byTooltip('Rows per page'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(PopupMenuItem<int>, '50'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    // One page now; the range resets to the start.
    expect(find.text('1–36 of 36', skipOffstage: false), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('filter dialog: pick rarity, apply, chips, clear all', (
    tester,
  ) async {
    await openConvene(tester);
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);

    expect(find.text('Filter history'), findsOneWidget);
    expect(find.text('5★ · 2'), findsWidgets);
    expect(find.text('4★ · 4'), findsOneWidget);
    expect(find.text('3★ · 30'), findsOneWidget);
    expect(find.text('Weapon · 30'), findsOneWidget);
    expect(find.text('Resonator · 6'), findsOneWidget);
    expect(find.text('Newest first'), findsOneWidget);
    expect(find.text('Oldest first'), findsOneWidget);

    // Cancel changes nothing.
    await tester.tap(find.text('5★ · 2').last);
    await tester.pump();
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('36 results'), findsOneWidget);

    // Apply: 5★ only.
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);
    await tester.tap(find.text('5★ · 2').last);
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await settle(tester);
    expect(find.text('2 results'), findsOneWidget);
    expect(find.byType(InputChip), findsOneWidget);
    expect(find.text('1'), findsWidgets); // badge with the active count

    await tester.tap(find.text('Clear all'));
    await settle(tester);
    expect(find.text('36 results'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('type + oldest-first filters and removable chips', (
    tester,
  ) async {
    await openConvene(tester);
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);
    await tester.tap(find.text('Weapon · 30'));
    await tester.tap(find.text('Oldest first'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await settle(tester);

    expect(find.text('30 results'), findsOneWidget);
    expect(find.byType(InputChip), findsNWidgets(2)); // type + sort

    // Removing the type chip leaves the sort chip.
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(InputChip, 'Weapon'),
        matching: find.byIcon(Icons.clear),
      ),
    );
    await settle(tester);
    expect(find.text('36 results'), findsOneWidget);
    expect(find.byType(InputChip), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Reset in the dialog clears its selection', (tester) async {
    await openConvene(tester);
    await tester.tap(find.byTooltip('Filter'));
    await settle(tester);
    await tester.tap(find.text('4★ · 4'));
    await tester.tap(find.text('Reset'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await settle(tester);
    expect(find.text('36 results'), findsOneWidget);
    expect(find.byType(InputChip), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('tapping a history row opens that item\'s info', (tester) async {
    await openConvene(
      tester,
      overrides: [
        itemInfoProvider(
          1105,
          'Resonator',
          'en',
        ).overrideWith((ref) async => jinhsi),
      ],
    );
    await tester.enterText(find.byType(TextField), 'jinhsi');
    await tester.pump();
    tapHistoryRow(tester, 'Jinhsi'); // the history row, not a bubble
    await settle(tester);

    expect(find.text('Item info'), findsOneWidget);
    expect(find.text('Element: Spectro'), findsOneWidget);
    expect(find.text('Weapon type: Broadblade'), findsOneWidget);
    expect(find.text('Magistrate of Jinzhou.'), findsOneWidget);
    expect(find.text('Slash'), findsOneWidget);
    expect(find.text('HP'), findsOneWidget);
    expect(find.text('Info from encore.moe'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('item info shows an error with retry when the fetch fails', (
    tester,
  ) async {
    await openConvene(
      tester,
      overrides: [
        itemInfoProvider(
          1105,
          'Resonator',
          'en',
        ).overrideWith((ref) async => throw Exception('offline')),
      ],
    );
    await tester.enterText(find.byType(TextField), 'jinhsi');
    await tester.pump();
    tapHistoryRow(tester, 'Jinhsi');
    await settle(tester);

    expect(
      find.text(
        "Couldn't load item info. Check your connection and try again.",
      ),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    await disposeApp(tester);
  });
}
