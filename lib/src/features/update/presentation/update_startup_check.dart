import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/preferences.dart';
import '../domain/update_platform.dart';
import '../update_providers.dart';
import 'update_actions.dart';
import 'update_dialog.dart';

/// Looks for a new version once when the app opens and offers it in a dialog.
/// It only asks GitHub at most twice a day, can be switched off in About, and
/// does nothing on platforms without a download or while tests run.
class UpdateStartupCheck extends ConsumerStatefulWidget {
  const UpdateStartupCheck({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateStartupCheck> createState() => _UpdateStartupCheckState();
}

class _UpdateStartupCheckState extends ConsumerState<UpdateStartupCheck> {
  static const _interval = Duration(hours: 12);
  static const _lastCheckKey = 'last_update_check';

  /// The shell can be rebuilt (window resized across a layout breakpoint);
  /// the app should still check only once per launch.
  static bool _ranThisLaunch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_ranThisLaunch || !updatesSupported) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _ranThisLaunch = true;

    // An update downloaded last time is either installed now or no longer
    // wanted; either way the file is dead weight.
    unawaited(ref.read(updateServiceProvider).clearDownloads());

    if (!ref.read(autoUpdateCheckProvider)) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = prefs.getInt(_lastCheckKey);
    if (last != null && now - last < _interval.inMilliseconds) return;
    await prefs.setInt(_lastCheckKey, now);

    final result = await checkForUpdate(ref, manual: false);
    if (!mounted || result is! UpdateAvailable) return;
    await showUpdateDialog(context, result);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
