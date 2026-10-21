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
  const ItemSkill(this.type, this.name, {this.iconUrl, this.description});

  final String type;
  final String name;
  final String? iconUrl;
  final String? description;
}

/// One resonance chain node (S1 to S6).
class ItemChainNode {
  const ItemChainNode(this.name, {this.description, this.iconUrl});

  final String name;
  final String? description;
  final String? iconUrl;
}

/// Who a resonator is: birthday, region, affiliation and voice actors.
class ItemProfile {
  const ItemProfile({
    this.birthday,
    this.country,
    this.influence,
    this.voiceActors = const {},
  });

  final String? birthday;
  final String? country;
  final String? influence;

  /// Voice actor per language (`en`, `ja`, `zh`, `ko`).
  final Map<String, String> voiceActors;

  bool get isEmpty =>
      birthday == null &&
      country == null &&
      influence == null &&
      voiceActors.isEmpty;
}

enum ItemGalleryKind { icon, outfit, convene, skill }

/// Images of one kind for an item (the icon, outfit art, or convene art).
class ItemGallery {
  const ItemGallery(this.kind, this.urls, {this.captions = const []});

  final ItemGalleryKind kind;
  final List<String> urls;

  /// Optional label per image (the outfit's name), parallel to [urls].
  final List<String?> captions;

  String? captionAt(int i) => i < captions.length ? captions[i] : null;
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
    this.chain = const [],
    this.profile,
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

  /// Resonance chain, S1 first (resonators only).
  final List<ItemChainNode> chain;

  final ItemProfile? profile;
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
      for (final tag in _list(json['Tags']))
        if (tag is Map && tag['TagName'] is String) tag['TagName'] as String,
    ],
    skills: [
      for (final s in _list(json['Skills']))
        if (s is Map && s['SkillName'] is String && s['SkillType'] is String)
          ItemSkill(
            s['SkillType'] as String,
            s['SkillName'] as String,
            iconUrl: encoreAssetUrl(s['Icon']),
            description: _text(s['SkillDescribe']),
          ),
    ],
    stats: [
      for (final p in _list(json['Properties']))
        if (p is Map && _isPlainStat(p)) ?_characterStat(p),
    ],
    gallery: _characterGallery(json),
    chain: [
      for (final n in _list(json['ResonantChain']))
        if (n is Map && _text(n['NodeName']) != null)
          ItemChainNode(
            _text(n['NodeName'])!,
            description: _text(n['AttributesDescription']),
            iconUrl: encoreAssetUrl(n['NodeIcon']),
          ),
    ],
    profile: _profile(json['favorRole']),
  );
}

ItemProfile? _profile(Object? raw) {
  if (raw is! Map) return null;
  final cv = {
    'en': _text(raw['CVNameEn']),
    'ja': _text(raw['CVNameJp']),
    'zh': _text(raw['CVNameCn']),
    'ko': _text(raw['CVNameKo']),
  };
  final profile = ItemProfile(
    birthday: _text(raw['Birthday']),
    country: _text(raw['Country']),
    influence: _text(raw['Influence']),
    voiceActors: {
      for (final e in cv.entries)
        if (e.value != null) e.key: e.value!,
    },
  );
  return profile.isEmpty ? null : profile;
}

/// Distinct asset URLs from [raw] (paths or URLs), first occurrence kept.
List<String> _urls(Iterable<Object?> raw) {
  final seen = <String>{};
  return [
    for (final r in raw)
      if (encoreAssetUrl(r) case final url? when seen.add(url)) url,
  ];
}

/// An [ItemGallery] from (asset, caption) pairs; repeated URLs keep their
/// first caption.
ItemGallery _captioned(
  ItemGalleryKind kind,
  Iterable<(Object?, String?)> items,
) {
  final seen = <String>{};
  final urls = <String>[];
  final captions = <String?>[];
  for (final (raw, caption) in items) {
    final url = encoreAssetUrl(raw);
    if (url != null && seen.add(url)) {
      urls.add(url);
      captions.add(caption);
    }
  }
  return ItemGallery(kind, urls, captions: captions);
}

/// Icon, outfit and convene art of a resonator. Outfits cover the base look
/// and every skin, each captioned with its name; convene art is what the pull
/// screens show.
List<ItemGallery> _characterGallery(Map<String, dynamic> json) {
  final skins = [
    for (final s in _list(json['Skins']))
      if (s is Map) s,
  ];
  // The base outfit's name is the 3D model that carries the default skin id.
  String? baseName;
  for (final m in _list(json['Model3D'])) {
    if (m is Map && m['Id'] == json['SkinId']) baseName = _text(m['Name']);
  }
  final groups = [
    ItemGallery(ItemGalleryKind.icon, _urls([json['RoleHeadIconLarge']])),
    _captioned(ItemGalleryKind.outfit, [
      (json['FormationRoleCard'], baseName),
      (json['RoleStand'], baseName),
      (json['RolePortrait'], baseName),
      for (final s in skins) ...[
        (s['PreviewRoleCard'], _text(s['Name'])),
        (s['FormationRoleCard'], _text(s['Name'])),
        (s['RoleStand'], _text(s['Name'])),
      ],
    ]),
    ItemGallery(
      ItemGalleryKind.convene,
      _urls([
        for (final g in _list(json['GachaViewInfo']))
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
  for (final g in _list(p['GrowthValues'])) {
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
      for (final p in _list(json['Properties']))
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
  for (final g in _list(p['GrowthValues'])) {
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

/// A list field read leniently: a list as is, a map as its values, else empty.
List<dynamic> _list(Object? v) => switch (v) {
  List() => v,
  Map() => v.values.toList(),
  _ => const [],
};
