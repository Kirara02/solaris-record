import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/item_name.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../info/presentation/item_info_dialog.dart';
import '../domain/pity_calculator.dart';
import '../domain/pool_type.dart';

enum LuckTier { lucky, average, unlucky }

/// Luck of a 5★ by how much of the pity limit it used: up to half is lucky,
/// up to 80% average, beyond that unlucky.
LuckTier luckTier(int pulls, {int threshold = hardPity5}) {
  final ratio = threshold <= 0 ? 1.0 : pulls / threshold;
  if (ratio <= 0.5) return LuckTier.lucky;
  if (ratio <= 0.8) return LuckTier.average;
  return LuckTier.unlucky;
}

/// Tinted container pair for a pull-count badge.
(Color, Color) luckColors(
  ColorScheme scheme,
  int pulls, {
  int threshold = hardPity5,
}) => switch (luckTier(pulls, threshold: threshold)) {
  LuckTier.lucky => (scheme.primaryContainer, scheme.onPrimaryContainer),
  LuckTier.average => (scheme.secondaryContainer, scheme.onSecondaryContainer),
  LuckTier.unlucky => (scheme.errorContainer, scheme.onErrorContainer),
};

/// Solid colour for a timeline node of the given [tier].
Color luckNodeColor(ColorScheme scheme, LuckTier tier) => switch (tier) {
  LuckTier.lucky => scheme.primary,
  LuckTier.average => scheme.tertiary,
  LuckTier.unlucky => scheme.error,
};

/// Ring colour for a 5★'s 50/50 outcome (rarity colour where not applicable).
Color ringFor(ColorScheme scheme, FiftyFiftyResult result) => switch (result) {
  FiftyFiftyResult.won => scheme.primary,
  FiftyFiftyResult.lost => scheme.error,
  FiftyFiftyResult.guaranteed => scheme.tertiary,
  FiftyFiftyResult.notApplicable => rarityColor(scheme, 5),
};

/// Every 5★ of the pool as a round avatar with its pull count, newest first.
/// Tapping one opens its details.
class FiveStarBubbles extends StatelessWidget {
  const FiveStarBubbles({super.key, required this.entries, required this.pool});

  final List<FiveStarEntry> entries;
  final PoolType pool;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SettingsGroup(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 14,
                children: [
                  for (final e in entries)
                    _Bubble(
                      entry: e,
                      threshold: pool.hardPity5,
                      onTap: () => showFiveStarDetail(
                        context,
                        e,
                        threshold: pool.hardPity5,
                      ),
                    ),
                ],
              ),
              if (pool.hasFiftyFifty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _LegendDot(scheme.primary, t.stats.won),
                    _LegendDot(scheme.error, t.stats.lost),
                    _LegendDot(scheme.tertiary, t.stats.guaranteed),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet with a 5★'s pulls used, time and 50/50 result.
void showFiveStarDetail(
  BuildContext context,
  FiveStarEntry e, {
  int threshold = hardPity5,
}) {
  final t = context.t;
  final scheme = Theme.of(context).colorScheme;
  final (bg, fg) = luckColors(scheme, e.pullsUsed, threshold: threshold);

  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    // Without this a sheet is capped at about half the screen, which pushed
    // the "Item info" button into the scroll area.
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ItemIcon(
                resourceId: e.resourceId,
                resourceType: e.resourceType,
                rarity: 5,
                size: 96,
                circular: true,
                ringColor: ringFor(scheme, e.result),
              ),
              const SizedBox(height: 12),
              ItemName(
                resourceId: e.resourceId,
                fallback: e.name,
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: rarityColor(scheme, 5),
                ),
              ),
              const SizedBox(height: 16),
              SettingsGroup(
                children: [
                  SettingsItem(
                    icon: Icons.layers_outlined,
                    title: t.stats.detailPity,
                    trailing: StatusBadge(
                      label: '${e.pullsUsed} / $threshold',
                      background: bg,
                      foreground: fg,
                    ),
                    footer: M3EProgressIndicator.linear(
                      value: (e.pullsUsed / threshold).clamp(0.0, 1.0),
                      color: fg,
                      trackColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  SettingsItem(
                    icon: Icons.schedule,
                    title: t.stats.detailTime,
                    trailing: Text(e.time),
                    showDivider: e.result != FiftyFiftyResult.notApplicable,
                  ),
                  if (e.result != FiftyFiftyResult.notApplicable)
                    SettingsItem(
                      icon: Icons.casino_outlined,
                      title: t.stats.detailResult,
                      trailing: StatusBadge(
                        label: switch (e.result) {
                          FiftyFiftyResult.won => t.stats.won,
                          FiftyFiftyResult.lost => t.stats.lost,
                          _ => t.stats.guaranteed,
                        },
                        background: ringFor(scheme, e.result),
                        foreground: scheme.surface,
                      ),
                      showDivider: false,
                    ),
                ],
              ),
              if (e.resourceId > 0) ...[
                const SizedBox(height: 12),
                M3EButton(
                  style: M3EButtonStyle.tonal,
                  size: M3EButtonSize.md,
                  icon: const Icon(Icons.info_outline),
                  label: Text(t.info.button),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    showItemInfo(
                      context,
                      resourceId: e.resourceId,
                      resourceType: e.resourceType,
                      name: e.name,
                      rarity: 5,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.entry,
    required this.onTap,
    required this.threshold,
  });

  final FiveStarEntry entry;
  final int threshold;
  final VoidCallback onTap;

  static const _size = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (bg, fg) = luckColors(scheme, entry.pullsUsed, threshold: threshold);

    return SizedBox(
      width: 64,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _size + 8,
              height: _size + 6,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  ItemIcon(
                    resourceId: entry.resourceId,
                    resourceType: entry.resourceType,
                    rarity: 5,
                    size: _size,
                    circular: true,
                    ringColor: ringFor(scheme, entry.result),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 22),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: scheme.surface, width: 2),
                      ),
                      child: Text(
                        '${entry.pullsUsed}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ItemName(
              resourceId: entry.resourceId,
              fallback: entry.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
