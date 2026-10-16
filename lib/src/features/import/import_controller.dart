import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers.dart';
import '../../shared/logging/log_sanitize.dart';
import '../accounts/accounts_providers.dart';
import '../stats/domain/pool_type.dart';
import 'domain/convene_api.dart';
import 'domain/convene_url.dart';
import 'saved_import_urls.dart';

part 'import_controller.g.dart';

final _log = Logger('import');

class ImportSummary {
  const ImportSummary({required this.uid, required this.newRecords});

  final String uid;
  final int newRecords;
}

/// Pool currently being fetched, for progress display.
@riverpod
class ImportProgress extends _$ImportProgress {
  @override
  PoolType? build() => null;

  void set(PoolType? pool) => state = pool;
}

/// Idle state is `AsyncData(null)`; errors are [ConveneUrlException] or
/// [ConveneApiException].
@riverpod
class ImportController extends _$ImportController {
  static const _requestGap = Duration(milliseconds: 400);

  @override
  Future<ImportSummary?> build() async => null;

  Future<void> run(String rawUrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _import(rawUrl));
    final result = state;
    if (result.hasError) {
      final e = result.error;
      _log.warning(
        switch (e) {
          ConveneUrlException(:final missing) =>
            'Import rejected: bad URL (missing: ${missing.join(', ')})',
          ConveneApiException(:final error, :final detail) =>
            'Import failed: api=${error.name}'
                '${detail == null ? '' : ' detail=$detail'}',
          _ => 'Import failed: unexpected',
        },
        e is ConveneUrlException || e is ConveneApiException ? null : e,
        result.stackTrace,
      );
    }
  }

  Future<ImportSummary> _import(String rawUrl) async {
    final url = parseConveneUrl(rawUrl);
    final api = ref.read(conveneApiProvider);
    final repo = ref.read(conveneRepositoryProvider);
    final progress = ref.read(importProgressProvider.notifier);

    final uid = sanitizeUid(url.playerId);
    _log.info('Import started uid=$uid');
    var added = 0;
    try {
      for (final pool in PoolType.values) {
        progress.set(pool);
        final List<RemoteRecord> records;
        try {
          records = await api.fetchPool(url, pool);
        } on ConveneApiException catch (e) {
          // The first pool validates the URL. Later on, a rejected pool just
          // means this server doesn't offer it, so it is skipped.
          if (pool == PoolType.values.first ||
              e.error != ConveneApiError.invalidOrExpired) {
            rethrow;
          }
          _log.info('Skipped pool=${pool.id}: rejected by server');
          continue;
        }
        if (pool == PoolType.values.first) {
          // Only create the account once the server accepted the URL.
          await repo.upsertAccount(uid: url.playerId, serverId: url.serverId);
        }
        final fresh = await repo.mergeRecords(url.playerId, pool, records);
        added += fresh;
        _log.info(
          'Pool fetched uid=$uid pool=${pool.id} '
          'received=${records.length} new=$fresh',
        );
        await Future<void>.delayed(_requestGap);
      }
    } on ConveneApiException catch (e) {
      if (e.error == ConveneApiError.invalidOrExpired) {
        await ref.read(savedImportUrlsProvider).remove(url.playerId);
      }
      rethrow;
    } finally {
      progress.set(null);
    }
    await ref.read(savedImportUrlsProvider).save(url.playerId, rawUrl);
    await ref.read(activeUidProvider.notifier).select(url.playerId);
    _log.info('Import finished uid=$uid new=$added');
    return ImportSummary(uid: url.playerId, newRecords: added);
  }
}
