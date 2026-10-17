import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/features/announcements/announcements_providers.dart';
import 'package:solaris_record_app/src/features/announcements/data/announcement_service.dart';
import 'package:solaris_record_app/src/features/announcements/domain/announcement.dart';
import 'package:solaris_record_app/src/features/announcements/presentation/announcement_dialog.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

class _FakeService extends AnnouncementService {
  _FakeService(this.items) : super(Dio());

  final List<Announcement> items;

  @override
  Future<List<Announcement>> fetch() async => items;
}

Announcement _notice(String id, {String? max}) => Announcement(
  id: id,
  title: {'en': 'Title $id'},
  body: {'en': 'Body $id'},
  maxVersion: max,
);

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Future<SharedPreferences> pumpButton(
    WidgetTester tester,
    List<Announcement> items, {
    Map<String, Object> prefsValues = const {},
  }) async {
    PackageInfo.setMockInitialValues(
      appName: 'Solaris Record',
      packageName: 'id.kirara.solarisRecordApp',
      version: '1.2.0',
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues(prefsValues);
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          announcementServiceProvider.overrideWithValue(_FakeService(items)),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: TextButton(
                  onPressed: () => showAnnouncementIfAny(context, ref),
                  child: const Text('run'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return prefs;
  }

  Future<void> run(WidgetTester tester) async {
    await tester.tap(find.text('run'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('shows the first applicable notice and remembers it', (
    tester,
  ) async {
    final prefs = await pumpButton(tester, [
      _notice('old', max: '1.1.0'),
      _notice('a'),
      _notice('b'),
    ]);
    await run(tester);
    expect(find.text('Title a'), findsOneWidget);
    expect(find.text('Body a'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(prefs.getStringList('dismissed_announcements'), ['a']);

    // The next launch moves on to the following notice, never repeating one.
    await run(tester);
    expect(find.text('Title b'), findsOneWidget);
    expect(find.text('Title a'), findsNothing);
  });

  testWidgets('a dismissed notice does not show again', (tester) async {
    await pumpButton(
      tester,
      [_notice('a')],
      prefsValues: {
        'dismissed_announcements': ['a'],
      },
    );
    await run(tester);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('nothing shows when there are no announcements', (tester) async {
    await pumpButton(tester, const []);
    await run(tester);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
