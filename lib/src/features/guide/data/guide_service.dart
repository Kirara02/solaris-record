import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../info/data/encore_info_service.dart';
import '../../info/domain/encore_links.dart';
import '../domain/guide_entry.dart';

/// Loads the full resonator, weapon and echo lists, and echo details, from the
/// community encore.moe API. Responses are cached on disk, so the guide works
/// offline once it has been opened. Unofficial endpoint: every failure is an
/// exception the UI turns into a retry state.
class GuideService {
  GuideService({Future<String> Function(String url)? loadJson})
    : _loadJson = loadJson ?? _loadViaCache;

  final Future<String> Function(String url) _loadJson;

  static Future<String> _loadViaCache(String url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    return file.readAsString();
  }

  static String listUrl(GuideKind kind, String lang) {
    final segment = switch (kind) {
      GuideKind.resonator => 'character',
      GuideKind.weapon => 'weapon',
      GuideKind.echo => 'echo',
    };
    return '${EncoreInfoService.apiBase}/$lang/$segment';
  }

  static String echoUrl(int id, String lang) =>
      '${EncoreInfoService.apiBase}/$lang/echo/$id';

  static String _language(String lang) =>
      encoreLanguages.contains(lang) ? lang : 'en';

  /// Every entry of [kind] in [lang], falling back to English when the API
  /// has nothing translated.
  Future<List<GuideEntry>> list(GuideKind kind, String lang) async {
    final wanted = _language(lang);
    final entries = await _list(kind, wanted);
    if (entries.isNotEmpty || wanted == 'en') return entries;
    return _list(kind, 'en');
  }

  Future<List<GuideEntry>> _list(GuideKind kind, String lang) async {
    final body = await _loadJson(listUrl(kind, lang));
    return parseGuideList(kind, jsonDecode(body));
  }

  /// Details of one echo in [lang], falling back to English.
  Future<EchoInfo?> echo(int id, String lang) async {
    final wanted = _language(lang);
    final info = await _echoIn(id, wanted);
    if (info != null || wanted == 'en') return info;
    return _echoIn(id, 'en');
  }

  Future<EchoInfo?> _echoIn(int id, String lang) async {
    final json = jsonDecode(await _loadJson(echoUrl(id, lang)));
    return json is Map<String, dynamic> ? parseEcho(json) : null;
  }
}
