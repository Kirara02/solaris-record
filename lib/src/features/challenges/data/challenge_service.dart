import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../info/data/encore_info_service.dart';
import '../../info/domain/encore_links.dart';
import '../domain/challenge_models.dart';
import '../domain/challenge_season.dart';
import '../domain/matrix_models.dart';
import '../domain/monster_info.dart';

/// Loads Tower of Adversity and Whimpering Wastes data from the community
/// encore.moe API. Responses are cached on disk for a day (new seasons show up
/// the next day) and an expired copy still serves when the network is down.
/// Unofficial endpoint: every failure is an exception the UI turns into a
/// retry state.
class ChallengeService {
  ChallengeService({Future<String> Function(String url)? loadJson})
    : _loadJson = loadJson ?? _loadViaCache;

  final Future<String> Function(String url) _loadJson;

  static final _cache = CacheManager(
    Config('encore_challenges', stalePeriod: const Duration(days: 1)),
  );

  static Future<String> _loadViaCache(String url) async {
    try {
      return await (await _cache.getSingleFile(url)).readAsString();
    } on Object {
      final old = await _cache.getFileFromCache(url);
      if (old == null) rethrow;
      return old.file.readAsString();
    }
  }

  static String _url(String mode, String lang, [int? id]) =>
      '${EncoreInfoService.apiBase}/'
      '${encoreLanguages.contains(lang) ? lang : 'en'}/$mode'
      '${id == null ? '' : '/$id'}';

  Future<List<ChallengeSeason>> towerSeasons(String lang) async =>
      parseSeasons(jsonDecode(await _loadJson(_url('toa', lang))));

  Future<TowerSeason> tower(int season, String lang) async =>
      parseTower(jsonDecode(await _loadJson(_url('toa', lang, season))));

  Future<List<ChallengeSeason>> whiwaSeasons(String lang) async =>
      parseSeasons(jsonDecode(await _loadJson(_url('whiwa', lang))));

  Future<WhiwaSeason> whiwa(int season, String lang) async =>
      parseWhiwa(jsonDecode(await _loadJson(_url('whiwa', lang, season))));

  Future<WhiwaBuffInfo?> buffInfo(int itemId, String lang) async =>
      parseBuffInfo(jsonDecode(await _loadJson(_url('item', lang, itemId))));

  Future<List<ChallengeSeason>> matrixSeasons(String lang) async =>
      parseMatrixSeasons(jsonDecode(await _loadJson(_url('dpmatrix', lang))));

  Future<MatrixSeason> matrix(int season, String lang) async =>
      parseMatrixSeason(
        jsonDecode(await _loadJson(_url('dpmatrix', lang, season))),
      );

  /// One enemy's page in [lang]; null when the answer is not a monster.
  Future<MonsterInfo?> monster(int id, String lang) async =>
      parseMonsterInfo(jsonDecode(await _loadJson(_url('monster', lang, id))));
}
