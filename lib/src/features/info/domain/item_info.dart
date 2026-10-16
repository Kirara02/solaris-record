import 'item_kind.dart';

class ItemStat {
  const ItemStat(this.name, this.value, {this.byLevel = const {}});

  final String name;
  final String value;

  /// Display value per whole level (1..90), as formatted by the API ("122.25",
  /// "9.60%"). Empty for stats that don't scale with level.
  final Map<int, String> byLevel;

  /// Value at [level], or the base [value] when the level isn't known.
  String valueAt(int level) => byLevel[level] ?? value;
}

class ItemSkill {
  const ItemSkill(this.type, this.name);

  final String type;
  final String name;
}

enum ItemGalleryKind { icon, outfit, convene }

/// Images of one kind for an item (the icon, outfit art, or convene art).
class ItemGallery {
  const ItemGallery(this.kind, this.urls);

  final ItemGalleryKind kind;
  final List<String> urls;
}

/// Reference info for a resonator or weapon (not tied to any pull).
class ItemInfo {
  const ItemInfo({
    required this.kind,
    required this.name,
    required this.rarity,
    this.typeName,
    this.elementName,
    this.imageUrl,
    this.description,
    this.tags = const [],
    this.skills = const [],
    this.effectName,
    this.effectDescription,
    this.stats = const [],
    this.gallery = const [],
  });

  final ItemKind kind;
  final String name;
  final int rarity;

  /// Weapon class ("Rectifier", "Broadblade", ...).
  final String? typeName;
  final String? elementName;
  final String? imageUrl;
  final String? description;
  final List<String> tags;
  final List<ItemSkill> skills;
  final String? effectName;
  final String? effectDescription;
  final List<ItemStat> stats;

  /// Non-empty image groups, in display order.
  final List<ItemGallery> gallery;
}

const _assetBase = 'https://api-v2.encore.moe/resource/Data';

/// Turns an Unreal asset path (`/Game/.../T_X.T_X`) into the matching `.webp`
/// URL; full URLs pass through. Null for empty input.
String? encoreAssetUrl(Object? raw) {
  if (raw is! String || raw.isEmpty) return null;
  if (raw.startsWith('http')) return raw;
  final slash = raw.lastIndexOf('/');
  final dot = raw.indexOf('.', slash + 1);
  final path = dot < 0 ? raw : raw.substring(0, dot);
  return '$_assetBase$path.webp';
}

/// Plain text from the HTML-ish strings encore returns (spans, `<br>`, and
/// stray `<size=..>` tags).
String stripHtml(String html) => html
    .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll(RegExp(r'[ \t]+'), ' ')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

String? _text(Object? v) {
  if (v is Map) v = v['Content'];
  if (v is! String) return null;
  final t = stripHtml(v);
  return t.isEmpty ? null : t;
}

String _number(num v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

/// Only plain-number stats (HP, ATK, DEF): the API stores ratios in mixed
/// units (a 5% crit rate is `500`), so those are left out rather than shown
/// wrong. They are told apart by icon, because the stat names are translated
/// (`攻撃力`, `ANG`, ...) while the icon file stays the same in every language.
const _plainStatIcons = [
  'propertygreenlife',
  'propertyredattack',
  'propertygreendefense',
];

bool _isPlainStat(Map<dynamic, dynamic> p) {
  final icon = '${p['Icon']}'.toLowerCase();
  return _plainStatIcons.any(icon.contains);
}

/// Parses `/api/{lang}/character/{id}`. Null when it has no name (encore
/// returns empty text for languages it hasn't translated an item into).
ItemInfo? parseCharacter(Map<String, dynamic> json) {
  final name = _text(json['Name']) ?? _text(json['NickName']);
  if (name == null) return null;
  return ItemInfo(
    kind: ItemKind.resonator,
    name: name,
    rarity: (json['QualityId'] as num?)?.toInt() ?? 0,
    typeName: json['WeaponTypeName'] as String?,
    elementName: json['ElementName'] as String?,
    imageUrl:
        encoreAssetUrl(json['FormationRoleCard']) ??
        encoreAssetUrl(json['Card']),
    description: _text(json['Introduction']),
    tags: [
      for (final tag in (json['Tags'] as List?) ?? const [])
        if (tag is Map && tag['TagName'] is String) tag['TagName'] as String,
    ],
    skills: [
      for (final s in (json['Skills'] as List?) ?? const [])
        if (s is Map && s['SkillName'] is String && s['SkillType'] is String)
          ItemSkill(s['SkillType'] as String, s['SkillName'] as String),
    ],
    stats: [
      for (final p in (json['Properties'] as List?) ?? const [])
        if (p is Map && _isPlainStat(p)) ?_characterStat(p),
    ],
    gallery: _characterGallery(json),
  );
}

/// Distinct asset URLs from [raw] (paths or URLs), first occurrence kept.
List<String> _urls(Iterable<Object?> raw) {
  final seen = <String>{};
  return [
    for (final r in raw)
      if (encoreAssetUrl(r) case final url? when seen.add(url)) url,
  ];
}

/// Icon, outfit and convene art of a resonator. Outfits cover the base look
/// and every skin; convene art is what the pull screens show.
List<ItemGallery> _characterGallery(Map<String, dynamic> json) {
  final skins = [
    for (final s in (json['Skins'] as List?) ?? const [])
      if (s is Map) s,
  ];
  final groups = [
    ItemGallery(ItemGalleryKind.icon, _urls([json['RoleHeadIconLarge']])),
    ItemGallery(
      ItemGalleryKind.outfit,
      _urls([
        json['FormationRoleCard'],
        json['RoleStand'],
        json['RolePortrait'],
        for (final s in skins) ...[
          s['PreviewRoleCard'],
          s['FormationRoleCard'],
          s['RoleStand'],
        ],
      ]),
    ),
    ItemGallery(
      ItemGalleryKind.convene,
      _urls([
        for (final g in (json['GachaViewInfo'] as List?) ?? const [])
          if (g is Map) g['UnderBgTexturePath'],
      ]),
    ),
  ];
  return [
    for (final g in groups)
      if (g.urls.isNotEmpty) g,
  ];
}

/// A resonator's HP / ATK / DEF with its value at every level.
///
/// Rows are `{level, value}`; an ascension level appears twice and the first
/// row (before ascension) is kept, as for weapons.
ItemStat? _characterStat(Map<dynamic, dynamic> p) {
  final name = p['Name'] as String;
  final byLevel = <int, String>{};
  for (final g in (p['GrowthValues'] as List?) ?? const []) {
    if (g is! Map || g['value'] is! num) continue;
    final level = g['level'];
    if (level is int) {
      byLevel.putIfAbsent(level, () => (g['value'] as num).round().toString());
    }
  }
  final base = p['BaseValue'];
  if (byLevel.isEmpty) {
    return base is num ? ItemStat(name, _number(base)) : null;
  }
  return ItemStat(
    name,
    byLevel[weaponMinLevel] ?? byLevel.values.first,
    byLevel: byLevel,
  );
}

/// Parses `/api/{lang}/weapon/{id}`.
ItemInfo? parseWeapon(Map<String, dynamic> json) {
  final name = _text(json['WeaponName']);
  if (name == null) return null;
  return ItemInfo(
    kind: ItemKind.weapon,
    name: name,
    rarity: (json['QualityId'] as num?)?.toInt() ?? 0,
    typeName: json['WeaponTypeName'] as String?,
    imageUrl:
        encoreAssetUrl(json['IconBig']) ?? encoreAssetUrl(json['IconMiddle']),
    description:
        _text(json['BgDescription']) ?? _text(json['AttributesDescription']),
    effectName: _text(json['ResonName']),
    effectDescription: _text(json['Desc']),
    stats: [
      for (final p in (json['Properties'] as List?) ?? const [])
        if (p is Map) ?_weaponStat(p),
    ],
    gallery: [
      ItemGallery(ItemGalleryKind.icon, _urls([json['IconBig']])),
    ].where((g) => g.urls.isNotEmpty).toList(),
  );
}

/// A weapon's primary or secondary stat with its value at every level.
///
/// The API lists each ascension level twice (`20` before, `20.5` after);
/// only the whole levels are kept, matching what the level slider shows.
ItemStat? _weaponStat(Map<dynamic, dynamic> p) {
  final name = p['Name'];
  if (name is! String) return null;
  final byLevel = <int, String>{};
  for (final g in (p['GrowthValues'] as List?) ?? const []) {
    if (g is! Map || g['Value'] is! String) continue;
    final level = g['Level'];
    if (level is int) byLevel[level] = g['Value'] as String;
  }
  if (byLevel.isEmpty) {
    // No per-level table: keep the plain base number, as for resonators.
    final base = p['BaseValue'];
    return _isPlainStat(p) && base is num && base >= 1
        ? ItemStat(name, _number(base))
        : null;
  }
  return ItemStat(
    name,
    byLevel[weaponMinLevel] ?? byLevel.values.first,
    byLevel: byLevel,
  );
}

/// Level range of the stat slider (resonators and weapons alike).
const weaponMinLevel = 1;
const weaponMaxLevel = 90;
