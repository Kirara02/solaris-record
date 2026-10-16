import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../domain/backup_bundle.dart';
import '../domain/backup_parser.dart';

final _log = Logger('backup');

String _stamp(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}${two(d.month)}${two(d.day)}';
}

/// Writes every account and record to a JSON file chosen by the user.
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final t = context.t;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final now = DateTime.now();
    final version = (await PackageInfo.fromPlatform()).version;
    final bundle = await ref
        .read(conveneRepositoryProvider)
        .exportBundle(now: now, appVersion: version);
    if (bundle.accounts.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(t.data.exportEmpty)));
      return;
    }
    final saved = await FilePicker.saveFile(
      fileName: 'solaris-record-backup-${_stamp(now)}.json',
      bytes: utf8.encode(bundle.encode()),
      mimeType: 'application/json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (saved == null) return;
    _log.info(
      'Exported accounts=${bundle.accounts.length} '
      'records=${bundle.recordCount}',
    );
    messenger.showSnackBar(
      SnackBar(content: Text(t.data.exportDone(records: bundle.recordCount))),
    );
  } on Object catch (e, st) {
    _log.warning('Export failed', e, st);
    messenger.showSnackBar(SnackBar(content: Text(t.data.exportFailed)));
  }
}

/// Outcome of [pickAndImportBackup], ready to show to the user.
typedef BackupImportOutcome = ({String message, bool ok});

/// Lets the user pick a JSON file and merges it into local data: a backup of
/// this app, or a WuWa Tracker export. Returns null when the picker is
/// cancelled.
Future<BackupImportOutcome?> pickAndImportBackup(
  WidgetRef ref,
  Translations t,
) async {
  BackupImportOutcome fail(String message) => (message: message, ok: false);

  final PlatformFile? file;
  try {
    file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
  } on Object catch (e, st) {
    _log.warning('File picker failed', e, st);
    return fail(t.data.importFailed);
  }
  if (file == null) return null;

  try {
    final bundle = parseBackup(utf8.decode(await file.readAsBytes()));
    final result = await ref
        .read(conveneRepositoryProvider)
        .importBundle(bundle);
    ref.invalidate(storageUsageProvider);
    _log.info(
      'Imported file accounts=${result.accounts} '
      'records=${bundle.recordCount} new=${result.newRecords}',
    );
    return (
      message: result.newRecords == 0
          ? t.data.importNothingNew
          : t.data.importDone(
              records: result.newRecords,
              accounts: result.accounts,
            ),
      ok: true,
    );
  } on UnsupportedBackupVersionException catch (e) {
    _log.warning('Import rejected: backup from a newer app (${e.version})');
    return fail(t.data.importTooNew);
  } on ForeignBackupException {
    _log.warning('Import rejected: not a backup or tracker file');
    return fail(t.data.importForeign);
  } on FormatException catch (e) {
    _log.warning('Import rejected: bad format (${e.message})');
    return fail(t.data.importInvalid);
  } on Object catch (e, st) {
    _log.warning('Import failed', e, st);
    return fail(t.data.importFailed);
  }
}

/// [pickAndImportBackup] reporting through a snackbar.
Future<void> importBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await pickAndImportBackup(ref, context.t);
  if (outcome == null) return;
  messenger.showSnackBar(SnackBar(content: Text(outcome.message)));
}
