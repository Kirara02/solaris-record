import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/app.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/data/providers.dart';
import 'package:solaris_record_app/src/features/import/domain/convene_api.dart';
import 'package:solaris_record_app/src/features/settings/data/storage_usage.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';
import 'package:solaris_record_app/src/shared/widgets/confirm_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showConfirmDialog resolves true only on confirm', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showConfirmDialog(
              context,
              title: 'T',
              body: 'B',
              confirmLabel: 'Yes',
              cancelLabel: 'No',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    for (final (tap, expected) in [('Yes', true), ('No', false)]) {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(tap));
      await tester.pumpAndSettle();
      expect(result, expected);
    }

    // Tapping the barrier dismisses and counts as cancel.
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(result, false);
  });

  testWidgets('data screen asks before clearing cache or deleting data', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        storageUsageProvider.overrideWith(
          (ref) async => const StorageUsage(
            databaseBytes: 2048,
            imageCacheBytes: 5 * 1024 * 1024,
            accounts: 1,
            records: 1,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final repo = container.read(conveneRepositoryProvider);
    // drift uses real I/O, which never completes inside testWidgets' fake
    // async zone, so every database call goes through runAsync.
    Future<T> real<T>(Future<T> Function() f) async =>
        (await tester.runAsync(f)) as T;
    await real(() => repo.upsertAccount(uid: '100', serverId: 's'));
    await real(
      () => repo.mergeRecords('100', PoolType.featuredResonator, const [
        RemoteRecord(
          poolType: '',
          time: '2025-01-01 00:00:00',
          name: 'Sword',
          resourceType: 'Weapon',
          rarity: 3,
          count: 1,
        ),
      ]),
    );
    Future<int> records() => real(
      () async =>
          (await repo.watchRecords('100', PoolType.featuredResonator).first)
              .length,
    );
    Future<int> accounts() =>
        real(() async => (await repo.watchAccounts().first).length);

    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(child: const SolarisApp()),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go('/settings/data');
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Clear image cache: shows a dialog mentioning the size; Cancel does nothing.
    await tester.tap(find.text('Clear image cache'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Clear image cache?'), findsOneWidget);
    expect(find.textContaining('5 MB of downloaded'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Image cache cleared'), findsNothing);

    // Delete all data: Cancel keeps everything.
    await tester.tap(find.text('Delete all data'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Delete all data?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(await records(), 1);
    expect(await accounts(), 1);

    // Confirming removes it.
    await tester.tap(find.text('Delete all data'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Delete').last);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(await records(), 0);
    expect(await accounts(), 0);
    expect(find.text('All data deleted'), findsOneWidget);
  });
}
