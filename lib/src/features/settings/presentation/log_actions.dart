import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/logging/app_log.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../settings_providers.dart';

final _log = Logger('logs');

String _stamp(DateTime d) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year}${two(d.month)}${two(d.day)}';
}

/// Saves the debug log, with a header naming the app version and platform, to
/// a text file chosen by the user.
Future<void> exportLogs(BuildContext context, WidgetRef ref) async {
  final t = context.t;
  final messenger = ScaffoldMessenger.of(context);
  void say(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));

  if (!AppLog.hasLogs) {
    say(t.data.logsEmpty);
    return;
  }
  try {
    final now = DateTime.now();
    final version = (await PackageInfo.fromPlatform()).version;
    final text = await AppLog.collect(
      info:
          'Solaris Record $version | ${defaultTargetPlatform.name} | '
          'ui=${LocaleSettings.currentLocale.languageCode} | '
          'exported=${now.toIso8601String()}',
    );
    final saved = await FilePicker.saveFile(
      fileName: 'solaris-record-logs-${_stamp(now)}.txt',
      bytes: utf8.encode(text),
      mimeType: 'text/plain',
      type: FileType.custom,
      allowedExtensions: const ['txt', 'log'],
    );
    if (saved == null) return;
    _log.info('Logs exported bytes=${text.length}');
    say(t.data.logsExported);
  } on Object catch (e, st) {
    _log.warning('Log export failed', e, st);
    say(t.data.logsExportFailed);
  }
}

/// Deletes all stored logs after confirming.
Future<void> clearLogs(BuildContext context, WidgetRef ref) async {
  final t = context.t;
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showConfirmDialog(
    context,
    title: t.data.clearLogsTitle,
    body: t.data.clearLogsBody,
    confirmLabel: t.data.clear,
    cancelLabel: t.data.cancel,
  );
  if (!confirmed) return;
  await AppLog.clear();
  ref.invalidate(logSizeProvider);
  messenger.showSnackBar(SnackBar(content: Text(t.data.logsCleared)));
}
