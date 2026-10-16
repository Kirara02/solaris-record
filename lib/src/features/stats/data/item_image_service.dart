import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../info/domain/item_kind.dart';

/// Resolves icon URLs for convene items. Resonators come from the official
/// guide server (needs a lookup); weapon icons live at a URL derived from the
/// resource id. Both hosts are unofficial for third-party use, so every
/// failure resolves to `null` and the UI falls back to a placeholder.
class ItemImageService {
  ItemImageService(this._dio, this._prefs);

  static const guideEndpoint =
      'https://guide-server.aki-game.net/introduction/list';
  static const weaponIconBase =
      'https://api-v2.encore.moe/resource/Data/Game/Aki/UI/UIResources/'
      'Common/Image/IconWeapon/T_IconWeapon';
  static const _prefix = 'icon_url_';

  final Dio _dio;
  final SharedPreferences _prefs;

  static String weaponIconUrl(int resourceId) =>
      '$weaponIconBase${resourceId}_UI.webp';

  Future<String?> urlFor(int resourceId, String resourceType) async {
    if (resourceId <= 0) return null;
    switch (itemKindFor(resourceId, resourceType)) {
      case ItemKind.weapon:
        return weaponIconUrl(resourceId);
      case ItemKind.resonator:
        return _resonatorUrl(resourceId);
      case null:
        return null;
    }
  }

  Future<String?> _resonatorUrl(int id) async {
    final cached = _prefs.getString('$_prefix$id');
    if (cached != null) return cached;
    try {
      final response = await _dio.get<dynamic>(
        guideEndpoint,
        queryParameters: {'roleGbId': id},
        options: Options(headers: {'X-Language': 'en'}),
      );
      final body = response.data;
      if (body is! Map || body['code'] != 200) return null;
      final data = body['data'];
      if (data is! List || data.isEmpty) return null;
      final role = (data.first as Map)['role'];
      final url = role is Map ? role['cardPictureUrl'] : null;
      if (url is! String || url.isEmpty) return null;
      await _prefs.setString('$_prefix$id', url);
      return url;
    } on Object {
      // Not cached, so a later attempt can succeed.
      return null;
    }
  }

  /// Drops stored resonator URLs (used by "clear image cache").
  Future<void> clearCachedUrls() async {
    for (final key in _prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await _prefs.remove(key);
    }
  }
}
