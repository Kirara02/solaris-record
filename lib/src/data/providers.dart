import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/import/domain/convene_api.dart';
import '../features/info/data/encore_info_service.dart';
import '../features/info/data/url_opener.dart';
import '../features/info/domain/item_info.dart';
import '../features/settings/data/storage_usage.dart';
import '../features/stats/data/item_image_service.dart';
import '../features/stats/data/item_name_service.dart';
import 'convene_repository.dart';
import 'database.dart';
import 'preferences.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
ConveneRepository conveneRepository(Ref ref) =>
    ConveneRepository(ref.watch(appDatabaseProvider));

@Riverpod(keepAlive: true)
ConveneApi conveneApi(Ref ref) => ConveneApi(
  Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      validateStatus: (s) => s != null && s < 400,
    ),
  ),
);

@Riverpod(keepAlive: true)
ItemImageService itemImageService(Ref ref) => ItemImageService(
  Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  ),
  ref.watch(sharedPreferencesProvider),
);

@Riverpod(keepAlive: true)
ItemNameService itemNameService(Ref ref) => ItemNameService();

/// Icon URL for an item, or null when none is available. Cached per item for
/// the app's lifetime.
@Riverpod(keepAlive: true)
Future<String?> itemImageUrl(Ref ref, int resourceId, String resourceType) =>
    ref.watch(itemImageServiceProvider).urlFor(resourceId, resourceType);

/// How many records have no item id. Follows the database.
@Riverpod(keepAlive: true)
Stream<int> incompleteRecordCount(Ref ref) =>
    ref.watch(conveneRepositoryProvider).watchCountWithoutResourceId();

/// Disk usage for the Data & storage screen. Invalidate after clearing data.
@riverpod
Future<StorageUsage> storageUsage(Ref ref) async {
  final counts = await ref.watch(conveneRepositoryProvider).counts();
  return measureStorage(accounts: counts.accounts, records: counts.records);
}

@Riverpod(keepAlive: true)
EncoreInfoService encoreInfoService(Ref ref) => EncoreInfoService();

/// Riverpod 3 retries failed providers with backoff by default, which would
/// delay the error state; the item info dialog offers its own retry button.
Duration? _noRetry(int retryCount, Object error) => null;

/// Reference info for an item in [lang]. Kept alive so reopening is instant.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<ItemInfo?> itemInfo(
  Ref ref,
  int resourceId,
  String resourceType,
  String lang,
) async {
  try {
    return await ref
        .watch(encoreInfoServiceProvider)
        .fetch(resourceId, resourceType, lang);
  } on Object catch (e, st) {
    Logger('info').warning(
      'Item info failed id=$resourceId type=$resourceType lang=$lang',
      e,
      st,
    );
    rethrow;
  }
}

@Riverpod(keepAlive: true)
UrlOpener urlOpener(Ref ref) => const UrlOpener();
