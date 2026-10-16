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
}
