import '../../info/domain/item_info.dart';

/// What the guide lists.
enum GuideKind { resonator, weapon, echo }

/// A named attribute with its game icon (an element, a weapon class or a
/// sonata effect). Two facets are the same when their names match.
class GuideFacet {
  const GuideFacet(this.name, [this.iconUrl]);

  final String name;
  final String? iconUrl;

  @override
  bool operator ==(Object other) => other is GuideFacet && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

/// One row of a guide list: just enough to draw a card and open the detail.
class GuideEntry {
  const GuideEntry({
    required this.kind,
    required this.id,
    required this.name,
    required this.rarity,
    this.element,
    this.weapon,
    this.type,
    this.iconUrl,
    this.sets = const [],
  });

  final GuideKind kind;
  final int id;
  final String name;

  /// Stars for resonators and weapons; the class for echoes (0 common, 1
  /// elite, 2 overlord, 3 calamity).
  final int rarity;
  final GuideFacet? element;

  /// Weapon class of a resonator or weapon ("Sword", ...).
  final GuideFacet? weapon;

  /// The echo type ("Echo" or "Phantom Appearance"); echoes only.
  final String? type;
  final String? iconUrl;

  /// Sonata effects an echo belongs to.
  final List<GuideFacet> sets;
}

String? _str(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;

int _int(Object? v) => v is num ? v.toInt() : 0;

String? _name(Object? v) => v is Map ? _str(v['Name']) : null;

GuideFacet? _facet(Object? v, [String? name]) {
  final n = name ?? _name(v);
  if (n == null) return null;
  return GuideFacet(n, v is Map ? encoreAssetUrl(v['Icon']) : null);
}

List<Map<String, dynamic>> _list(Object? json, String key) {
  if (json is! Map) return const [];
  final raw = json[key];
  if (raw is! List) return const [];
  return [
    for (final e in raw)
      if (e is Map<String, dynamic>) e,
  ];
}

/// Parses `/api/{lang}/character` (`roleList`). Entries without an id or name
/// are skipped.
List<GuideEntry> parseResonatorList(Object? json) => [
  for (final e in _list(json, 'roleList'))
    if (_int(e['Id']) > 0 && _str(e['Name']) != null)
      GuideEntry(
        kind: GuideKind.resonator,
        id: _int(e['Id']),
        name: _str(e['Name'])!,
        rarity: _int(e['QualityId']),
        element: _facet(e['Element']),
        weapon: _facet(e['WeaponType']),
        iconUrl: encoreAssetUrl(e['RoleHeadIcon']),
      ),
];

/// Parses `/api/{lang}/weapon` (`weapons`).
List<GuideEntry> parseWeaponList(Object? json) => [
  for (final e in _list(json, 'weapons'))
    if (_int(e['Id']) > 0 && _str(e['Name']) != null)
      GuideEntry(
        kind: GuideKind.weapon,
        id: _int(e['Id']),
        name: _str(e['Name'])!,
        rarity: _int(e['QualityId']),
        weapon: _str(e['TypeName']) == null
            ? null
            : GuideFacet(_str(e['TypeName'])!, encoreAssetUrl(e['TypeIcon'])),
        iconUrl: encoreAssetUrl(e['Icon']),
      ),
];

/// Parses `/api/{lang}/echo` (`Echo`).
List<GuideEntry> parseEchoList(Object? json) => [
  for (final e in _list(json, 'Echo'))
    if (_int(e['Id']) > 0 && _str(e['Name']) != null)
      GuideEntry(
        kind: GuideKind.echo,
        id: _int(e['Id']),
        name: _str(e['Name'])!,
        rarity: _int(e['Rarity']),
        element: _facet(e['Element']),
        type: _str(e['Type']),
        iconUrl: encoreAssetUrl(e['IconMiddle'] ?? e['Icon']),
        sets: [for (final g in _list(e, 'FetterGroups')) ?_facet(g)],
      ),
];

List<GuideEntry> parseGuideList(GuideKind kind, Object? json) => switch (kind) {
  GuideKind.resonator => parseResonatorList(json),
  GuideKind.weapon => parseWeaponList(json),
  GuideKind.echo => parseEchoList(json),
};

/// One sonata effect with its piece-count tiers.
class EchoSet {
  const EchoSet(this.name, this.effects, {this.iconUrl});

  final String name;
  final String? iconUrl;

  /// (pieces, description), in ascending piece order.
  final List<(int, String)> effects;
}

/// Reference info for an echo.
class EchoInfo {
  const EchoInfo({
    required this.id,
    required this.name,
    this.elementName,
    this.className,
    this.family,
    this.place,
    this.mainStats,
    this.skill,
    this.cooldown,
    this.imageUrl,
    this.elementIconUrl,
    this.gallery = const [],
    this.sets = const [],
  });

  final int id;
  final String name;
  final String? elementName;

  /// "Common Class", "Overlord Class", ...
  final String? className;

  /// "Mutant Fauna", ...
  final String? family;
  final String? place;

  /// Main stats an echo of this kind can roll.
  final String? mainStats;
  final String? skill;

  /// Echo skill cooldown in seconds.
  final num? cooldown;
  final String? imageUrl;
  final String? elementIconUrl;

  /// The echo's art and its skill icon.
  final List<ItemGallery> gallery;
  final List<EchoSet> sets;
}

/// Parses `/api/{lang}/echo/{id}`. Null when it has no name (encore returns
/// empty text for languages it hasn't translated an echo into).
EchoInfo? parseEcho(Map<String, dynamic> json) {
  final handbook = json['Handbook'] is Map<String, dynamic>
      ? json['Handbook'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final skill = json['Skill'] is Map<String, dynamic>
      ? json['Skill'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final name = _str(json['MonsterName']) ?? _str(handbook['Name']);
  if (name == null) return null;

  final details = json['FetterDetails'] is Map
      ? json['FetterDetails'] as Map
      : const {};
  final sets = <EchoSet>[];
  for (final g in _list(json, 'FetterGroupDetails')) {
    final group = g['Group'];
    final fetter = g['Fetter'];
    // `FetterDetails` is keyed by the sonata (group) name; the nested fetter
    // has its own, unrelated name.
    final setName =
        (group is Map ? _str(group['FetterGroupName']) : null) ??
        (fetter is Map ? _str(fetter['Name']) : null);
    final detail = setName == null ? null : details[setName];
    if (setName == null || detail is! Map) continue;
    final texts = detail['EffectDescriptions'];
    final keys = detail['EffectKeys'];
    if (texts is! List) continue;
    sets.add(
      EchoSet(
        setName,
        [
          for (var i = 0; i < texts.length; i++)
            if (texts[i] is String && (texts[i] as String).trim().isNotEmpty)
              (
                keys is List && i < keys.length ? _int(keys[i]) : i + 1,
                stripHtml(texts[i] as String),
              ),
        ],
        iconUrl: group is Map
            ? encoreAssetUrl(group['FetterElementPath'])
            : null,
      ),
    );
  }

  String? clean(Object? v) {
    final s = _str(v);
    return s == null ? null : stripHtml(s);
  }

  final rawSkill =
      clean(skill['DescriptionEx']) ?? clean(skill['SimplyDescription']);
  return EchoInfo(
    id: _int(json['MonsterId']),
    name: name,
    elementName: _name(json['Element']),
    className: _str(handbook['Intensity']),
    family: _str(handbook['TypeDescrtption']),
    place: _str(handbook['Place']),
    mainStats: clean(handbook['Descrtption1']),
    skill: rawSkill ?? clean(handbook['Descrtption2']),
    cooldown: skill['SkillCD'] is num ? skill['SkillCD'] as num : null,
    imageUrl:
        encoreAssetUrl(json['IconBig']) ??
        encoreAssetUrl(json['IconMiddle']) ??
        encoreAssetUrl(json['Icon']),
    elementIconUrl: encoreAssetUrl(
      json['ElementIcon'] ??
          (json['Element'] is Map ? json['Element']['Icon'] : null),
    ),
    gallery: [
      for (final g in [
        ItemGallery(ItemGalleryKind.icon, [
          ?encoreAssetUrl(json['IconBig']),
          if (encoreAssetUrl(json['Icon']) case final u?
              when u != encoreAssetUrl(json['IconBig']))
            u,
        ]),
        ItemGallery(ItemGalleryKind.skill, [
          ?encoreAssetUrl(skill['BattleViewIcon']),
        ]),
      ])
        if (g.urls.isNotEmpty) g,
    ],
    sets: sets,
  );
}
