import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/app.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/data/providers.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

/// Pumps the whole app with an in-memory database and mock preferences.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  required Size size,
  void Function(AppDatabase db)? onDatabase,
  List<Override> extraOverrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  onDatabase?.call(db);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        ...extraOverrides,
      ],
      child: TranslationProvider(child: const SolarisApp()),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  return GoRouter.of(tester.element(find.byType(Scaffold).first));
}

/// Unmounts the app and lets drift's zero-duration stream-cancel timers fire,
/// which the test binding otherwise reports as pending.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

/// Loads the real Inter font. flutter_test's default Ahem font has glyphs about
/// twice as wide as real text, which makes width assertions meaningless.
Future<void> loadInterFont() async {
  final inter = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    inter.addFont(
      Future.value(
        ByteData.view(
          File('assets/fonts/Inter-$weight.ttf').readAsBytesSync().buffer,
        ),
      ),
    );
  }
  await inter.load();
}
