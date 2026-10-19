import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/horizontal_scroll_area.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../accounts/accounts_providers.dart';
import '../../accounts/presentation/account_widgets.dart';
import '../../import/presentation/import_dialog.dart';
import '../../share/presentation/share_dialog.dart';
import '../domain/pool_type.dart';
import '../pool_selection.dart';
import 'overview_view.dart';
import 'pool_view.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final account = ref.watch(activeAccountProvider);
    final pool = ref.watch(selectedPoolProvider);
    // Wide windows get the analyzer-style top bar actions.
    final wide = context.windowSize != WindowSize.compact;
    // On wide layouts the pull types live in the rail, so the screen shows no
    // selector and names the pool in its title.
    final inRail = wide;

    if (account == null) {
      return Scaffold(
        body: EmptyState(
          icon: Icons.auto_awesome,
          leading: const AppLogo(size: 104),
          title: t.stats.noAccountTitle,
          body: t.stats.noAccountBody,
          action: M3EButton(
            size: M3EButtonSize.md,
            icon: const AdaptiveIcon(Icons.download),
            label: Text(t.stats.goToImport),
            onPressed: () => showImportDialog(context),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: inRail
                ? (pool?.label(t) ?? t.stats.overviewTitle)
                : (pool == null ? t.nav.overview : t.nav.stats),
            actions: wide
                ? [
                    // Wide top bar: "Update" button and the account pill.
                    IconButton(
                      tooltip: t.share.tooltip,
                      icon: const AdaptiveIcon(Icons.ios_share),
                      onPressed: () => showShareDialog(
                        context,
                        account: account,
                        pool: pool,
                      ),
                    ),
                    const SizedBox(width: 4),
                    M3EButton(
                      size: M3EButtonSize.sm,
                      icon: const AdaptiveIcon(Icons.sync),
                      label: Text(t.stats.updateShort),
                      onPressed: () => showImportDialog(context),
                    ),
                    const SizedBox(width: 12),
                    AccountPill(account: account),
                  ]
                : [
                    IconButton(
                      tooltip: t.share.tooltip,
                      icon: const AdaptiveIcon(Icons.ios_share),
                      onPressed: () => showShareDialog(
                        context,
                        account: account,
                        pool: pool,
                      ),
                    ),
                    IconButton(
                      tooltip: t.settings.import,
                      icon: const AdaptiveIcon(Icons.download_outlined),
                      onPressed: () => showImportDialog(context),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Tooltip(
                        message: t.stats.switchAccount,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => showAccountSwitcher(context, ref),
                          child: AccountAvatar(account: account),
                        ),
                      ),
                    ),
                  ],
          ),
          // Phones: chips only on the Convene tab (the Overview tab has none).
          if (!inRail && pool != null)
            SliverToBoxAdapter(
              child: _PoolSelector(
                selected: pool,
                onSelected: ref.read(selectedPoolProvider.notifier).select,
              ),
            ),
          if (pool == null)
            OverviewSlivers(
              key: ValueKey('${account.uid}-overview'),
              uid: account.uid,
            )
          else
            PoolSlivers(
              key: ValueKey('${account.uid}-${pool.id}'),
              uid: account.uid,
              pool: pool,
            ),
        ],
      ),
    );
  }
}

class _PoolSelector extends StatelessWidget {
  const _PoolSelector({required this.selected, required this.onSelected});

  final PoolType selected;
  final ValueChanged<PoolType> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    const options = PoolType.values;
    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final inset = WindowSize.sideInset(constraints.maxWidth);
          return HorizontalScrollArea(
            builder: (context, controller) => ListView.separated(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: inset),
              itemCount: options.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final p = options[i];
                return Center(
                  child: SettingsChoiceChip(
                    label: p.label(t),
                    isSelected: p == selected,
                    onTap: () => onSelected(p),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
