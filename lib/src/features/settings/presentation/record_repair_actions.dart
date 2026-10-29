import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../guide/guide_providers.dart';
import '../data/record_repair.dart';
import '../repair_providers.dart';

final _log = Logger('repair');

/// Fills in the item ids that older records lack, and says what happened.
Future<void> repairRecords(BuildContext context, WidgetRef ref) async {
  final t = context.t;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final report = await RecordRepair(
      ref.read(conveneRepositoryProvider),
      ref.read(guideServiceProvider),
    ).run();
    _log.info('Repaired fixed=${report.fixed} remaining=${report.remaining}');
    // What is left cannot be matched, so stop warning about it.
    await ref.read(repairIgnoredCountProvider.notifier).set(report.remaining);
    final message = report.nothingToDo
        ? t.data.repairNone
        : report.remaining == 0
        ? t.data.repairDone(n: report.fixed)
        : t.data.repairDoneLeft(fixed: report.fixed, left: report.remaining);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  } on Object catch (e, st) {
    _log.warning('Repair failed', e, st);
    messenger.showSnackBar(SnackBar(content: Text(t.data.repairFailed)));
  }
}

/// Asks before repairing from the warning in the top bar, saying how many
/// records are affected.
Future<void> confirmRepairRecords(
  BuildContext context,
  WidgetRef ref,
  int count,
) async {
  final t = context.t;
  final confirmed = await showConfirmDialog(
    context,
    title: t.data.repairRecords,
    body: t.data.repairPromptBody(n: count),
    confirmLabel: t.data.repairConfirm,
    cancelLabel: t.data.cancel,
  );
  if (confirmed && context.mounted) await repairRecords(context, ref);
}
