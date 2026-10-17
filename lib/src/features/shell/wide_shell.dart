import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/i18n/gen/strings.g.dart';
import '../../shared/i18n/pool_labels.dart';
import '../../shared/layout/window_size.dart';
import '../../shared/theme/app_tokens.dart';
import '../stats/domain/pool_type.dart';
import '../stats/pool_selection.dart';
import 'nav_destination.dart';
import 'rail_brand.dart';
import 'rail_metrics.dart';
import 'rail_state.dart';

/// Tablet / desktop layout: a navigation rail on the left.
///
/// - The first destination (Overview) is at the top. With the rail expanded, a
///   collapsible "Pull types" group below it lists the pull types, so the
///   Convene screen itself needs no selector.
/// - The last destination (Settings) is pinned to the bottom, where desktop
///   apps usually keep it.
/// - The rail is always expanded; it has no collapsed mode.
class WideShell extends ConsumerWidget {
  const WideShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    required this.size,
  });

  final StatefulNavigationShell navigationShell;
  final List<NavDestination> destinations;
  final WindowSize size;

  /// Key of the pinned bottom destination.
  static const bottomItemKey = ValueKey('rail-bottom-item');

  /// Key of the collapsible "Pull types" header.
  static const poolGroupHeaderKey = ValueKey('rail-pool-group-header');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final navColor = Theme.of(context).colorScheme.surfaceContainer;
    final shell = navigationShell;
    final current = shell.currentIndex;
    final groupOpen = ref.watch(poolGroupExpandedProvider);
    final pool = ref.watch(selectedPoolProvider);

    final main = destinations.sublist(0, destinations.length - 1);
    final bottomIndex = destinations.length - 1;
    final bottom = destinations.last;

    void selectBranch(int i) =>
        shell.goBranch(i, initialLocation: i == current);

    void onSelected(int i) {
      // 0 is Overview; 1.. are the pull types of the open group.
      final selection = i == 0 ? null : PoolType.values[i - 1];
      ref.read(selectedPoolProvider.notifier).select(selection);
      shell.goBranch(0, initialLocation: current == 0);
    }

    final rail = M3ENavigationRail(
      background: navColor,
      type: M3ENavigationRailType.alwaysExpand,
      labelBehavior: M3ENavigationRailLabelBehavior.alwaysShow,
      leading: const RailBrand(expanded: true),
      showDivider: true,
      // Wide enough for the longest pull-type label ("Standard Resonator").
      expandedWidth: 280,
      selectedIndex: current == 0
          ? railSelectedIndex(branch: 0, groupVisible: groupOpen, pool: pool)
          : -1,
      onDestinationSelected: onSelected,
      sections: [
        M3ENavigationRailSection(
          destinations: [
            for (final d in main)
              M3ENavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: d.selectedIcon,
                label: d.label,
              ),
          ],
        ),
        M3ENavigationRailSection(
          header: PoolGroupHeader(
            key: WideShell.poolGroupHeaderKey,
            label: t.stats.poolTypes,
            // While collapsed, say which pull type the screen shows.
            activeLabel: !groupOpen ? pool?.label(t) : null,
            tooltip: t.stats.togglePoolTypes,
            open: groupOpen,
            onToggle: ref.read(poolGroupExpandedProvider.notifier).toggle,
          ),
          destinations: [
            if (groupOpen)
              for (final p in PoolType.values)
                M3ENavigationRailDestination(
                  // Nested under the group header, so no icon.
                  icon: const SizedBox.shrink(),
                  label: p.label(t),
                  semanticLabel: p.label(t),
                  short: true,
                ),
          ],
        ),
      ],
      trailing: RailBottomItem(
        key: WideShell.bottomItemKey,
        destination: bottom,
        selected: current == bottomIndex,
        onTap: () => selectBranch(bottomIndex),
      ),
    );

    return Scaffold(
      body: Row(
        children: [
          rail,
          Expanded(child: shell),
        ],
      ),
    );
  }
}

/// Clickable header of the pull-type group: label plus a chevron that points
/// up while the group is open.
class PoolGroupHeader extends StatelessWidget {
  const PoolGroupHeader({
    super.key,
    required this.label,
    required this.tooltip,
    required this.open,
    required this.onToggle,
    this.activeLabel,
  });

  final String label;

  /// Name of the shown pull type, displayed as a pill while the group is
  /// collapsed and nothing in the list can be highlighted.
  final String? activeLabel;
  final String tooltip;

  /// Narrowest inner width (after the header's own padding) that still fits
  /// icon, label and chevron.
  static const labelMinWidth = 130.0;

  /// Icon of the group header. The pull types nested below have none.
  static const groupIcon = Icons.layers_outlined;

  /// Key of the active pull-type pill, for tests.
  static const activePillKey = ValueKey('rail-pool-group-active');
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          // The rail already insets section headers by 16px; with 16px more the
          // icon lines up with the Overview icon above (x = 32).
          padding: const EdgeInsets.fromLTRB(16, 10, 20, 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Too narrow (rail still animating open): just the icon.
              if (constraints.maxWidth < labelMinWidth) {
                return Icon(
                  groupIcon,
                  size: 24,
                  color: activeLabel != null
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        groupIcon,
                        size: 24,
                        color: activeLabel != null
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: open ? 0.5 : 0,
                        duration: context.tokens.motionFast,
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (activeLabel != null)
                    // Own line, under the label, so a long name ("Standard
                    // Resonator") fits.
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 32),
                      child: Container(
                        key: PoolGroupHeader.activePillKey,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activeLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A rail destination drawn by hand so it can sit at the bottom of the rail,
/// matching the look of the rail's own items (pill when selected).
class RailBottomItem extends StatelessWidget {
  const RailBottomItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  /// Narrowest slot width that still fits icon, gap and a label.
  static const labelMinWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    final icon = IconTheme(
      data: IconThemeData(color: fg, size: 24),
      child: selected ? destination.selectedIcon : Icon(destination.icon),
    );

    // While the rail animates open the slot is still too narrow for icon +
    // label, so show just the icon until there is room.
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth >= RailBottomItem.labelMinWidth;
        return AnimatedContainer(
          duration: tokens.motionFast,
          height: RailMetrics.itemHeight,
          alignment: room ? null : Alignment.center,
          padding: room
              ? const EdgeInsets.symmetric(horizontal: 16)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: selected ? scheme.secondaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(RailMetrics.indicatorRadius),
          ),
          child: room
              ? Row(
                  children: [
                    icon,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fg,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : icon,
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Separates the pinned destination from the list above it.
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.6)),
        Padding(
          // The rail's trailing slot already insets by 16px on each side,
          // which is what the other items' indicators use too.
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
          child: Semantics(
            button: true,
            selected: selected,
            label: destination.label,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(RailMetrics.indicatorRadius),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
