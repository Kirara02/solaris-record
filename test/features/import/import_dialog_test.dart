import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/features/import/presentation/import_dialog.dart';
import 'package:solaris_record_app/src/shared/routing/app_routes.dart';

import '../../support/app_harness.dart';

void main() {
  const phone = Size(412, 915);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('import is no longer a route or tab', (tester) async {
    final router = await pumpApp(tester, size: phone);
    router.go('/import');
    await settle(tester);
    // Unknown route: no import screen, no dialog.
    expect(find.byType(ImportDialog), findsNothing);
    expect(find.text('Import convene records'), findsNothing);
    expect(AppRoutes.settings, isNot('/import'));
    await disposeApp(tester);
  });

  testWidgets('empty Convene screen opens the import dialog', (tester) async {
    await pumpApp(tester, size: phone);
    await tester.tap(find.text('Import records'));
    await settle(tester);
    expect(find.byType(ImportDialog), findsOneWidget);
    expect(find.text('Import convene records'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Settings has an Import records entry that opens the dialog', (
    tester,
  ) async {
    final router = await pumpApp(tester, size: phone);
    router.go(AppRoutes.settings);
    await settle(tester);
    await tester.tap(find.text('Import records'));
    await settle(tester);
    expect(find.byType(ImportDialog), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('Convene header has an import button once an account exists', (
    tester,
  ) async {
    late AppDatabase database;
    await pumpApp(tester, size: phone, onDatabase: (db) => database = db);
    await tester.runAsync(
      () => database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(uid: '100', serverId: 's')),
    );
    await tester.pump(const Duration(seconds: 1));

    final button = find.byTooltip('Import records');
    expect(button, findsOneWidget);
    await tester.tap(button);
    await settle(tester);
    expect(find.byType(ImportDialog), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('dialog validates the URL and can be closed', (tester) async {
    await pumpApp(tester, size: phone);
    await tester.tap(find.text('Import records'));
    await settle(tester);

    // Update is disabled until something is typed.
    M3EButton updateButton() => tester.widget<M3EButton>(
      find.widgetWithText(M3EButton, 'Update records'),
    );
    expect(updateButton().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();
    expect(updateButton().onPressed, isNotNull);

    // The guides above push the button below the fold of a phone.
    await tester.ensureVisible(find.text('Update records'));
    await tester.tap(find.text('Update records'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text("That doesn't look like a convene record URL."),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(find.byType(ImportDialog), findsNothing);
    await disposeApp(tester);
  });

  group('guides', () {
    Future<void> openDialog(WidgetTester tester) async {
      await pumpApp(tester, size: phone);
      await tester.tap(find.text('Import records'));
      await settle(tester);
    }

    Future<void> choose(WidgetTester tester, String label) async {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pump();
    }

    testWidgets('each platform shows its own way to get the link', (
      tester,
    ) async {
      await openDialog(tester);

      await choose(tester, 'Windows');
      expect(find.textContaining('import.ps1 | iex'), findsOneWidget);

      await choose(tester, 'Linux');
      expect(find.textContaining('import.sh" | bash'), findsOneWidget);

      await choose(tester, 'macOS');
      expect(
        find.textContaining('com.kurogame.wutheringwaves.global'),
        findsWidgets,
      );
      await disposeApp(tester);
    });

    testWidgets('the pinned scripts come from the tracker commit', (
      tester,
    ) async {
      await openDialog(tester);
      await choose(tester, 'Windows');
      expect(
        find.textContaining('747a48b1b994baa9c372a4fb933ea7588428bd4b'),
        findsOneWidget,
      );
      await disposeApp(tester);
    });

    testWidgets('Android offers several methods and ends with a paste step', (
      tester,
    ) async {
      await openDialog(tester);
      await choose(tester, 'Android');
      expect(find.text('Airplane mode'), findsOneWidget);
      expect(find.text('Client.log'), findsOneWidget);
      expect(find.text('Ascent'), findsOneWidget);
      expect(
        find.text('Paste it below and tap Update records.'),
        findsOneWidget,
      );

      // A Client.log method ends with a file import instead of a paste.
      await choose(tester, 'Client.log');
      expect(
        find.text(
          'Import the file with the Import from JSON file button below.',
        ),
        findsOneWidget,
      );
      expect(find.text('Paste it below and tap Update records.'), findsNothing);
      await disposeApp(tester);
    });

    testWidgets('the file guide names the tracker export', (tester) async {
      await openDialog(tester);
      await choose(tester, 'WuWa Tracker');
      expect(find.textContaining('Export Pull History'), findsOneWidget);
      await choose(tester, 'Solaris Record');
      expect(find.textContaining('Export backup'), findsOneWidget);
      await disposeApp(tester);
    });
  });

  group('prefilled link', () {
    const link =
        'https://aki-gm-resources-oversea.aki-game.net/aki/gacha/index.html'
        '#/record?svr_id=s&player_id=p&record_id=r&lang=en';

    void mockClipboard(WidgetTester tester, String? text) {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async => call.method == 'Clipboard.getData'
            ? (text == null ? null : <String, dynamic>{'text': text})
            : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
    }

    testWidgets('a convene link on the clipboard fills the field', (
      tester,
    ) async {
      mockClipboard(tester, 'copied: $link');
      await pumpApp(tester, size: phone);
      await tester.tap(find.text('Import records'));
      await settle(tester);
      expect(find.text(link), findsOneWidget);
      expect(find.text('Filled from your clipboard.'), findsOneWidget);
      await disposeApp(tester);
    });

    testWidgets('other clipboard text leaves the field empty', (tester) async {
      mockClipboard(tester, 'just some words');
      await pumpApp(tester, size: phone);
      await tester.tap(find.text('Import records'));
      await settle(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Filled from your clipboard.'), findsNothing);
      await disposeApp(tester);
    });

    testWidgets('a shared link opens the dialog filled in', (tester) async {
      mockClipboard(tester, null);
      await pumpApp(tester, size: phone);
      final context = tester.element(find.byType(Scaffold).first);
      unawaited(showImportDialog(context, initialUrl: link));
      await settle(tester);
      expect(find.text(link), findsOneWidget);
      expect(find.text('Received from another app.'), findsOneWidget);
      await disposeApp(tester);
    });
  });
}
