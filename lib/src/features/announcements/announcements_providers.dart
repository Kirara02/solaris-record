import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/preferences.dart';
import 'data/announcement_service.dart';

part 'announcements_providers.g.dart';

@Riverpod(keepAlive: true)
AnnouncementService announcementService(Ref ref) => AnnouncementService(
  Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
);

/// Whether the app looks for announcements when it starts. On by default.
@Riverpod(keepAlive: true)
class AnnouncementsEnabled extends _$AnnouncementsEnabled {
  static const _key = 'announcements_enabled';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? true;

  Future<void> set(bool value) async {
    state = value;
    await ref.read(sharedPreferencesProvider).setBool(_key, value);
  }
}
