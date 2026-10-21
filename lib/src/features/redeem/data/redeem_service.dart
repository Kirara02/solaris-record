import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../update/data/update_service.dart';
import '../domain/redeem_code.dart';

final _log = Logger('redeem');

/// The codes and whether they came from the last saved copy (offline).
class RedeemFeed {
  const RedeemFeed(this.codes, {this.fromCache = false});

  final List<RedeemCode> codes;
  final bool fromCache;
}

/// Reads `redeem-codes.json` from the repository's default branch. The file is
/// public and static; nothing about the user or the device is sent. The last
/// good copy is kept in preferences so the list still shows offline.
class RedeemService {
  RedeemService(this._dio, this._prefs);

  final Dio _dio;
  final SharedPreferences _prefs;

  static const url =
      'https://raw.githubusercontent.com/$githubRepo/main/redeem-codes.json';
  static const _cacheKey = 'redeem_codes_cache';

  /// Fresh codes, or the saved copy when the file can't be reached. Throws
  /// only when there is neither.
  Future<RedeemFeed> fetch() async {
    // Debug builds read the bundled local file, so edits show up without
    // pushing to GitHub first.
    if (kDebugMode) {
      final body = await rootBundle.loadString('redeem-codes.json');
      return RedeemFeed(parseRedeemCodes(jsonDecode(body)));
    }
    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      final body = response.data;
      if (response.statusCode == 200 && body != null) {
        final codes = parseRedeemCodes(jsonDecode(body));
        await _prefs.setString(_cacheKey, body);
        return RedeemFeed(codes);
      }
      _log.info('No redeem codes file (${response.statusCode})');
    } on Object catch (e) {
      _log.info('Could not load redeem codes: $e');
    }
    final saved = _prefs.getString(_cacheKey);
    if (saved != null) {
      try {
        return RedeemFeed(parseRedeemCodes(jsonDecode(saved)), fromCache: true);
      } on Object catch (e) {
        _log.warning('Saved redeem codes are unreadable: $e');
      }
    }
    throw const RedeemUnavailable();
  }
}

class RedeemUnavailable implements Exception {
  const RedeemUnavailable();

  @override
  String toString() => 'Redeem codes are unavailable';
}
