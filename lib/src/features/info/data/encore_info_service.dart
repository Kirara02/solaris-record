import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../domain/encore_links.dart';
import '../domain/item_info.dart';
import '../domain/item_kind.dart';

/// Loads reference info (not pull data) for a resonator or weapon from the
/// community encore.moe API. Responses are cached on disk, so opened items
/// work offline afterwards. Unofficial endpoint: every failure is an
/// exception the UI turns into a retry state.
class EncoreInfoService {
  EncoreInfoService({Future<String> Function(String url)? loadJson})
    : _loadJson = loadJson ?? _loadViaCache;

  static const apiBase = 'https://api-v2.encore.moe/api';

  final Future<String> Function(String url) _loadJson;

  static Future<String> _loadViaCache(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file.readAsString();
  }

  static String urlFor(ItemKind kind, int id, String lang) {
    final segment = kind == ItemKind.resonator ? 'character' : 'weapon';
    return '$apiBase/$lang/$segment/$id';
  }

  /// Info for the item in [lang], falling back to English when the API has no
  /// translated name. Null when the id isn't a resonator or weapon.
  Future<ItemInfo?> fetch(
    int resourceId,
    String resourceType,
    String lang,
  ) async {
    final kind = itemKindFor(resourceId, resourceType);
    if (kind == null || resourceId <= 0) return null;
    final wanted = encoreLanguages.contains(lang) ? lang : 'en';
    final info = await _fetchIn(kind, resourceId, wanted);
    if (info != null || wanted == 'en') return info;
    return _fetchIn(kind, resourceId, 'en');
  }

  Future<ItemInfo?> _fetchIn(ItemKind kind, int id, String lang) async {
    final body = await _loadJson(urlFor(kind, id, lang));
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    return kind == ItemKind.resonator
        ? parseCharacter(json)
        : parseWeapon(json);
  }
}
