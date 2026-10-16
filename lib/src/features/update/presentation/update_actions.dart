import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/update_info.dart';
import '../domain/update_platform.dart';
import '../update_providers.dart';

final _log = Logger('update');

sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

/// A newer release than the installed one.
class UpdateAvailable extends UpdateCheckResult {
  const UpdateAvailable(this.info, this.currentVersion);

  final UpdateInfo info;
  final String currentVersion;
}

class UpdateUpToDate extends UpdateCheckResult {
  const UpdateUpToDate();
}

class UpdateCheckFailed extends UpdateCheckResult {
  const UpdateCheckFailed();
}

/// Looks for a release newer than the installed version. An automatic check
/// ([manual] false) stays quiet about a version the user chose to skip.
Future<UpdateCheckResult> checkForUpdate(
  WidgetRef ref, {
  required bool manual,
}) async {
  try {
    final current = (await PackageInfo.fromPlatform()).version;
    final latest = await ref
        .read(updateServiceProvider)
        .fetchLatest(updatePlatform());
    if (latest == null || !isNewerVersion(latest.version, current)) {
      _log.info(
        'No update installed=$current latest=${latest?.version ?? 'none'}',
      );
      return const UpdateUpToDate();
    }
    if (!manual && ref.read(skippedUpdateVersionProvider) == latest.version) {
      _log.info('Update ${latest.version} skipped by the user');
      return const UpdateUpToDate();
    }
    _log.info(
      'Update available installed=$current latest=${latest.version} '
      'file=${latest.asset?.name ?? 'none'}',
    );
    return UpdateAvailable(latest, current);
  } on Object catch (e, st) {
    _log.warning('Update check failed', e, st);
    return const UpdateCheckFailed();
  }
}
