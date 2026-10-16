enum ItemKind { resonator, weapon }

/// Prefers the API's resource type; falls back to the id length (resonators
/// are 4 digits, weapons 8) when the type string isn't recognised.
ItemKind? itemKindFor(int resourceId, String resourceType) {
  switch (resourceType.toLowerCase()) {
    case 'resonator':
      return ItemKind.resonator;
    case 'weapon':
      return ItemKind.weapon;
  }
  final digits = resourceId.toString().length;
  if (digits == 4) return ItemKind.resonator;
  if (digits == 8) return ItemKind.weapon;
  return null;
}
