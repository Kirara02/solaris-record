import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../data/preferences.dart';
import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../domain/update_info.dart';
import '../domain/update_platform.dart';
import '../update_providers.dart';

final _log = Logger('update');

const _lastSeenKey = 'last_seen_version';

/// After the app was updated, shows the notes of the version that is now
/// installed, once. A first launch only records the version (there is nothing
/// to explain yet), and a failed lookup is retried at the next launch.
Future<void> showWhatsNewIfNeeded(BuildContext context, WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  final current = (await PackageInfo.fromPlatform()).version;
  final seen = prefs.getString(_lastSeenKey);
  if (seen == current) return;
  if (seen == null || !isNewerVersion(current, seen)) {
    await prefs.setString(_lastSeenKey, current);
    return;
  }

  final UpdateInfo? release;
  try {
    release = await ref
        .read(updateServiceProvider)
        .fetchVersion(current, updatePlatform());
  } on Object catch (e) {
    _log.info('Could not load the notes of $current: $e');
    return;
  }
  await prefs.setString(_lastSeenKey, current);
  final notes = release == null ? '' : formatReleaseNotes(release.notes);
  if (release == null || notes.isEmpty || !context.mounted) return;

  _log.info('Showing what\'s new for $current');
  await showDialog<void>(
    context: context,
    builder: (context) => _WhatsNewDialog(
      version: current,
      notes: notes,
      pageUrl: release!.pageUrl,
    ),
  );
}

class _WhatsNewDialog extends ConsumerWidget {
  const _WhatsNewDialog({
    required this.version,
    required this.notes,
    required this.pageUrl,
  });

  final String version;
  final String notes;
  final String pageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return AppAlertDialog(
      title: Text(t.whatsNewDialog.title(version: version)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(child: Text(notes)),
      ),
      actions: [
        TextButton(
          onPressed: () => ref.read(urlOpenerProvider).open(Uri.parse(pageUrl)),
          child: Text(t.whatsNewDialog.fullChangelog),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.whatsNewDialog.gotIt),
        ),
      ],
    );
  }
}
