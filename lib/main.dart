import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/data/preferences.dart';
import 'src/features/settings/settings_providers.dart';
import 'src/shared/i18n/gen/strings.g.dart';
import 'src/shared/logging/app_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLog.init();
  _registerFontLicense();
  _logUncaughtErrors();
  final prefs = await SharedPreferences.getInstance();
  registerPluralResolvers();
  applySavedLanguage(prefs.getString(languagePrefKey));
  AppLog.setDetailed(prefs.getBool(detailedLoggingPrefKey) ?? false);
  final version = (await PackageInfo.fromPlatform()).version;
  Logger('app').info(
    'Started version=$version platform=${defaultTargetPlatform.name} '
    'locale=${LocaleSettings.currentLocale.languageCode}',
  );
  // Compile the glass shaders up front so the Mornye tab bar is glass on its
  // first frame. Glass falls back to a frosted look when they can't load.
  try {
    await LiquidGlassShaders.ensureLoaded();
  } catch (e) {
    Logger('app').warning('Liquid glass shaders unavailable: $e');
  }
  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SolarisApp(),
      ),
    ),
  );
}

/// Sends framework and uncaught errors to the debug log, then lets the
/// default handling carry on.
void _logUncaughtErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    Logger('flutter')
        .severe(details.exceptionAsString(), details.exception, details.stack);
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger('app').severe('Uncaught error', error, stack);
    return false;
  };
}

/// Adds the Inter font's license (SIL OFL) to the list shown on the licenses
/// page; Flutter only collects package licenses by itself.
void _registerFontLicense() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Inter',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
}
