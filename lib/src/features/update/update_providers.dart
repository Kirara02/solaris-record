import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/preferences.dart';
import 'data/update_service.dart';

part 'update_providers.g.dart';

@Riverpod(keepAlive: true)
UpdateService updateService(Ref ref) => UpdateService(
  Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

/// Whether the app looks for a new version when it starts. On by default.
@Riverpod(keepAlive: true)
class AutoUpdateCheck extends _$AutoUpdateCheck {
  static const _key = 'auto_update_check';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_key, value);
  }
}

/// A version the user chose to skip: it isn't offered again by the automatic
/// check, only by a manual one.
@Riverpod(keepAlive: true)
class SkippedUpdateVersion extends _$SkippedUpdateVersion {
  static const _key = 'skipped_update_version';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> set(String? version) async {
    state = version;
    final prefs = ref.read(sharedPreferencesProvider);
    if (version == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, version);
    }
  }
}
