import '../../info/domain/item_info.dart';

/// What the guide lists.
enum GuideKind { resonator, weapon, echo }

/// A named attribute with its game icon (an element, a weapon class or a
/// sonata effect). Two facets are the same when their names match.
class GuideFacet {
  const GuideFacet(this.name, [this.iconUrl, this.id]);

  final String name;
  final String? iconUrl;

  /// The API's id of the facet, where it has one (sonata effects); it gives
  /// the game's own order and takes no part in equality.
  final int? id;

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
  return GuideFacet(
    n,
    v is Map ? encoreAssetUrl(v['Icon']) : null,
    v is Map && v['Id'] is num ? (v['Id'] as num).toInt() : null,
  );
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

/// Parses `/api/{lang}/echo` (`Echo`). The API also lists 92 entries with a
/// `PhantomType` other than 1 (ids such as 6020003): unfinished copies of real
/// echoes carrying another echo's skill text. encore.moe leaves them out of
/// its own list too, so they are skipped here.
List<GuideEntry> parseEchoList(Object? json) => [
  for (final e in _list(json, 'Echo'))
    if (_int(e['Id']) > 0 &&
        _str(e['Name']) != null &&
        (e['PhantomType'] == null || e['PhantomType'] == 1))
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

/// The echoes of one sonata effect.
class EchoGroup {
  const EchoGroup(this.sonata, this.entries);

  final GuideFacet sonata;
  final List<GuideEntry> entries;
}

/// Groups [echoes] by sonata effect, in the game's order. An echo with
/// several sonata effects is listed under each of them. [only], when not
/// empty, keeps just those sonata effects.
List<EchoGroup> groupEchoesBySonata(
  Iterable<GuideEntry> echoes, {
  Set<GuideFacet> only = const {},
}) {
  final bySonata = <GuideFacet, List<GuideEntry>>{};
  for (final e in echoes) {
    for (final sonata in e.sets) {
      if (only.isNotEmpty && !only.contains(sonata)) continue;
      bySonata.putIfAbsent(sonata, () => []).add(e);
    }
  }
  final groups = [
    for (final entry in bySonata.entries) EchoGroup(entry.key, entry.value),
  ];
  int order(EchoGroup g) => g.sonata.id ?? 1 << 30;
  groups.sort((a, b) {
    final byId = order(a).compareTo(order(b));
    return byId != 0 ? byId : a.sonata.name.compareTo(b.sonata.name);
  });
  return groups;
}

/// One sonata effect with its piece-count tiers.
class EchoSet {
  const EchoSet(this.name, this.effects, {this.iconUrl});

  final String name;
  final String? iconUrl;

  /// (pieces, description), in ascending piece order.
  final List<(int, String)> effects;
}

/// One hit of an echo skill, a row of encore.moe's "Damage info" table.
class EchoHit {
  const EchoHit({
    required this.number,
    this.property,
    this.type,
    this.damageType,
    this.rates = const [],
    this.resonanceEnergy,
    this.concertoEnergy,
    this.hardness,
    this.toughness,
    this.offTune,
  });

  final int number;

  /// What the rate scales with ("ATK", "HP", "DEF").
  final String? property;

  /// "Echo Skill".
  final String? type;

  /// "Damage" or "Heal".
  final String? damageType;

  /// The rate at skill level 1, 2, ... as the API writes it ("125.1%").
  final List<String> rates;
  final num? resonanceEnergy;
  final num? concertoEnergy;
  final num? hardness;
  final num? toughness;
  final num? offTune;

  /// The rate at [level] (1-based); the last one when there are fewer levels,
  /// so a hit that does not scale shows its single value at every level.
  String? rateAt(int level) =>
      rates.isEmpty ? null : rates[(level - 1).clamp(0, rates.length - 1)];
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
    this.skillIconUrl,
    this.hits = const [],
    this.skillLevels = const [],
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

  /// Icon of the echo skill.
  final String? skillIconUrl;

  /// The skill's hits, with their rates per skill level.
  final List<EchoHit> hits;

  /// The numbers the skill text quotes at each skill level (level 1 first):
  /// `["125.10%", "125.10%", "166.80%", "4.00%", "4.00%", "15", "20"]`.
  final List<List<String>> skillLevels;

  /// Highest skill level there is data for.
  int get maxSkillLevel => hits.fold(
    skillLevels.isEmpty ? 1 : skillLevels.length,
    (m, h) => h.rates.length > m ? h.rates.length : m,
  );

  /// The skill text for [level]. The text quotes the numbers of one level
  /// (the highest); they are swapped for those of [level], in the order the
  /// API lists them. When the numbers cannot be found in that order the text
  /// is returned as it is rather than guessed at.
  String? skillTextAt(int level) {
    final text = skill;
    if (text == null || skillLevels.length < 2) return text;
    final target = skillLevels[(level - 1).clamp(0, skillLevels.length - 1)];
    // The text normally quotes the last level; try the others if it does not.
    for (var source = skillLevels.length - 1; source >= 0; source--) {
      final params = skillLevels[source];
      if (params.length != target.length) continue;
      final spans = _locate(text, params);
      if (spans == null) continue;
      final out = StringBuffer();
      var at = 0;
      for (final (i, span) in spans.indexed) {
        if (span == null) continue;
        out
          ..write(text.substring(at, span.$1))
          ..write(target[i]);
        at = span.$2;
      }
      return (out..write(text.substring(at))).toString();
    }
    return text;
  }

  /// Where each of [params] stands in [text], searching left to right; null
  /// when one cannot be found (an empty parameter is skipped).
  static List<(int, int)?>? _locate(String text, List<String> params) {
    final spans = <(int, int)?>[];
    var cursor = 0;
    for (final p in params) {
      if (p.isEmpty) {
        spans.add(null);
        continue;
      }
      // Not part of a longer number (15 inside 115 or 15.5).
      final match = RegExp('(?<![\\d.])${RegExp.escape(p)}(?!\\d|\\.\\d)')
          .firstMatch(text.substring(cursor));
      if (match == null) return null;
      spans.add((cursor + match.start, cursor + match.end));
      cursor += match.end;
    }
    return spans;
  }

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
    skillIconUrl: encoreAssetUrl(skill['BattleViewIcon']),
    hits: _parseHits(skill['DamageList']),
    skillLevels: _parseSkillLevels(skill['LevelDescStrArray']),
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

num? _first(Object? v) =>
    v is List && v.isNotEmpty && v.first is num ? v.first as num : null;

List<EchoHit> _parseHits(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final (i, h) in raw.indexed)
      if (h is Map)
        EchoHit(
          number: h['EntryNumber'] is num
              ? (h['EntryNumber'] as num).toInt()
              : i + 1,
          property: _str(h['PropertyName']),
          type: _str(h['Type']),
          damageType: _str(h['DmgType']),
          rates: [
            if (h['RateLv'] is List)
              for (final r in h['RateLv'] as List)
                if (r is String && r.trim().isNotEmpty) r.trim(),
          ],
          resonanceEnergy: _first(h['Energy']),
          concertoEnergy: _first(h['ElementPower']),
          hardness: _first(h['HardnessLv']),
          toughness: _first(h['ToughLv']),
          offTune: _first(h['WeaknessLvl']),
        ),
  ];
}

List<List<String>> _parseSkillLevels(Object? raw) => [
  if (raw is List)
    for (final level in raw)
      if (level is Map && level['ArrayString'] is List)
        [
          for (final p in level['ArrayString'] as List)
            if (p is String) p.trim() else '',
        ],
];
