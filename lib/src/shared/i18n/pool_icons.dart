import 'package:material_ui/material_ui.dart';

import '../../features/stats/domain/pool_type.dart';

/// Icons for the pull types. Only used where there is no room for a label:
/// the collapsed navigation rail shows the pull types as icons alone.
extension PoolTypeIcon on PoolType {
  IconData get icon => switch (this) {
    PoolType.featuredResonator => Icons.person_outline,
    PoolType.featuredWeapon => Icons.shield_outlined,
    PoolType.standardResonator => Icons.badge_outlined,
    PoolType.standardWeapon => Icons.security,
    PoolType.beginner => Icons.school_outlined,
    PoolType.beginnerChoice => Icons.checklist,
    PoolType.newVoyageResonator => Icons.explore_outlined,
    PoolType.newVoyageWeapon => Icons.travel_explore,
    PoolType.collabResonator => Icons.handshake_outlined,
    PoolType.collabWeapon => Icons.link,
    PoolType.reverbResonator => Icons.graphic_eq,
    PoolType.reverbWeapon => Icons.equalizer,
  };
}
