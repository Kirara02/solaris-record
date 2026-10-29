import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../repair_providers.dart';
import 'record_repair_actions.dart';

/// A warning icon for the top bar that shows while some records lack an item
/// id (so no image or details), and offers to repair them. Takes no space
/// when everything is complete.
class RepairWarningButton extends ConsumerWidget {
  const RepairWarningButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(incompleteRecordWarningProvider);
    if (count == 0) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: context.t.data.repairWarningTooltip(n: count),
      icon: Badge(
        label: Text('$count'),
        child: AdaptiveIcon(Icons.error_outline, color: scheme.error),
      ),
      onPressed: () => confirmRepairRecords(context, ref, count),
    );
  }
}
