import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../info/data/encore_info_service.dart';

/// Resonator and weapon names by game id in one language, from the encore.moe
/// list endpoints. Responses are cached on disk by the cache manager, so a
/// language only needs the network once in a while.
///
/// Pull records are always stored in English (see `ConveneApi`); this is what
/// lets the app show them in another language without touching stored data.
class ItemNameService {
  ItemNameService({Future<String> Function(String url)? loadJson})
    : _loadJson = loadJson ?? _loadViaCache;

  final Future<String> Function(String url) _loadJson;

  static Future<String> _loadViaCache(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file.readAsString();
  }

  /// Names in [lang]. Items the API has no translation for (it sends an empty
  /// name) are left out, so callers fall back to the stored English name.
  Future<Map<int, String>> namesFor(String lang) async {
    final lists = await Future.wait([
      _names('character', 'roleList', lang),
      _names('weapon', 'weapons', lang),
    ]);
    return {...lists[0], ...lists[1]};
  }

  Future<Map<int, String>> _names(
    String segment,
    String listKey,
    String lang,
  ) async {
    final url = '${EncoreInfoService.apiBase}/$lang/$segment';
    final json = jsonDecode(await _loadJson(url));
    final list = json is Map<String, dynamic> ? json[listKey] : null;
    if (list is! List) return const {};
    return {
      for (final item in list)
        if (item is Map<String, dynamic> &&
            item['Id'] is int &&
            item['Name'] is String &&
            (item['Name'] as String).trim().isNotEmpty)
          item['Id'] as int: (item['Name'] as String).trim(),
    };
  }
}
