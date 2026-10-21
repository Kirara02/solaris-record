import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/data/providers.dart';
import 'package:solaris_record_app/src/features/guide/domain/guide_entry.dart';
import 'package:solaris_record_app/src/features/guide/presentation/guide_detail_screen.dart';
import 'package:solaris_record_app/src/features/info/data/url_opener.dart';
import 'package:solaris_record_app/src/features/info/domain/encore_links.dart';
import 'package:solaris_record_app/src/features/info/domain/item_info.dart';
import 'package:solaris_record_app/src/features/info/domain/item_kind.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

class _RecordingOpener implements UrlOpener {
  _RecordingOpener({this.succeeds = true});

  final bool succeeds;
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return succeeds;
  }
}

const jinhsi = ItemInfo(
  kind: ItemKind.resonator,
  name: 'Jinhsi',
  rarity: 5,
  elementName: 'Spectro',
);

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  group('encore links', () {
    test('resonators and weapons use their own path', () {
      expect(
        encoreItemUrl(ItemKind.resonator, 1105, 'en'),
        'https://encore.moe/character/1105?lang=en',
      );
      expect(
        encoreItemUrl(ItemKind.weapon, 21010011, 'id'),
        'https://encore.moe/weapon/21010011?lang=id',
      );
    });

    test('unsupported languages fall back to English', () {
      expect(
        encoreItemUrl(ItemKind.resonator, 1105, 'xx'),
        'https://encore.moe/character/1105?lang=en',
      );
      expect(
        encoreItemUrl(ItemKind.resonator, 1105, 'zh-Hans'),
        'https://encore.moe/character/1105?lang=zh-Hans',
      );
    });

    test('records that are neither resonator nor weapon have no link', () {
      expect(encoreItemUrlFor(123, '', 'en'), isNull);
      expect(encoreItemUrlFor(0, 'Weapon', 'en'), isNull);
      expect(
        encoreItemUrlFor(1105, 'Resonator', 'id'),
        'https://encore.moe/character/1105?lang=id',
      );
      // The type string wins; otherwise the id length decides.
      expect(
        encoreItemUrlFor(21010011, '', 'en'),
        'https://encore.moe/weapon/21010011?lang=en',
      );
    });
  });

  Future<_RecordingOpener> pumpDetail(
    WidgetTester tester, {
    bool openSucceeds = true,
    int resourceId = 1105,
    GuideKind kind = GuideKind.resonator,
    Future<ItemInfo?> Function()? info,
  }) async {
    final opener = _RecordingOpener(succeeds: openSucceeds);
    // The screen reads the data language setting.
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          urlOpenerProvider.overrideWithValue(opener),
          itemInfoProvider(
            resourceId,
            kind.name,
            'en',
          ).overrideWith((ref) => (info ?? () async => jinhsi)()),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            home: GuideDetailScreen(kind: kind, id: resourceId),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return opener;
  }

  Future<void> tapViewOnEncore(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(GuideDetailScreen.viewOnEncoreKey));
    await tester.tap(find.byKey(GuideDetailScreen.viewOnEncoreKey));
    await tester.pump();
  }

  testWidgets('the detail offers "View on encore.moe" and opens the page', (
    tester,
  ) async {
    final opener = await pumpDetail(tester);
    expect(find.text('View on encore.moe'), findsOneWidget);

    await tapViewOnEncore(tester);
    expect(opener.opened.map((u) => u.toString()), [
      'https://encore.moe/character/1105?lang=en',
    ]);
  });

  testWidgets('weapons link to /weapon/', (tester) async {
    final opener = await pumpDetail(
      tester,
      resourceId: 21010011,
      kind: GuideKind.weapon,
    );
    await tapViewOnEncore(tester);
    expect(
      opener.opened.single.toString(),
      'https://encore.moe/weapon/21010011?lang=en',
    );
  });

  testWidgets('the link is still offered when the info could not be loaded', (
    tester,
  ) async {
    final opener = await pumpDetail(
      tester,
      info: () async => throw Exception('offline'),
    );
    expect(
      find.text(
        "Couldn't load item info. Check your connection and try again.",
      ),
      findsOneWidget,
    );
    await tapViewOnEncore(tester);
    expect(opener.opened, hasLength(1));
  });

  testWidgets('a failed launch says so', (tester) async {
    await pumpDetail(tester, openSucceeds: false);
    await tapViewOnEncore(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Couldn't open the link."), findsOneWidget);
  });
}
