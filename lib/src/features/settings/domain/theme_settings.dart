import 'package:material_ui/material_ui.dart';

const defaultSeedColor = Color(0xFF5B7CFA);

/// Accent choices shown when dynamic color is off.
const accentChoices = [
  defaultSeedColor,
  Color(0xFF6750A4),
  Color(0xFF0061A4),
  Color(0xFF006E1C),
  Color(0xFFBA1A1A),
  Color(0xFF984061),
  Color(0xFFB26A00),
  Color(0xFF006874),
];

/// Visual system: Material 3 Expressive, or "Mornye" (iOS-style grouped
/// colours, Cupertino icons and glass surfaces).
enum AppThemeStyle { material, mornye }

/// Accent of the Mornye style (iOS system colours).
enum MornyeAccent { red, orange, green, teal, blue, purple, pink }

const defaultMornyeGlassClarity = 0.75;

@immutable
class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.useDynamicColor = true,
    this.seedColor = defaultSeedColor,
    this.useAmoled = false,
    this.style = AppThemeStyle.material,
    this.mornyeAccent = MornyeAccent.red,
    this.mornyeGlassClarity = defaultMornyeGlassClarity,
    this.mornyeGlassOutlines = true,
  });

  final ThemeMode mode;

  /// Follow the device's wallpaper palette where the platform provides one.
  final bool useDynamicColor;
  final Color seedColor;

  /// Pure-black surfaces in dark mode.
  final bool useAmoled;
  final AppThemeStyle style;
  final MornyeAccent mornyeAccent;

  /// 0 (tinted) to 1 (clear) glass in the Mornye style.
  final double mornyeGlassClarity;
  final bool mornyeGlassOutlines;

  ThemeSettings copyWith({
    ThemeMode? mode,
    bool? useDynamicColor,
    Color? seedColor,
    bool? useAmoled,
    AppThemeStyle? style,
    MornyeAccent? mornyeAccent,
    double? mornyeGlassClarity,
    bool? mornyeGlassOutlines,
  }) => ThemeSettings(
    mode: mode ?? this.mode,
    useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    seedColor: seedColor ?? this.seedColor,
    useAmoled: useAmoled ?? this.useAmoled,
    style: style ?? this.style,
    mornyeAccent: mornyeAccent ?? this.mornyeAccent,
    mornyeGlassClarity: (mornyeGlassClarity ?? this.mornyeGlassClarity).clamp(
      0.0,
      1.0,
    ),
    mornyeGlassOutlines: mornyeGlassOutlines ?? this.mornyeGlassOutlines,
  );
}
