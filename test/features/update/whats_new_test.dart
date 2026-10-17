import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/features/update/data/update_service.dart';
import 'package:solaris_record_app/src/features/update/domain/update_info.dart';
import 'package:solaris_record_app/src/features/update/presentation/whats_new.dart';
import 'package:solaris_record_app/src/features/update/update_providers.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

class _FakeUpdateService extends UpdateService {
  _FakeUpdateService({this.release, this.fails = false}) : super(Dio());

  final UpdateInfo? release;
  final bool fails;
  final asked = <String>[];

  @override
  Future<UpdateInfo?> fetchVersion(String version, String platform) async {
    asked.add(version);
    if (fails) throw const UpdateException('network');
    return release;
  }
}

const _notes = UpdateInfo(
  version: '1.2.0',
  notes: '## Added\n- A log viewer\n\n---\n\nDownloads table',
  pageUrl: 'https://github.com/x/y/releases/tag/v1.2.0',
);

void main() {
  setUpAll(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Future<SharedPreferences> pumpButton(
    WidgetTester tester, {
    required _FakeUpdateService service,
    String? lastSeen,
    String version = '1.2.0',
  }) async {
    PackageInfo.setMockInitialValues(
      appName: 'Solaris Record',
      packageName: 'id.kirara.solarisRecordApp',
      version: version,
      buildNumber: '1',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({'last_seen_version': ?lastSeen});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          updateServiceProvider.overrideWithValue(service),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) => Scaffold(
                body: TextButton(
                  onPressed: () => showWhatsNewIfNeeded(context, ref),
                  child: const Text('run'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('run'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return prefs;
  }

  testWidgets('a first launch only records the version', (tester) async {
    final service = _FakeUpdateService(release: _notes);
    final prefs = await pumpButton(tester, service: service);
    expect(find.byType(AlertDialog), findsNothing);
    expect(service.asked, isEmpty);
    expect(prefs.getString('last_seen_version'), '1.2.0');
  });

  testWidgets('after an update the notes of the new version show once', (
    tester,
  ) async {
    final service = _FakeUpdateService(release: _notes);
    final prefs = await pumpButton(tester, service: service, lastSeen: '1.1.0');
    expect(service.asked, ['1.2.0']);
    expect(find.text("What's new in 1.2.0"), findsOneWidget);
    expect(find.textContaining('A log viewer'), findsOneWidget);
    // The download footer after the first rule is not part of the notes.
    expect(find.textContaining('Downloads table'), findsNothing);
    expect(prefs.getString('last_seen_version'), '1.2.0');

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('nothing happens when the version is unchanged', (tester) async {
    final service = _FakeUpdateService(release: _notes);
    await pumpButton(tester, service: service, lastSeen: '1.2.0');
    expect(service.asked, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a failed lookup is retried at the next launch', (tester) async {
    final service = _FakeUpdateService(fails: true);
    final prefs = await pumpButton(tester, service: service, lastSeen: '1.1.0');
    expect(find.byType(AlertDialog), findsNothing);
    expect(prefs.getString('last_seen_version'), '1.1.0');
  });

  testWidgets('a version without a release is marked seen quietly', (
    tester,
  ) async {
    final service = _FakeUpdateService();
    final prefs = await pumpButton(tester, service: service, lastSeen: '1.1.0');
    expect(find.byType(AlertDialog), findsNothing);
    expect(prefs.getString('last_seen_version'), '1.2.0');
  });

  testWidgets('a downgrade just records the version', (tester) async {
    final service = _FakeUpdateService(release: _notes);
    final prefs = await pumpButton(tester, service: service, lastSeen: '1.3.0');
    expect(service.asked, isEmpty);
    expect(prefs.getString('last_seen_version'), '1.2.0');
  });
}
