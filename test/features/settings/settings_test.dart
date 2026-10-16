import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/features/settings/domain/theme_settings.dart';
import 'package:solaris_record_app/src/features/settings/settings_providers.dart';
import 'package:solaris_record_app/src/shared/i18n/gen/strings.g.dart';

Future<ProviderContainer> container(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme defaults', () async {
    final s = (await container({})).read(themeSettingsControllerProvider);
    expect(s.mode, ThemeMode.system);
    expect(s.useDynamicColor, isTrue);
    expect(s.seedColor, defaultSeedColor);
    expect(s.useAmoled, isFalse);
  });

  test('theme settings persist and reload', () async {
    final c = await container({});
    final n = c.read(themeSettingsControllerProvider.notifier);
    await n.setMode(ThemeMode.dark);
    await n.setUseDynamicColor(false);
    await n.setSeedColor(const Color(0xFF006E1C));
    await n.setUseAmoled(true);

    final prefs = c.read(sharedPreferencesProvider);
    final reloaded = await container({
      for (final k in prefs.getKeys()) k: prefs.get(k)!,
    });
    final s = reloaded.read(themeSettingsControllerProvider);
    expect(s.mode, ThemeMode.dark);
    expect(s.useDynamicColor, isFalse);
    expect(s.seedColor, const Color(0xFF006E1C));
    expect(s.useAmoled, isTrue);
  });

  test('unknown saved values fall back to defaults', () async {
    final c = await container({'theme_mode': 'bogus', languagePrefKey: 'xx'});
    expect(c.read(themeSettingsControllerProvider).mode, ThemeMode.system);
    expect(c.read(appLanguageProvider), isNull);
  });

  test('language persists and switches the slang locale', () async {
    final c = await container({});
    final n = c.read(appLanguageProvider.notifier);
    await n.set('id');
    expect(c.read(appLanguageProvider), 'id');
    expect(LocaleSettings.currentLocale, AppLocale.id);
    expect(c.read(sharedPreferencesProvider).getString(languagePrefKey), 'id');

    await n.set('en');
    expect(LocaleSettings.currentLocale, AppLocale.en);
    await n.set(null);
    expect(
      c.read(sharedPreferencesProvider).getString(languagePrefKey),
      isNull,
    );
  });
}
