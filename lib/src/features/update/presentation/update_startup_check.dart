import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/preferences.dart';
import '../../announcements/announcements_providers.dart';
import '../../announcements/presentation/announcement_dialog.dart';
import '../domain/update_platform.dart';
import '../update_providers.dart';
import 'update_actions.dart';
import 'update_dialog.dart';
import 'whats_new.dart';

/// Runs the checks that belong to opening the app, one dialog at a time: a
/// new version (at most twice a day, can be switched off in About, only where
/// there is a download), the notes of the version that was just installed, and
/// a developer announcement (also at most twice a day and switchable). Does
/// nothing on the web or while tests run.
class UpdateStartupCheck extends ConsumerStatefulWidget {
  const UpdateStartupCheck({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateStartupCheck> createState() => _UpdateStartupCheckState();
}

class _UpdateStartupCheckState extends ConsumerState<UpdateStartupCheck> {
  static const _interval = Duration(hours: 12);
  static const _lastCheckKey = 'last_update_check';
  static const _lastAnnouncementKey = 'last_announcement_check';

  /// The shell can be rebuilt (window resized across a layout breakpoint);
  /// the app should still check only once per launch.
  static bool _ranThisLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  /// Whether [key] was last stamped more than [_interval] ago; stamps it now
  /// when so.
  Future<bool> _due(String key) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = prefs.getInt(key);
    if (last != null && now - last < _interval.inMilliseconds) return false;
    await prefs.setInt(key, now);
    return true;
  }

  Future<void> _run() async {
    if (_ranThisLaunch || kIsWeb) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _ranThisLaunch = true;

    if (updatesSupported) {
      // An update downloaded last time is either installed now or no longer
      // wanted; either way the file is dead weight.
      unawaited(ref.read(updateServiceProvider).clearDownloads());

      if (ref.read(autoUpdateCheckProvider) && await _due(_lastCheckKey)) {
        final result = await checkForUpdate(ref, manual: false);
        if (!mounted) return;
        if (result is UpdateAvailable) await showUpdateDialog(context, result);
      }
    }

    if (!mounted) return;
    await showWhatsNewIfNeeded(context, ref);

    if (!mounted || !ref.read(announcementsEnabledProvider)) return;
    if (await _due(_lastAnnouncementKey) && mounted) {
      await showAnnouncementIfAny(context, ref);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
