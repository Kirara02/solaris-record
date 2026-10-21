import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_colors.dart';

/// Name of an echo class (the list's `Rarity`: 0 common to 3 calamity).
String echoClassLabel(Translations t, int echoClass) => switch (echoClass) {
  0 => t.guide.classCommon,
  1 => t.guide.classElite,
  2 => t.guide.classOverlord,
  _ => t.guide.classCalamity,
};

/// Accent of an echo class, on the same scale as the item rarities.
Color echoClassColor(ColorScheme scheme, int echoClass) =>
    rarityColor(scheme, switch (echoClass) {
      0 => 3,
      1 => 4,
      _ => 5,
    });
