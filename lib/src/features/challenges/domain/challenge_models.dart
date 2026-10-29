import 'package:flutter/painting.dart' show Color;

import 'challenge_text.dart';

class ChallengeElement {
  const ChallengeElement(this.name, this.iconUrl);

  final String name;
  final String? iconUrl;
}

/// One row of a monster's stat table.
class MonsterStat {
  const MonsterStat(
    this.name,
    this.value, {
    this.isPercent = false,
    this.iconUrl,
  });

  final String name;
  final num value;
  final bool isPercent;
  final String? iconUrl;
}

/// The stats the encore.moe tower page shows for a monster, in its order of
/// appearance in the data.
const _shownStats = {
  'Lv',
  'LifeMax',
  'Atk',
  'Def',
  'CritRate',
  'CritDamage',
  'DamageResistancePhys',
  'DamageResistanceElement1',
  'DamageResistanceElement2',
  'DamageResistanceElement3',
  'DamageResistanceElement4',
  'DamageResistanceElement5',
  'DamageResistanceElement6',
  'ToughMax',
  'Tough',
  'ToughRecover',
  'ToughChange',
  'ToughReduce',
  'HardnessMax',
  'Hardness',
  'HardnessRecover',
  'HardnessChange',
  'HardnessReduce',
  'WeakTime',
  'AutoAttackSpeed',
  'CastAttackSpeed',
  'WeaknessBuildUpMax',
  'BreakWeaknessRatio',
};

class ChallengeMonster {
  const ChallengeMonster({
    required this.name,
    this.id,
    this.iconUrl,
    this.level,
    this.rarity,
    this.rarityId,
    this.elements = const [],
    this.stats = const [],
  });

  final String name;

  /// encore.moe monster id, which its detail page is addressed by.
  final int? id;
  final String? iconUrl;
  final int? level;

  /// Class label such as "Overlord Class (COST 4)".
  final String? rarity;

  /// 1 standard, 2 elite, 3 overlord, 4 calamity (colours the tile's edge).
  final int? rarityId;
  final List<ChallengeElement> elements;
  final List<MonsterStat> stats;
}

List<ChallengeElement> _elements(Object? raw) => [
  for (final e in listOf(raw))
    if (e is Map && textOf(e['name']) != null)
      ChallengeElement(textOf(e['name'])!, _url(e['icon'])),
];

String? _url(Object? v) => v is String && v.isNotEmpty ? v : null;

ChallengeMonster? parseMonster(Object? raw) {
  if (raw is! Map) return null;
  final name = textOf(raw['name']);
  if (name == null) return null;
  int? level;
  for (final p in listOf(raw['whiteGreenProps'])) {
    if (p is Map && p['key'] == 'Lv' && p['value'] is num) {
      level = (p['value'] as num).round();
    }
  }
  final rarity = raw['rarity'];
  final stats = <MonsterStat>[
    for (final p in listOf(raw['whiteGreenProps']))
      if (p is Map &&
          _shownStats.contains(p['key']) &&
          p['value'] is num &&
          textOf(p['name']) != null)
        MonsterStat(
          textOf(p['name'])!,
          p['value'] as num,
          isPercent: p['isPercent'] == true,
          iconUrl: _url(p['icon']),
        ),
  ];
  var elements = _elements(raw['elements']);
  final single = raw['element'];
  if (elements.isEmpty && single is Map) elements = _elements([single]);
  return ChallengeMonster(
    name: name,
    id: raw['id'] is int ? raw['id'] as int : null,
    iconUrl: _url(raw['icon']),
    level: level,
    rarity: rarity is Map ? textOf(rarity['desc']) : null,
    rarityId: rarity is Map && rarity['id'] is int ? rarity['id'] as int : null,
    elements: elements,
    stats: stats,
  );
}

List<ChallengeMonster> parseMonsters(Object? raw) => [
  for (final m in listOf(raw)) ?parseMonster(m),
];

// Tower of Adversity -------------------------------------------------------

/// A stage modifier or bonus objective.
class TowerEffect {
  const TowerEffect(this.id, this.text, {this.iconUrl});

  final int id;
  final String text;
  final String? iconUrl;
}

/// Effects shared by a run of floors; the tower page lists them once with the
/// floors they apply to.
class TowerEffectGroup {
  const TowerEffectGroup(this.effects, this.floors);

  final List<TowerEffect> effects;
  final List<int> floors;

  /// "1-4", "1, 3" or "2": consecutive floors collapse into a range.
  String get floorLabel {
    final f = [...floors]..sort();
    if (f.length > 2 &&
        [for (var i = 1; i < f.length; i++) f[i] - f[i - 1]]
            .every((d) => d == 1)) {
      return '${f.first}-${f.last}';
    }
    return f.join(', ');
  }
}

class TowerStage {
  const TowerStage({
    required this.floor,
    required this.cost,
    this.backgroundUrl,
    this.monsters = const [],
    this.buffs = const [],
    this.targets = const [],
  });

  final int floor;

  /// Team cost limit of the stage.
  final int cost;
  final String? backgroundUrl;
  final List<ChallengeMonster> monsters;
  final List<TowerEffect> buffs;
  final List<TowerEffect> targets;
}

class TowerArea {
  const TowerArea(this.name, this.stages, this.buffGroups, this.targetGroups);

  final String name;
  final List<TowerStage> stages;
  final List<TowerEffectGroup> buffGroups;
  final List<TowerEffectGroup> targetGroups;
}

class TowerSeason {
  const TowerSeason(this.areas);

  final List<TowerArea> areas;
}

int _int(Object? v) => v is num ? v.round() : 0;

List<TowerEffect> _effects(Object? raw, {bool icons = false}) => [
  for (final e in listOf(raw))
    if (e is Map &&
        e['id'] is int &&
        textOf(e['desc'] ?? e['description']) != null)
      TowerEffect(
        e['id'] as int,
        textOf(e['desc'] ?? e['description'])!,
        iconUrl: icons ? _url(e['icon']) : null,
      ),
];

List<TowerEffectGroup> _group(
  List<TowerStage> stages,
  List<TowerEffect> Function(TowerStage) pick,
) {
  final groups = <String, (List<TowerEffect>, List<int>)>{};
  for (final s in stages) {
    final effects = pick(s);
    final key = ([for (final e in effects) e.id]..sort()).join(',');
    groups.putIfAbsent(key, () => (effects, <int>[])).$2.add(s.floor);
  }
  return [
    for (final g in groups.values)
      if (g.$1.isNotEmpty) TowerEffectGroup(g.$1, g.$2),
  ];
}

int _numeric(Object? a, Object? b) =>
    (int.tryParse('$a') ?? 0).compareTo(int.tryParse('$b') ?? 0);

/// `{seasonId: {area: {floor: {cost: [stage]}}}}`. Like the encore.moe page,
/// each floor shows its first entry; the buffs and objectives that repeat
/// across floors are grouped per area.
TowerSeason parseTower(Object? json) {
  if (json is! Map || json.values.firstOrNull is! Map) {
    return const TowerSeason([]);
  }
  final season = json.values.first as Map;
  final areaKeys = season.keys.toList()..sort(_numeric);
  final areas = <TowerArea>[];
  for (final ak in areaKeys) {
    final floors = season[ak];
    if (floors is! Map) continue;
    String? name;
    final stages = <TowerStage>[];
    final floorKeys = floors.keys.toList()..sort(_numeric);
    for (final fk in floorKeys) {
      final byCost = floors[fk];
      if (byCost is! Map || byCost.isEmpty) continue;
      final list = byCost.values.first;
      final e = list is List && list.isNotEmpty ? list.first : null;
      if (e is! Map) continue;
      name ??= textOf(e['areaName']);
      stages.add(
        TowerStage(
          floor: int.tryParse('$fk') ?? _int(e['floor']),
          cost: _int(e['cost']),
          backgroundUrl: _url(e['bgPath']) ?? _url(e['background']),
          monsters: parseMonsters(e['monsters']),
          buffs: _effects(e['buffs'], icons: true),
          targets: _effects(e['targets']),
        ),
      );
    }
    if (stages.isEmpty) continue;
    areas.add(
      TowerArea(
        name ?? 'Area $ak',
        stages,
        _group(stages, (s) => s.buffs),
        _group(stages, (s) => s.targets),
      ),
    );
  }
  return TowerSeason(areas);
}

// Whimpering Wastes --------------------------------------------------------

/// An effect active in a stage, with the colour the game gives its name.
class WhiwaStageBuff {
  const WhiwaStageBuff(this.name, this.description, {this.iconUrl, this.color});

  final String name;
  final String description;
  final String? iconUrl;
  final Color? color;
}

class WhiwaStage {
  const WhiwaStage({
    this.description,
    this.monsters = const [],
    this.buffs = const [],
  });

  /// The stage rule, as game markup (see `MarkupText`).
  final String? description;
  final List<ChallengeMonster> monsters;
  final List<WhiwaStageBuff> buffs;
}

/// One floor of the mode (numbered by [orderIndex] across both stage groups).
class WhiwaLevel {
  const WhiwaLevel({
    required this.title,
    required this.orderIndex,
    this.description,
    this.scores = const [],
    this.stages = const [],
  });

  final String title;
  final int orderIndex;
  final String? description;

  /// Target score per grade, such as `B: 1500`.
  final List<(String, int)> scores;
  final List<WhiwaStage> stages;
}

class WhiwaGroup {
  const WhiwaGroup(this.name, this.levels);

  final String name;
  final List<WhiwaLevel> levels;
}

/// A token the player may bring to the floor numbered [orderIndex].
class WhiwaBuff {
  const WhiwaBuff(
    this.itemId,
    this.name,
    this.iconUrl, {
    required this.orderIndex,
    this.qualityId,
  });

  /// Id of the token item, used to look up its description.
  final int itemId;
  final String name;
  final String? iconUrl;
  final int orderIndex;
  final int? qualityId;
}

/// What a Whimpering Wastes token does, from the item endpoint.
class WhiwaBuffInfo {
  const WhiwaBuffInfo({
    required this.name,
    this.iconUrl,
    this.effect,
    this.story,
  });

  final String name;
  final String? iconUrl;
  final String? effect;
  final String? story;
}

class WhiwaSeason {
  const WhiwaSeason(this.groups, this.buffs);

  final List<WhiwaGroup> groups;

  /// Tokens of every floor; pick by [WhiwaBuff.orderIndex].
  final List<WhiwaBuff> buffs;

  /// Every floor number across the groups, ascending.
  List<int> get floors => ({
    for (final g in groups)
      for (final l in g.levels) l.orderIndex,
  }.toList()..sort());
}

Color? _color(Object? v) {
  if (v is! String) return null;
  final hex = v.replaceFirst('#', '');
  final n = int.tryParse(hex, radix: 16);
  if (n == null) return null;
  if (hex.length == 6) return Color(0xFF000000 | n);
  if (hex.length == 8) return Color(((n & 0xFF) << 24) | (n >> 8));
  return null;
}

WhiwaLevel? _level(Object? raw) {
  if (raw is! Map) return null;
  final title = textOf(raw['title']);
  if (title == null) return null;
  final targets = listOf(raw['targetScore']);
  final grades = listOf(raw['scoreStage']);
  return WhiwaLevel(
    title: title,
    orderIndex: _int(raw['orderIndex']),
    description: rawOf(raw['desc']),
    scores: [
      for (var i = 0; i < targets.length && i < grades.length; i++)
        if (targets[i] is num) ('${grades[i]}', (targets[i] as num).round()),
    ],
    stages: [
      for (final s in listOf(raw['stages']))
        if (s is Map)
          WhiwaStage(
            description: rawOf(s['dungeonDesc']),
            monsters: parseMonsters(s['monsters']),
            buffs: [
              for (final b in listOf(s['buffs']))
                if (b is Map && textOf(b['desc']) != null)
                  WhiwaStageBuff(
                    textOf(b['name']) ?? textOf(b['desc'])!,
                    textOf(b['desc'])!,
                    iconUrl: _url(b['path']),
                    color: _color(b['color']),
                  ),
            ],
          ),
    ],
  );
}

WhiwaSeason parseWhiwa(Object? json) {
  if (json is! Map) return const WhiwaSeason([], []);
  return WhiwaSeason(
    [
      for (final g in listOf(json['stageGroups']))
        if (g is Map && textOf(g['name']) != null)
          WhiwaGroup(textOf(g['name'])!, [
            for (final l in listOf(g['levels'])) ?_level(l),
          ]),
    ],
    [
      for (final b in listOf(json['buffItems']))
        if (b is Map &&
            b['itemId'] is int &&
            b['item'] is Map &&
            textOf(b['item']['name']) != null)
          WhiwaBuff(
            b['itemId'] as int,
            textOf(b['item']['name'])!,
            _url(b['item']['iconSmall']),
            orderIndex: _int(b['orderIndex']),
            qualityId: b['item']['qualityId'] is int
                ? b['item']['qualityId'] as int
                : null,
          ),
    ],
  );
}

WhiwaBuffInfo? parseBuffInfo(Object? json) {
  if (json is! Map) return null;
  final name = textOf(json['Name']);
  if (name == null) return null;
  return WhiwaBuffInfo(
    name: name,
    iconUrl: _url(json['Icon']),
    effect: textOf(json['AttributesDescription']),
    story: textOf(json['BgDescription']),
  );
}
