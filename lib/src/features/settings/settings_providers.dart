import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/preferences.dart';
import '../../shared/i18n/gen/strings.g.dart';
import '../../shared/logging/app_log.dart';
import '../info/domain/encore_links.dart';
import 'domain/theme_settings.dart';

part 'settings_providers.g.dart';

const _modeKey = 'theme_mode';
const _dynamicKey = 'use_dynamic_color';
const _seedKey = 'seed_color';
const _amoledKey = 'use_amoled';
const languagePrefKey = 'language';
const _dataLanguageKey = 'data_language';

@Riverpod(keepAlive: true)
class ThemeSettingsController extends _$ThemeSettingsController {
  @override
  ThemeSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final seed = prefs.getInt(_seedKey);
    return ThemeSettings(
      mode:
          ThemeMode.values.asNameMap()[prefs.getString(_modeKey)] ??
          ThemeMode.system,
      useDynamicColor: prefs.getBool(_dynamicKey) ?? true,
      seedColor: seed == null ? defaultSeedColor : Color(seed),
      useAmoled: prefs.getBool(_amoledKey) ?? false,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await ref.read(sharedPreferencesProvider).setString(_modeKey, mode.name);
  }

  Future<void> setUseDynamicColor(bool value) async {
    state = state.copyWith(useDynamicColor: value);
    await ref.read(sharedPreferencesProvider).setBool(_dynamicKey, value);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    await ref
        .read(sharedPreferencesProvider)
        .setInt(_seedKey, color.toARGB32());
  }

  Future<void> setUseAmoled(bool value) async {
    state = state.copyWith(useAmoled: value);
    await ref.read(sharedPreferencesProvider).setBool(_amoledKey, value);
  }
}

/// Language override: `null` follows the device, otherwise a slang locale code
/// (`en`, `id`).
@Riverpod(keepAlive: true)
class AppLanguage extends _$AppLanguage {
  @override
  String? build() {
    final code = ref
        .watch(sharedPreferencesProvider)
        .getString(languagePrefKey);
    return AppLocale.values.any((l) => l.languageCode == code) ? code : null;
  }

  Future<void> set(String? code) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null) {
      await prefs.remove(languagePrefKey);
      await LocaleSettings.useDeviceLocale();
    } else {
      await prefs.setString(languagePrefKey, code);
      await LocaleSettings.setLocaleRaw(code);
    }
    state = code;
  }
}

/// Applies the saved language before the first frame.
void applySavedLanguage(String? code) {
  if (code == null) {
    LocaleSettings.useDeviceLocaleSync();
  } else {
    LocaleSettings.setLocaleRawSync(code);
  }
}

/// Language names are shown in their own language so they stay recognisable
/// whatever the current UI language is.
const languageNames = {'en': 'English', 'id': 'Bahasa Indonesia'};

String languageLabel(String? code, Translations t) =>
    code == null ? t.language.system : languageNames[code] ?? code;

/// Language of item names in pull records and charts, independent of the app
/// language. `null` shows the English names as stored; otherwise an encore.moe
/// language code. Stored records are never changed by this.
@Riverpod(keepAlive: true)
class DataLanguage extends _$DataLanguage {
  @override
  String? build() {
    final code = ref
        .watch(sharedPreferencesProvider)
        .getString(_dataLanguageKey);
    return code != 'en' && encoreLanguages.contains(code) ? code : null;
  }

  Future<void> set(String? code) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null) {
      await prefs.remove(_dataLanguageKey);
    } else {
      await prefs.setString(_dataLanguageKey, code);
    }
    state = code;
  }
}

/// Selectable data languages, in their own language like [languageNames].
const dataLanguageNames = {
  'zh-Hans': '简体中文',
  'zh-Hant': '繁體中文',
  'ja': '日本語',
  'ko': '한국어',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
  'id': 'Bahasa Indonesia',
  'pt': 'Português',
  'ru': 'Русский',
  'th': 'ไทย',
  'vi': 'Tiếng Việt',
};

String dataLanguageLabel(String? code, Translations t) => code == null
    ? t.appearance.dataLanguageDefault
    : dataLanguageNames[code] ?? code;

/// Size of the stored debug logs in bytes. Invalidate after clearing them.
@riverpod
Future<int> logSize(Ref ref) => AppLog.size();
