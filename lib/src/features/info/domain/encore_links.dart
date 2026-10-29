import 'item_kind.dart';

/// Languages encore.moe serves (anything else falls back to English).
const encoreLanguages = {
  'en',
  'zh-Hans',
  'zh-Hant',
  'ja',
  'ko',
  'de',
  'es',
  'fr',
  'id',
  'pt',
  'ru',
  'th',
  'vi',
};

/// The encore.moe web page of a resonator or weapon, in [lang].
String encoreItemUrl(ItemKind kind, int resourceId, String lang) {
  final segment = kind == ItemKind.resonator ? 'character' : 'weapon';
  final language = encoreLanguages.contains(lang) ? lang : 'en';
  return 'https://encore.moe/$segment/$resourceId?lang=$language';
}

/// [encoreItemUrl] for a raw record, or null when it isn't a resonator or
/// weapon (nothing to link to).
String? encoreItemUrlFor(int resourceId, String resourceType, String lang) {
  final kind = itemKindFor(resourceId, resourceType);
  if (kind == null || resourceId <= 0) return null;
  return encoreItemUrl(kind, resourceId, lang);
}

/// The encore.moe web page of an echo, in [lang].
String encoreEchoUrl(int id, String lang) {
  final language = encoreLanguages.contains(lang) ? lang : 'en';
  return 'https://encore.moe/echo/$id?lang=$language';
}

/// The encore.moe web page of an enemy, in [lang].
String encoreMonsterUrl(int id, String lang) {
  final language = encoreLanguages.contains(lang) ? lang : 'en';
  return 'https://encore.moe/monster/$id?lang=$language';
}
