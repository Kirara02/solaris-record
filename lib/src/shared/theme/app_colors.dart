import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_ui/material_ui.dart';

/// Seed used when the platform provides no dynamic palette.
const fallbackSeed = Color(0xFF5B7CFA);

const _gold = Color(0xFFE0A526);
const _violet = Color(0xFF9B6BE0);

/// Rarity accents, harmonized toward the active scheme's primary so they follow
/// the wallpaper-derived palette while staying recognisably gold / violet.
Color rarityColor(ColorScheme scheme, int rarity) {
  Color harmonize(Color design) =>
      Color(Blend.harmonize(design.toARGB32(), scheme.primary.toARGB32()));
  return switch (rarity) {
    5 => harmonize(_gold),
    4 => harmonize(_violet),
    _ => scheme.outline,
  };
}
