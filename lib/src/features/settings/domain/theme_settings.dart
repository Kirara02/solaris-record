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

@immutable
class ThemeSettings {
  const ThemeSettings({
    this.mode = ThemeMode.system,
    this.useDynamicColor = true,
    this.seedColor = defaultSeedColor,
    this.useAmoled = false,
  });

  final ThemeMode mode;

  /// Follow the device's wallpaper palette where the platform provides one.
  final bool useDynamicColor;
  final Color seedColor;

  /// Pure-black surfaces in dark mode.
  final bool useAmoled;

  ThemeSettings copyWith({
    ThemeMode? mode,
    bool? useDynamicColor,
    Color? seedColor,
    bool? useAmoled,
  }) => ThemeSettings(
    mode: mode ?? this.mode,
    useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    seedColor: seedColor ?? this.seedColor,
    useAmoled: useAmoled ?? this.useAmoled,
  );
}
