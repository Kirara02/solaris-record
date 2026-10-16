import 'dart:convert';

import 'backup_bundle.dart';
import 'wuwa_tracker_import.dart';

/// Reads a backup of this app or a WuWa Tracker export, detected from content.
///
/// Throws [ForeignBackupException] for other files,
/// [UnsupportedBackupVersionException] for backups from a newer app, and
/// [FormatException] for malformed content.
BackupBundle parseBackup(String text) {
  final Object? raw;
  try {
    raw = jsonDecode(text);
  } on FormatException {
    throw const FormatException('Invalid JSON');
  }
  if (raw is! Map<String, dynamic>) throw const ForeignBackupException();
  try {
    if (raw['app'] == backupAppId) return BackupBundle.fromJson(raw);
    if (raw.containsKey('app')) throw const ForeignBackupException();
    if (isWuwaTrackerFile(raw)) return parseWuwaTracker(raw);
  } on TypeError catch (e) {
    throw FormatException('Unexpected structure: $e');
  }
  throw const ForeignBackupException();
}
