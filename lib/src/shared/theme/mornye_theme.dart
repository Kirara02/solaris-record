import 'package:flutter/cupertino.dart'
    show CupertinoColors, CupertinoDynamicColor;
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
    this.glassClarity = 0.5,
    this.glassOutlines = true,
    this.accent = MornyeAccent.red,
  });

  /// 0 (milky) to 1 (almost see-through).
  final double glassClarity;
  final bool glassOutlines;

  final MornyeAccent accent;

  static const standard = MornyeTheme();

  @override
  MornyeTheme copyWith({
    double? glassClarity,
    bool? glassOutlines,
    MornyeAccent? accent,
  }) => MornyeTheme(
    glassClarity: glassClarity ?? this.glassClarity,
    glassOutlines: glassOutlines ?? this.glassOutlines,
    accent: accent ?? this.accent,
  );

  @override
  MornyeTheme lerp(ThemeExtension<MornyeTheme>? other, double t) {
    if (other is! MornyeTheme) return this;
    return MornyeTheme(
      glassClarity: glassClarity + (other.glassClarity - glassClarity) * t,
      glassOutlines: t < 0.5 ? glassOutlines : other.glassOutlines,
      accent: t < 0.5 ? accent : other.accent,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MornyeTheme &&
      other.glassClarity == glassClarity &&
      other.glassOutlines == glassOutlines &&
      other.accent == accent;

  @override
  int get hashCode => Object.hash(glassClarity, glassOutlines, accent);

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
    headerExpandedHeight: 96,
    headerCollapsedTitleSize: 17,
    headerExpandedTitleSize: 34,
    motionMedium: const Duration(milliseconds: 300),
  );

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

  static final _cache = <(Brightness, MornyeTheme), ThemeData>{};

  /// Material [ThemeData] with the iOS palette mapped onto the M3 roles, so
  /// widgets that read `colorScheme` need no changes.
  static ThemeData build(
    Brightness brightness, [
    MornyeTheme extra = MornyeTheme.standard,
  ]) => _cache[(brightness, extra)] ??= _build(brightness, extra);

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

    final typography = Typography.material2021(
      platform: defaultTargetPlatform == TargetPlatform.macOS
          ? TargetPlatform.macOS
          : TargetPlatform.iOS,
    );
    var text = (dark ? typography.white : typography.black).apply(
      bodyColor: label,
      displayColor: label,
    );
    // The SF fonts only exist on Apple platforms.
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      text = text.apply(fontFamily: 'Inter');
    }

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
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
      // Popup menus can't host a blur through the theme, so they get a nearly
      // opaque card colour, no tint and a soft rounded shape.
      popupMenuTheme: PopupMenuThemeData(
        color: card.withValues(alpha: 0.96),
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusControl + 2),
          side: BorderSide(color: separator, width: 0.5),
        ),
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
  /// Whether the "Mornye" (iOS glass) style is active.
  bool get isMornye => Theme.of(this).extension<MornyeTheme>() != null;

  /// The style's glass settings, or the defaults under Material.
  MornyeTheme get mornye =>
      Theme.of(this).extension<MornyeTheme>() ?? MornyeTheme.standard;
}
