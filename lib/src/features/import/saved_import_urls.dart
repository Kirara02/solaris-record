import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/preferences.dart';

part 'saved_import_urls.g.dart';

/// Last convene URL that worked, per UID, so the next update needs no paste.
/// The URL carries the record token, so it is dropped as soon as the server
/// rejects it and when its account is deleted.
class SavedImportUrls {
  SavedImportUrls(this._prefs);

  static const _prefix = 'import_url_';

  final SharedPreferences _prefs;

  String? get(String uid) => _prefs.getString('$_prefix$uid');

  Future<void> save(String uid, String url) =>
      _prefs.setString('$_prefix$uid', url.trim());

  Future<void> remove(String uid) => _prefs.remove('$_prefix$uid');

  Future<void> clear() async {
    for (final key in _prefs.getKeys().where((k) => k.startsWith(_prefix))) {
      await _prefs.remove(key);
    }
  }
}

@Riverpod(keepAlive: true)
SavedImportUrls savedImportUrls(Ref ref) =>
    SavedImportUrls(ref.watch(sharedPreferencesProvider));
