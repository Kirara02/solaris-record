import 'challenge_models.dart';
import 'challenge_text.dart';

/// Everything encore.moe's monster page shows: art, class, element, the two
/// descriptions and the base stats.
class MonsterInfo {
  const MonsterInfo({
    required this.id,
    required this.name,
    this.iconUrl,
    this.rarity,
    this.rarityId,
    this.element,
    this.description,
    this.properties = const [],
    this.growth = const {},
  });

  final int id;
  final String name;
  final String? iconUrl;

  /// Class label such as "Elite Class".
  final String? rarity;

  /// 1 standard, 2 elite, 3 overlord, 4 calamity.
  final int? rarityId;
  final ChallengeElement? element;

  /// Game markup (`<br>`, colour spans); render with `MarkupText`.
  final String? description;

  /// HP, ATK, DEF and resistances at level 1, in the order they are shown.
  final List<MonsterProperty> properties;

  /// Per level, each property's growth ratio in ten-thousandths, keyed by the
  /// property key (`LifeMax` for the API's `LifeMaxRatio`).
  final Map<int, Map<String, num>> growth;

  /// Highest level with growth data; zero when the enemy does not scale.
  int get maxLevel =>
      growth.keys.fold(0, (max, level) => level > max ? level : max);

  /// [property] at [level]: its base value times the level's ratio, as
  /// encore.moe's own stats table computes it. Without a ratio (resistances,
  /// or no data for that level) the base value stays.
  num valueAt(MonsterProperty property, int level) {
    final ratio = growth[level]?[property.key];
    return ratio == null || ratio == 0
        ? property.base
        : property.base * ratio / 10000;
  }
}

/// One stat of an enemy at level 1.
class MonsterProperty {
  const MonsterProperty(
    this.key,
    this.name,
    this.base, {
    this.isPercent = false,
    this.iconUrl,
  });

  /// The API's property key, such as `LifeMax` or `DamageResistancePhys`.
  final String key;
  final String name;
  final num base;
  final bool isPercent;
  final String? iconUrl;
}

/// Shown first, in this order; everything else follows in the API's order.
const _leadingKeys = ['LifeMax', 'Atk', 'Def'];

/// Properties that are worth showing only when they are not zero.
const _hideWhenZero = {'HardnessMax', 'RageMax'};

MonsterInfo? parseMonsterInfo(Object? raw) {
  if (raw is! Map) return null;
  final name = textOf(raw['Name']);
  final id = raw['Id'];
  if (name == null || id is! int) return null;

  final properties = <MonsterProperty>[];
  final props = raw['Properties'];
  if (props is Map) {
    for (final entry in props.entries) {
      final p = entry.value;
      if (p is! Map || p['Value'] is! num) continue;
      final label = textOf(p['Name']);
      if (label == null) continue;
      final key = '${entry.key}';
      final value = p['Value'] as num;
      if (value == 0 && _hideWhenZero.contains(key)) continue;
      // Resistances come in hundredths of a percent (1000 is 10%).
      final percent = key.startsWith('DamageResistance');
      properties.add(
        MonsterProperty(
          key,
          label,
          percent ? value / 100 : value,
          isPercent: percent,
          iconUrl: _url(p['Icon']),
        ),
      );
    }
  }

  final growth = <int, Map<String, num>>{};
  final rates = raw['GrowthRates'];
  if (rates is Map) {
    for (final entry in rates.entries) {
      final level = int.tryParse('${entry.key}');
      final row = entry.value;
      if (level == null || row is! Map) continue;
      growth[level] = {
        for (final r in row.entries)
          if (r.value is num && '${r.key}'.endsWith('Ratio'))
            '${r.key}'.substring(0, '${r.key}'.length - 'Ratio'.length):
                r.value as num,
      };
    }
  }

  final element = raw['Element'];
  final rarity = raw['Rarity'];
  return MonsterInfo(
    id: id,
    name: name,
    iconUrl: _url(raw['Icon']),
    rarity: rarity is String && rarity.trim().isNotEmpty ? rarity.trim() : null,
    rarityId: raw['RarityId'] is int ? raw['RarityId'] as int : null,
    element: element is Map && textOf(element['Name']) != null
        ? ChallengeElement(textOf(element['Name'])!, _url(element['Icon']))
        : null,
    description: rawOf(raw['DiscoveredDes']) ?? rawOf(raw['UndiscoveredDes']),
    properties: [
      for (final key in _leadingKeys) ...properties.where((p) => p.key == key),
      ...properties.where((p) => !_leadingKeys.contains(p.key)),
    ],
    growth: growth,
  );
}

/// The monster endpoint names its images `.png`, but only the `.webp` copies
/// exist on the resource server (the same files the season lists point at).
String? _url(Object? v) {
  if (v is! String || v.isEmpty) return null;
  return v.replaceFirst(RegExp(r'\.png$', caseSensitive: false), '.webp');
}
