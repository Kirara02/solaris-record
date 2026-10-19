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
const _styleKey = 'theme_style';
const _mornyeAccentKey = 'mornye_accent';
const _mornyeClarityKey = 'mornye_glass_clarity';
const _mornyeOutlinesKey = 'mornye_glass_outlines';
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
      style:
          AppThemeStyle.values.asNameMap()[prefs.getString(_styleKey)] ??
          AppThemeStyle.material,
      mornyeAccent:
          MornyeAccent.values.asNameMap()[prefs.getString(_mornyeAccentKey)] ??
          MornyeAccent.red,
      mornyeGlassClarity:
          prefs.getDouble(_mornyeClarityKey) ?? defaultMornyeGlassClarity,
      mornyeGlassOutlines: prefs.getBool(_mornyeOutlinesKey) ?? true,
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

  Future<void> setStyle(AppThemeStyle style) async {
    state = state.copyWith(style: style);
    await ref.read(sharedPreferencesProvider).setString(_styleKey, style.name);
  }

  Future<void> setMornyeAccent(MornyeAccent accent) async {
    state = state.copyWith(mornyeAccent: accent);
    await ref
        .read(sharedPreferencesProvider)
        .setString(_mornyeAccentKey, accent.name);
  }

  /// [persist] false while a slider is being dragged, so only the final value
  /// is written.
  Future<void> setMornyeGlassClarity(
    double value, {
    bool persist = true,
  }) async {
    state = state.copyWith(mornyeGlassClarity: value);
    if (persist) {
      await ref
          .read(sharedPreferencesProvider)
          .setDouble(_mornyeClarityKey, state.mornyeGlassClarity);
    }
  }

  Future<void> setMornyeGlassOutlines(bool value) async {
    state = state.copyWith(mornyeGlassOutlines: value);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(_mornyeOutlinesKey, value);
  }

  Future<void> setUseAmoled(bool value) async {
    state = state.copyWith(useAmoled: value);
    await ref.read(sharedPreferencesProvider).setBool(_amoledKey, value);
  }
}

/// Language override: `null` follows the device, otherwise a slang locale
/// language tag (`en`, `id`, `ja`, `zh-Hans`, `zh-Hant`).
@Riverpod(keepAlive: true)
class AppLanguage extends _$AppLanguage {
  @override
  String? build() {
    final code = ref
        .watch(sharedPreferencesProvider)
        .getString(languagePrefKey);
    return AppLocale.values.any((l) => l.languageTag == code) ? code : null;
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

/// Plural rules for the languages slang has none built in for (it logs
/// "Resolver for ... not specified" and guesses otherwise). Indonesian keeps
/// a singular for 1; Japanese and Chinese have a single form.
void registerPluralResolvers() {
  String single(
    num n, {
    String? zero,
    String? one,
    String? two,
    String? few,
    String? many,
    String? other,
  }) => other ?? '';
  for (final language in const ['ja', 'zh']) {
    LocaleSettings.setPluralResolverSync(
      language: language,
      cardinalResolver: single,
      ordinalResolver: single,
    );
  }
  String indonesian(
    num n, {
    String? zero,
    String? one,
    String? two,
    String? few,
    String? many,
    String? other,
  }) => n == 1 ? (one ?? other ?? '') : (other ?? '');
  LocaleSettings.setPluralResolverSync(
    language: 'id',
    cardinalResolver: indonesian,
    ordinalResolver: single,
  );
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
const languageNames = {
  'en': 'English',
  'id': 'Bahasa Indonesia',
  'ja': '日本語',
  'zh-Hans': '简体中文',
  'zh-Hant': '繁體中文',
};

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

const detailedLoggingPrefKey = 'detailed_logging';

/// Whether fine-grained logging is on, for bug reports. Applied to the logger
/// at startup (see `main`) and whenever it changes.
@Riverpod(keepAlive: true)
class DetailedLogging extends _$DetailedLogging {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(detailedLoggingPrefKey) ??
      false;

  Future<void> set(bool value) async {
    AppLog.setDetailed(value);
    await ref
        .read(sharedPreferencesProvider)
        .setBool(detailedLoggingPrefKey, value);
    state = value;
  }
}

const _navBlurKey = 'nav_blur';

/// Whether the phone's bottom bar is translucent with a blur behind it. On by
/// default; the blur re-filters what scrolls underneath on every frame, so
/// slower devices can turn it off for an opaque bar.
@Riverpod(keepAlive: true)
class NavBarBlur extends _$NavBarBlur {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(_navBlurKey) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_navBlurKey, value);
  }
}
