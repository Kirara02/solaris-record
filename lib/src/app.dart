import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import 'features/settings/settings_providers.dart';
import 'features/shell/rail_metrics.dart';
import 'shared/i18n/gen/strings.g.dart';
import 'shared/routing/app_router.dart';
import 'shared/theme/app_theme.dart';

class SolarisApp extends ConsumerWidget {
  const SolarisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsControllerProvider);

    // M3EMaterialApp has no router constructor, so this mirrors what it does:
    // a MaterialApp whose builder installs M3ETheme, which resolves brightness
    // and the device's dynamic palette (seeded fallback otherwise).
    final data = M3EThemeData.light(seedColor: settings.seedColor).copyWith(
      fontFamily: 'Inter',
      // Rail items span the whole rail like the hand-drawn Settings item
      // (pill = rail width minus a 16px inset on each side, the same inset the
      // rail gives its trailing slot), instead of shrinking to their label.
      navigationRailTheme: M3ENavigationRailTheme.defaults.copyWith(
        indicatorFillsWidth: true,
        expandedItemInset: 16,
        // Modern sidebar look: slim rounded-rectangle indicators (not full
        // pills) with a tight vertical rhythm. Colours stay theme-derived so
        // dynamic color still applies.
        expandedIndicatorHeight: RailMetrics.itemHeight,
        expandedIndicatorRadius: RailMetrics.indicatorRadius,
        itemExpandedHeight: RailMetrics.itemHeight,
        shortItemHeight: RailMetrics.shortItemHeight,
        noLabelIndicatorSize: RailMetrics.collapsedIndicator,
        itemVerticalGap: 2,
        topSpace: 20,
      ),
    );

    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      onGenerateTitle: (context) => context.t.appName,
      debugShowCheckedModeBanner: false,
      theme: applyAppTheme(data.toThemeData()),
      darkTheme: applyAppTheme(data.deriveDarkTemplate().toThemeData()),
      themeMode: settings.mode,
      // M3ETheme reads the parent Theme once per rebuild. With the default
      // animated transition it can capture a half-interpolated (or stale)
      // theme, so switch instantly.
      themeAnimationDuration: Duration.zero,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => M3ETheme(
        data: data,
        autoTheming: settings.mode == ThemeMode.system,
        initialTheme: switch (settings.mode) {
          ThemeMode.light => Brightness.light,
          ThemeMode.dark => Brightness.dark,
          ThemeMode.system => null,
        },
        dynamicColoring: settings.useDynamicColor,
        child: _ResolvedThemeScope(
          amoled: settings.useAmoled,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Pins the page background to the resolved scheme and applies AMOLED.
///
/// Sits inside M3ETheme. The Scaffold background comes from
/// `ThemeData.scaffoldBackgroundColor`, which M3ETheme doesn't recompute from
/// the scheme it resolves (dynamic palette, brightness), so it could disagree
/// with the rest of the UI (e.g. a black page behind light content).
class _ResolvedThemeScope extends StatelessWidget {
  const _ResolvedThemeScope({required this.amoled, required this.child});

  final bool amoled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final black = amoled && scheme.brightness == Brightness.dark;
    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: black ? Colors.black : scheme.surface,
        colorScheme: black
            ? scheme.copyWith(
                surface: Colors.black,
                surfaceContainerLowest: Colors.black,
                surfaceContainerLow: const Color(0xFF0A0A0A),
                surfaceContainer: const Color(0xFF121212),
                surfaceContainerHigh: const Color(0xFF1A1A1A),
                surfaceContainerHighest: const Color(0xFF222222),
              )
            : scheme,
      ),
      child: child,
    );
  }
}
