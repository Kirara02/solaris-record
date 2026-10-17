import 'package:dynamic_color/dynamic_color.dart';
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

    // The device palette comes from DynamicColorBuilder as the real system
    // scheme (Android's Material You roles), not re-derived from its primary
    // colour: M3ETheme's own dynamic host seeds a new scheme from the primary
    // only, which gives different surfaces and containers than the wallpaper
    // palette. Desktop platforms only expose an accent colour, so there the
    // scheme is seeded from it either way.
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        M3EThemeData dataFor(Brightness brightness) {
          final dark = brightness == Brightness.dark;
          final base = dark
              ? M3EThemeData.dark(seedColor: settings.seedColor)
              : M3EThemeData.light(seedColor: settings.seedColor);
          final device = dark ? darkDynamic : lightDynamic;
          final scheme = settings.useDynamicColor && device != null
              ? M3EColorScheme.fromColorScheme(device).harmonized()
              : base.colorScheme;
          return base.copyWith(
            fontFamily: 'Inter',
            // AMOLED is applied to the scheme itself so ThemeData and M3E
            // widgets agree on the black surfaces.
            colorScheme: dark && settings.useAmoled
                ? scheme.copyWith(
                    surface: Colors.black,
                    surfaceContainerLowest: Colors.black,
                    surfaceContainerLow: const Color(0xFF0A0A0A),
                    surfaceContainer: const Color(0xFF121212),
                    surfaceContainerHigh: const Color(0xFF1A1A1A),
                    surfaceContainerHighest: const Color(0xFF222222),
                  )
                : scheme,
            // Rail items span the whole rail like the hand-drawn Settings
            // item (pill = rail width minus a 16px inset on each side, the
            // same inset the rail gives its trailing slot), instead of
            // shrinking to their label.
            navigationRailTheme: M3ENavigationRailTheme.defaults.copyWith(
              indicatorFillsWidth: true,
              expandedItemInset: 16,
              // Modern sidebar look: slim rounded-rectangle indicators (not
              // full pills) with a tight vertical rhythm. Colours stay
              // theme-derived so dynamic color still applies.
              expandedIndicatorHeight: RailMetrics.itemHeight,
              expandedIndicatorRadius: RailMetrics.indicatorRadius,
              itemExpandedHeight: RailMetrics.itemHeight,
              shortItemHeight: RailMetrics.shortItemHeight,
              noLabelIndicatorSize: RailMetrics.collapsedIndicator,
              itemVerticalGap: 2,
              topSpace: 20,
            ),
          );
        }

        return MaterialApp.router(
          routerConfig: ref.watch(appRouterProvider),
          onGenerateTitle: (context) => context.t.appName,
          debugShowCheckedModeBanner: false,
          theme: applyAppTheme(dataFor(Brightness.light).toThemeData()),
          darkTheme: applyAppTheme(dataFor(Brightness.dark).toThemeData()),
          themeMode: settings.mode,
          // M3ETheme reads the parent Theme once per rebuild. With the default
          // animated transition it can capture a half-interpolated (or stale)
          // theme, so switch instantly.
          themeAnimationDuration: Duration.zero,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          // M3EThemeScope can't take a ready-made dark scheme (it re-derives
          // dark from the light primary), so the matching data is picked here
          // from the same brightness MaterialApp resolves.
          builder: (context, child) => M3ETheme(
            data: dataFor(switch (settings.mode) {
              ThemeMode.light => Brightness.light,
              ThemeMode.dark => Brightness.dark,
              ThemeMode.system => MediaQuery.platformBrightnessOf(context),
            }),
            child: _ResolvedThemeScope(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}

/// Pins the page background to the resolved scheme.
///
/// Sits inside M3ETheme. The Scaffold background comes from
/// `ThemeData.scaffoldBackgroundColor`, which M3ETheme doesn't recompute from
/// the scheme it resolves (dynamic palette, brightness, AMOLED), so it could
/// disagree with the rest of the UI (e.g. a black page behind light content).
class _ResolvedThemeScope extends StatelessWidget {
  const _ResolvedThemeScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(scaffoldBackgroundColor: theme.colorScheme.surface),
      child: child,
    );
  }
}
