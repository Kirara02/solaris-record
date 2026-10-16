/// Convene pools, keyed by the `cardPoolType` id used by the Kuro API.
enum PoolType {
  featuredResonator(1),
  featuredWeapon(2),
  standardResonator(3),
  standardWeapon(4),
  beginner(5),
  beginnerChoice(6),
  newVoyageResonator(8),
  newVoyageWeapon(9),
  collabResonator(10),
  collabWeapon(11),
  reverbResonator(12),
  reverbWeapon(13);

  const PoolType(this.id);

  final int id;

  /// Only the featured resonator banner has a 50/50 split; the featured
  /// weapon banner always gives the featured weapon.
  /// Pulls at which a 5★ is guaranteed. The beginner convene is the only
  /// pool with a lower limit.
  int get hardPity5 => this == beginner ? 50 : 80;

  bool get hasFiftyFifty => this == featuredResonator;

  static PoolType fromId(int id) =>
      PoolType.values.firstWhere((p) => p.id == id);
}
