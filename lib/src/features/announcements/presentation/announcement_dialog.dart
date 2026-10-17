import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/preferences.dart';
import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../announcements_providers.dart';
import '../domain/announcement.dart';

final _log = Logger('announcements');

const _dismissedKey = 'dismissed_announcements';
const _maxRemembered = 50;

String get _os => kIsWeb ? 'web' : Platform.operatingSystem;

/// Shows the first announcement that applies to this install and hasn't been
/// dismissed, then remembers its id so it appears only once.
Future<void> showAnnouncementIfAny(BuildContext context, WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final dismissed = prefs.getStringList(_dismissedKey) ?? const [];
  final version = (await PackageInfo.fromPlatform()).version;
  final all = await ref.read(announcementServiceProvider).fetch();
  final now = DateTime.now();
  final pending = [
    for (final a in all)
      if (!dismissed.contains(a.id) &&
          a.appliesTo(version: version, platform: _os, now: now))
        a,
  ];
  if (pending.isEmpty || !context.mounted) return;

  final announcement = pending.first;
  _log.info('Showing announcement id=${announcement.id}');
  await showDialog<void>(
    context: context,
    builder: (context) => _AnnouncementDialog(announcement: announcement),
  );
  final remembered = [...dismissed, announcement.id];
  await prefs.setStringList(
    _dismissedKey,
    remembered.length > _maxRemembered
        ? remembered.sublist(remembered.length - _maxRemembered)
        : remembered,
  );
}

class _AnnouncementDialog extends ConsumerWidget {
  const _AnnouncementDialog({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang = LocaleSettings.currentLocale.languageCode;
    final ctaUrl = announcement.ctaUrl;
    final ctaLabel = pickText(announcement.ctaLabel, lang);
    return AlertDialog(
      title: Text(pickText(announcement.title, lang) ?? ''),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Text(pickText(announcement.body, lang) ?? ''),
        ),
      ),
      actions: [
        if (ctaUrl != null && ctaLabel != null)
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final failed = t.info.openFailed;
              final opened = await ref
                  .read(urlOpenerProvider)
                  .open(Uri.parse(ctaUrl));
              if (!opened) {
                messenger.showSnackBar(SnackBar(content: Text(failed)));
              }
            },
            child: Text(ctaLabel),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.announcements.dismiss),
        ),
      ],
    );
  }
}
