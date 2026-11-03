import 'package:flutter/cupertino.dart'
    show CupertinoColors, CupertinoThemeData, CupertinoDynamicColor;
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/domain/theme_settings.dart';
import 'app_theme.dart';
import 'app_tokens.dart';

/// iOS green, used by switches.
const mornyeGreen = Color(0xFF34C759);

/// Settings of the "Mornye" style that are not plain colours: how clear the
/// glass is, whether surfaces get a hairline rim, and the accent. Only the
/// defaults are used for now; the values exist so those controls can be added
/// without touching the widgets that read them.
@immutable
class MornyeTheme extends ThemeExtension<MornyeTheme> {
  const MornyeTheme({
    this.glassClarity = defaultMornyeGlassClarity,
    this.glassOutlines = true,
    this.glassForced = false,
    this.accent = MornyeAccent.red,
    this.useSystemFont = false,
  });

  /// 0 (milky) to 1 (almost see-through).
  final double glassClarity;
  final bool glassOutlines;

  /// Keeps the glass on when the system asks for more contrast.
  final bool glassForced;

  final MornyeAccent accent;

  /// The platform's font instead of Inter (Apple platforms always use SF).
  final bool useSystemFont;

  static const standard = MornyeTheme();

  @override
  MornyeTheme copyWith({
    double? glassClarity,
    bool? glassOutlines,
    bool? glassForced,
    MornyeAccent? accent,
    bool? useSystemFont,
  }) => MornyeTheme(
    glassClarity: glassClarity ?? this.glassClarity,
    glassOutlines: glassOutlines ?? this.glassOutlines,
    glassForced: glassForced ?? this.glassForced,
    accent: accent ?? this.accent,
    useSystemFont: useSystemFont ?? this.useSystemFont,
  );

  @override
  MornyeTheme lerp(ThemeExtension<MornyeTheme>? other, double t) {
    if (other is! MornyeTheme) return this;
    return MornyeTheme(
      glassClarity: glassClarity + (other.glassClarity - glassClarity) * t,
      glassOutlines: t < 0.5 ? glassOutlines : other.glassOutlines,
      glassForced: t < 0.5 ? glassForced : other.glassForced,
      accent: t < 0.5 ? accent : other.accent,
      useSystemFont: t < 0.5 ? useSystemFont : other.useSystemFont,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MornyeTheme &&
      other.glassClarity == glassClarity &&
      other.glassOutlines == glassOutlines &&
      other.glassForced == glassForced &&
      other.accent == accent &&
      other.useSystemFont == useSystemFont;

  @override
  int get hashCode => Object.hash(
    glassClarity,
    glassOutlines,
    glassForced,
    accent,
    useSystemFont,
  );

  /// Radius, row and header scale of the style, on top of the Material one.
  static final tokens = AppTokens.standard.copyWith(
    radiusBadge: 4,
    radiusThumb: 8,
    radiusCover: 10,
    radiusControl: 12,
    radiusCard: 14,
    radiusSheet: 32,
    rowPaddingH: 16,
    rowPaddingV: 12,
    rowIconGap: 12,
    rowIconDividerIndent: 48,
    rowChevronSize: 20,
    headerExpandedHeight: 96,
    headerCollapsedTitleSize: 17,
    headerExpandedTitleSize: 34,
    motionMedium: const Duration(milliseconds: 300),
  );

  /// Fill of an inset control or well drawn on a grouped surface or dialog.
  static Color controlFill(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.onSurface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.10 : 0.07,
    );
  }

  /// The accent as drawn on the grouped surfaces. The light red is darker than
  /// iOS's own so small red text stays readable on white.
  static Color accentColor(MornyeAccent accent, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final color = switch (accent) {
      MornyeAccent.red => const CupertinoDynamicColor.withBrightness(
        color: Color(0xFFCC2E33),
        darkColor: Color(0xFFFF453A),
      ),
      MornyeAccent.orange => CupertinoColors.systemOrange,
      MornyeAccent.green => CupertinoColors.systemGreen,
      MornyeAccent.teal => CupertinoColors.systemTeal,
      MornyeAccent.blue => CupertinoColors.systemBlue,
      MornyeAccent.purple => CupertinoColors.systemPurple,
      MornyeAccent.pink => CupertinoColors.systemPink,
    };
    // Green and orange on white need the darker, high-contrast variant.
    if (!dark && accent == MornyeAccent.green) return const Color(0xFF24863D);
    return dark ? color.darkColor : color.highContrastColor;
  }

  // Building a theme seeds a colour scheme and the whole text theme. Only the
  // accent and the font change those, so the base is cached on them alone; the
  // glass settings (the clarity slider moves them on every step) are swapped
  // into a copy, and the last copy is reused while the settings stay equal.
  static final _baseCache =
      <(TargetPlatform, Brightness, MornyeAccent, bool), ThemeData>{};
  static final _glassVariants = Expando<ThemeData>();

  /// Material [ThemeData] with the iOS palette mapped onto the M3 roles, so
  /// widgets that read `colorScheme` need no changes.
  static ThemeData build(
    Brightness brightness, [
    MornyeTheme extra = MornyeTheme.standard,
  ]) {
    final base =
        _baseCache[(
          defaultTargetPlatform,
          brightness,
          extra.accent,
          extra.useSystemFont,
        )] ??= _build(
          brightness,
          MornyeTheme(accent: extra.accent, useSystemFont: extra.useSystemFont),
        );
    return _withGlass(base, extra);
  }

  static ThemeData _withGlass(ThemeData theme, MornyeTheme extra) {
    if (theme.extension<MornyeTheme>() == extra) return theme;
    final variant = _glassVariants[theme];
    if (variant?.extension<MornyeTheme>() == extra) return variant!;
    return _glassVariants[theme] = theme.copyWith(
      extensions: [
        for (final extension in theme.extensions.values)
          if (extension is MornyeTheme) extra else extension,
      ],
    );
  }

  static ThemeData _build(Brightness brightness, MornyeTheme extra) {
    final dark = brightness == Brightness.dark;
    final accent = accentColor(extra.accent, brightness);
    final page = dark ? Colors.black : const Color(0xFFF2F2F7);
    final card = dark ? const Color(0xFF1C1C1E) : Colors.white;
    final raised = dark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final label = dark ? Colors.white : Colors.black;
    final secondary = dark ? const Color(0xFF98989F) : const Color(0xFF6C6C70);
    final separator = dark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    final error = dark ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);

    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          onPrimary: Colors.white,
          primaryContainer: raised,
          onPrimaryContainer: accent,
          secondary: accent,
          onSecondary: Colors.white,
          secondaryContainer: raised,
          onSecondaryContainer: label,
          tertiary: dark
              ? CupertinoColors.systemOrange.darkColor
              : CupertinoColors.systemOrange.color,
          error: error,
          onError: Colors.white,
          errorContainer: Color.alphaBlend(error.withValues(alpha: 0.16), card),
          onErrorContainer: error,
          surface: page,
          onSurface: label,
          onSurfaceVariant: secondary,
          surfaceTint: Colors.transparent,
          surfaceContainerLowest: page,
          surfaceContainerLow: card,
          surfaceContainer: card,
          surfaceContainerHigh: card,
          surfaceContainerHighest: raised,
          outline: separator,
          outlineVariant: separator,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: dark ? Colors.white : const Color(0xFF2C2C2E),
          onInverseSurface: dark ? Colors.black : Colors.white,
        );

    // The text scale of iOS: the Cupertino styles (17 body, 15 secondary, 13
    // small) with their tracking, one complete style per Material role. A bare
    // Material scale (16/14/12) reads tighter than iOS next to the same rows.
    // The SF fonts only exist on Apple platforms; Inter stands in elsewhere.
    final apple =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final type = CupertinoThemeData(brightness: brightness).textTheme;
    final system = apple || extra.useSystemFont;
    final body = type.textStyle.copyWith(
      inherit: true,
      color: label,
      fontFamily: system ? type.textStyle.fontFamily : 'Inter',
    );
    final display = type.navLargeTitleTextStyle.copyWith(
      inherit: true,
      color: label,
      fontFamily: system ? type.navLargeTitleTextStyle.fontFamily : 'Inter',
    );
    final text = TextTheme(
      displayLarge: display.copyWith(fontSize: 57),
      displayMedium: display.copyWith(fontSize: 45),
      displaySmall: display.copyWith(fontSize: 36),
      headlineLarge: display,
      headlineMedium: display.copyWith(fontSize: 28, letterSpacing: 0.36),
      headlineSmall: display.copyWith(fontSize: 22, letterSpacing: 0.35),
      titleLarge: display.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.38,
      ),
      titleMedium: body.copyWith(fontWeight: FontWeight.w500),
      titleSmall: body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.23,
      ),
      bodyLarge: body,
      bodyMedium: body.copyWith(fontSize: 15, letterSpacing: -0.23),
      bodySmall: body.copyWith(
        fontSize: 13,
        letterSpacing: -0.08,
        color: secondary,
      ),
      labelLarge: body.copyWith(fontWeight: FontWeight.w600),
      labelMedium: body.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.08,
      ),
      labelSmall: body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.24,
        color: secondary,
      ),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      fontFamily: body.fontFamily,
      scaffoldBackgroundColor: page,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: label.withValues(alpha: dark ? 0.12 : 0.06),
      extensions: [extra],
    );
    return applyAppTheme(base, tokens: tokens).copyWith(
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        space: 0.5,
        color: separator,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSheet),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        constraints: const BoxConstraints(maxWidth: 640),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusSheet),
          ),
        ),
      ),
      // The popup route's surface is transparent: a popup menu draws its own
      // glass panel (see GlassMenu), as the Mornye app's menus do.
      popupMenuTheme: const PopupMenuThemeData(
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusControl),
        ),
      ),
      switchTheme: SwitchThemeData(thumbIcon: WidgetStateProperty.all(null)),
    );
  }
}

extension MornyeContext on BuildContext {
  /// Whether the system's contrast request switches the glass off: it does
  /// unless the user chose to keep the glass.
  bool get glassContrastBlocked =>
      MediaQuery.highContrastOf(this) && !mornye.glassForced;

  /// Whether the "Mornye" (iOS glass) style is active.
  bool get isMornye => Theme.of(this).extension<MornyeTheme>() != null;

  /// The style's glass settings, or the defaults under Material.
  MornyeTheme get mornye =>
      Theme.of(this).extension<MornyeTheme>() ?? MornyeTheme.standard;
}

/// Settings pages use iOS's large inset-grouped corners. Only the card radius
/// changes: the page already uses the grouped palette everywhere.
class MornyeSettingsTheme extends StatelessWidget {
  const MornyeSettingsTheme({super.key, required this.child});

  final Widget child;

  // Reusing the derived theme keeps a rebuild from notifying the whole page.
  static final _themes = Expando<ThemeData>();

  @override
  Widget build(BuildContext context) {
    if (!context.isMornye) return child;
    final theme = Theme.of(context);
    return Theme(
      data: _themes[theme] ??= theme.copyWith(
        extensions: [
          for (final extension in theme.extensions.values)
            if (extension is AppTokens)
              extension.copyWith(radiusCard: 24)
            else
              extension,
        ],
      ),
      child: child,
    );
  }
}
