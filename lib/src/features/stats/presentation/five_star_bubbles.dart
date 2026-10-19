import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/artwork_palette.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/item_name.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../info/domain/item_info.dart';
import '../../info/domain/item_kind.dart';
import '../../info/presentation/item_info_dialog.dart';
import '../../settings/settings_providers.dart';
import '../domain/pity_calculator.dart';
import '../domain/pool_type.dart';
import '../stats_providers.dart';

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

/// Every 5★ of the pool, newest first, as round avatars with their pull count
/// or (switchable, remembered) as a grid of cards. Tapping one opens its
/// details.
class FiveStarBubbles extends ConsumerWidget {
  const FiveStarBubbles({super.key, required this.entries, required this.pool});

  final List<FiveStarEntry> entries;
  final PoolType pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = ref.watch(fiveStarStyleChoiceProvider);
    final grid = style == FiveStarStyle.grid;
    void open(FiveStarEntry e) =>
        showFiveStarDetail(context, e, threshold: pool.hardPity5);

    return SettingsGroup(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: grid ? t.stats.styleBubbles : t.stats.styleGrid,
                  icon: Icon(
                    grid ? Icons.bubble_chart_outlined : Icons.grid_view,
                  ),
                  onPressed: () => ref
                      .read(fiveStarStyleChoiceProvider.notifier)
                      .set(grid ? FiveStarStyle.bubbles : FiveStarStyle.grid),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: grid
                    ? GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              mainAxisExtent: 200,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: entries.length,
                        itemBuilder: (context, i) => _FiveStarCard(
                          entry: entries[i],
                          threshold: pool.hardPity5,
                          onTap: () => open(entries[i]),
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 14,
                        children: [
                          for (final e in entries)
                            FiveStarBubble(
                              entry: e,
                              threshold: pool.hardPity5,
                              onTap: () => open(e),
                            ),
                        ],
                      ),
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

/// Details of a 5★ (pulls used, time, 50/50 result): a bottom sheet on compact
/// windows, a dialog centered over the content pane on wider ones.
void showFiveStarDetail(
  BuildContext context,
  FiveStarEntry e, {
  int threshold = hardPity5,
}) {
  showAdaptiveSheet(
    context,
    (inner) => ArtworkAccent(
      resourceId: e.resourceId,
      resourceType: e.resourceType,
      child: _FiveStarDetailBody(
        entry: e,
        threshold: threshold,
        onItemInfo: () {
          Navigator.pop(inner);
          showItemInfo(
            context,
            resourceId: e.resourceId,
            resourceType: e.resourceType,
            name: e.name,
            rarity: 5,
          );
        },
      ),
    ),
  );
}

class _FiveStarDetailBody extends StatelessWidget {
  const _FiveStarDetailBody({
    required this.entry,
    required this.threshold,
    required this.onItemInfo,
  });

  final FiveStarEntry entry;
  final int threshold;
  final VoidCallback onItemInfo;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = luckColors(scheme, e.pullsUsed, threshold: threshold);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                onPressed: onItemInfo,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A 5★ as a round avatar with its pull count badge and name.
class FiveStarBubble extends StatelessWidget {
  const FiveStarBubble({
    super.key,
    required this.entry,
    required this.threshold,
    this.onTap,
  });

  final FiveStarEntry entry;
  final int threshold;
  final VoidCallback? onTap;

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

/// A 5★ as a card: convene art as the background with the outfit art over it, with the pull count on
/// top and the name and time over a gradient at the bottom.
class _FiveStarCard extends ConsumerWidget {
  const _FiveStarCard({
    required this.entry,
    required this.onTap,
    required this.threshold,
  });

  final FiveStarEntry entry;
  final int threshold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (bg, fg) = luckColors(scheme, entry.pullsUsed, threshold: threshold);
    final ring = ringFor(scheme, entry.result);
    // Convene art (as in the item info dialog's gallery) when known, then
    // outfit art, then the icon.
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final info = entry.resourceId > 0
        ? ref
              .watch(
                itemInfoProvider(entry.resourceId, entry.resourceType, lang),
              )
              .value
        : null;
    String? firstOf(ItemGalleryKind kind) =>
        info?.gallery.where((g) => g.kind == kind).firstOrNull?.urls.first;
    final iconUrl = entry.resourceId > 0
        ? ref
              .watch(itemImageUrlProvider(entry.resourceId, entry.resourceType))
              .value
        : null;
    // Convene art is the background, outfit art the figure on top of it; items
    // lacking one fall back to the other, then to the item image.
    final background = firstOf(ItemGalleryKind.convene);
    final figure = firstOf(ItemGalleryKind.outfit) ?? info?.imageUrl ?? iconUrl;

    Widget placeholder() => Center(
      child: Icon(
        Icons.star,
        size: 44,
        color: rarityColor(scheme, 5).withValues(alpha: 0.6),
      ),
    );

    return Material(
      color: rarityColor(scheme, 5).withValues(alpha: 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: ring, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background == null && figure == null) placeholder(),
            for (final url in [?background, ?figure])
              CachedNetworkImage(
                key: ValueKey(url),
                imageUrl: url,
                fit: BoxFit.cover,
                // Weapon art sits right of center; showing more of the right
                // side of the crop moves it toward the middle.
                alignment: info?.kind == ItemKind.weapon
                    ? const Alignment(1, -1)
                    : Alignment.topCenter,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (_, _) => url == (background ?? figure)
                    ? placeholder()
                    : const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xE6000000)],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: StatusBadge(
                label: '${entry.pullsUsed}',
                background: bg,
                foreground: fg,
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemName(
                    resourceId: entry.resourceId,
                    fallback: entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      entry.time,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
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
