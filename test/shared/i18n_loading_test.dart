import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

/// Regression: with slang's default `lazy: true`, non-base locales are
/// deferred libraries. Release builds then crashed at startup on a device set
/// to Indonesian ("Deferred library l_id was not loaded") because
/// `useDeviceLocaleSync()` builds the locale synchronously. Debug builds and
/// the English-locale emulator never showed it, so guard the config itself.
void main() {
  test('generated translations are imported eagerly, not deferred', () {
    final generated = File('lib/src/shared/i18n/gen/strings.g.dart')
        .readAsStringSync();
    expect(generated, isNot(contains('deferred as')));
    expect(generated, isNot(contains('loadLibrary')));
  });

  test('slang is configured with lazy: false in both config files', () {
    for (final file in ['slang.yaml', 'build.yaml']) {
      expect(
        File(file).readAsStringSync(),
        contains('lazy: false'),
        reason: '$file must disable deferred locales',
      );
    }
  });

  test('every locale can be built synchronously', () {
    for (final locale in AppLocale.values) {
      expect(locale.buildSync(), isNotNull, reason: locale.languageCode);
    }
  });

  test('switching to Indonesian synchronously works', () {
    LocaleSettings.setLocaleRawSync('id');
    expect(LocaleSettings.currentLocale, AppLocale.id);
    expect(AppLocale.id.buildSync().nav.settings, 'Pengaturan');
    LocaleSettings.setLocaleSync(AppLocale.en);
  });
}
