import '../../features/stats/domain/pool_type.dart';
import 'gen/strings.g.dart';

extension PoolTypeLabel on PoolType {
  String label(Translations t) => switch (this) {
    PoolType.featuredResonator => t.pools.featuredResonator,
    PoolType.featuredWeapon => t.pools.featuredWeapon,
    PoolType.standardResonator => t.pools.standardResonator,
    PoolType.standardWeapon => t.pools.standardWeapon,
    PoolType.beginner => t.pools.beginner,
    PoolType.beginnerChoice => t.pools.beginnerChoice,
    PoolType.newVoyageResonator => t.pools.newVoyageResonator,
    PoolType.newVoyageWeapon => t.pools.newVoyageWeapon,
    PoolType.collabResonator => t.pools.collabResonator,
    PoolType.collabWeapon => t.pools.collabWeapon,
    PoolType.reverbResonator => t.pools.reverbResonator,
    PoolType.reverbWeapon => t.pools.reverbWeapon,
  };
}
