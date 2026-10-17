import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/settings/settings_providers.dart';
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

  test('slang is configured with lazy: false', () {
    expect(
      File('slang.yaml').readAsStringSync(),
      contains('lazy: false'),
      reason: 'slang.yaml must disable deferred locales',
    );
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

  test('both Chinese scripts are separate locales picked by language tag', () {
    LocaleSettings.setLocaleRawSync('zh-Hans');
    expect(LocaleSettings.currentLocale, AppLocale.zhHans);
    LocaleSettings.setLocaleRawSync('zh-Hant');
    expect(LocaleSettings.currentLocale, AppLocale.zhHant);
    expect(AppLocale.zhHans.languageTag, 'zh-Hans');
    expect(AppLocale.zhHant.languageTag, 'zh-Hant');
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  test('every language file has exactly the keys of English', () {
    Set<String> keys(Object? node, [String prefix = '']) => {
      if (node is Map)
        for (final e in node.entries)
          if ((e.key as String).endsWith('(plural)'))
            '$prefix${(e.key as String).replaceAll('(plural)', '')}.'
          else
            ...keys(
              e.value,
              '$prefix${(e.key as String).replaceAll(RegExp(r'\(.*\)'), '')}.',
            )
      else
        prefix,
    };

    Set<String> load(String name) => keys(
      jsonDecode(
        File('lib/src/shared/i18n/$name.i18n.json').readAsStringSync(),
      ),
    );

    final english = load('en');
    for (final name in ['id', 'ja', 'zh-Hans', 'zh-Hant']) {
      final other = load(name);
      expect(
        other.difference(english),
        isEmpty,
        reason: '$name has extra keys',
      );
      expect(english.difference(other), isEmpty, reason: '$name misses keys');
    }
  });

  test('plural rules exist for Indonesian, Japanese and Chinese', () {
    registerPluralResolvers();
    // Indonesian keeps a singular for 1; Japanese and Chinese have one form.
    final id = AppLocale.id.translations;
    expect(id.stats.pullsUsed(n: 1), isNot(id.stats.pullsUsed(n: 2)));
    for (final locale in [AppLocale.ja, AppLocale.zhHans, AppLocale.zhHant]) {
      final t = locale.translations;
      expect(
        t.stats.pullsUsed(n: 1).replaceAll('1', '#'),
        t.stats.pullsUsed(n: 2).replaceAll('2', '#'),
        reason: locale.languageTag,
      );
    }
  });
}
