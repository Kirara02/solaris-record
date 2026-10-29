import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/number_format.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/theme/mornye_theme.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/donut_chart.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/overview_stats.dart';
import '../stats_providers.dart';
import 'five_star_timeline.dart';
import 'stat_cards.dart';

/// Slivers of the global overview: totals, rarity and type distributions, and
/// the current pity of every pull type.
class OverviewSlivers extends ConsumerWidget {
  const OverviewSlivers({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return ref
        .watch(overviewStatsProvider(uid))
        .when(
          loading: () =>
              const SliverFillBody(child: Center(child: AppLoadingIndicator())),
          error: (e, _) => SliverFillBody(child: Center(child: Text('$e'))),
          data: (stats) {
            if (stats.total == 0) {
              return SliverFillBody(
                child: EmptyState(
                  icon: Icons.inbox_outlined,
                  title: t.stats.noPullsAnywhere,
                ),
              );
            }
            return SliverAdaptivePadding(
              sliver: SliverToBoxAdapter(child: _OverviewBody(stats: stats)),
            );
          },
        );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.stats});

  final OverviewStats stats;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;

    String detail(int count, double? avg) => avg == null
        ? t.stats.ofTotal(pct: StatCardsRow.percent(count, stats.total))
        : t.stats.ofTotalAvg(
            pct: StatCardsRow.percent(count, stats.total),
            avg: avg.toStringAsFixed(2),
          );

    // The three cards stay on one row, so phones get the compact variant.
    final dense = context.windowSize == WindowSize.compact;
    final cards = [
      StatCard(
        dense: dense,
        label: t.stats.total,
        value: formatNumber(stats.total),
        accent: scheme.primary,
        detail: t.stats.overviewAll,
      ),
      StatCard(
        dense: dense,
        label: t.stats.countFive,
        value: formatNumber(stats.fiveStars),
        accent: rarityColor(scheme, 5),
        detail: detail(stats.fiveStars, stats.averagePullsPerFiveStar),
      ),
      StatCard(
        dense: dense,
        label: t.stats.countFour,
        value: formatNumber(stats.fourStars),
        accent: rarityColor(scheme, 4),
        detail: detail(stats.fourStars, stats.averagePullsPerFourStar),
      ),
    ];

    // Mornye's secondary equals its primary (the accent), and a big donut in
    // the accent red is too loud next to the gold and violet rarity chart, so
    // the type chart takes cool system colours there.
    final typeColors = context.isMornye
        ? const [Color(0xFF0A84FF), Color(0xFF30B0C7), Color(0xFF5E5CE6)]
        : [scheme.primary, scheme.tertiary, scheme.secondary];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: t.stats.overviewAll),
        StatCardsLayout(cards: cards, singleRow: true),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final rarity = _ChartCard(
              title: t.stats.rarityDistribution,
              icon: Icons.pie_chart_outline,
              child: DonutChart(
                segments: [
                  DonutSegment(
                    label: t.stats.fiveStars,
                    value: stats.fiveStars,
                    color: rarityColor(scheme, 5),
                  ),
                  DonutSegment(
                    label: t.stats.fourStars,
                    value: stats.fourStars,
                    color: rarityColor(scheme, 4),
                  ),
                  DonutSegment(
                    label: t.stats.threeStars,
                    value: stats.threeStars,
                    color: scheme.outline,
                  ),
                ],
              ),
            );
            final types = _ChartCard(
              title: t.stats.typeDistribution,
              icon: Icons.donut_large,
              child: DonutChart(
                segments: [
                  for (final (i, e) in stats.typeCounts.indexed)
                    DonutSegment(
                      label: e.$1,
                      value: e.$2,
                      color: typeColors[i % typeColors.length],
                    ),
                ],
              ),
            );
            if (c.maxWidth < 640) {
              return Column(
                children: [rarity, const SizedBox(height: 12), types],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: rarity),
                  const SizedBox(width: 12),
                  Expanded(child: types),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ChartCard(
          title: t.stats.topRarityTitle,
          icon: Icons.bar_chart,
          child: _TopRarityBars(pools: stats.pools),
        ),
        if (stats.timeline.isNotEmpty) ...[
          const SizedBox(height: 12),
          FiveStarTimeline(
            items: stats.timeline,
            pullsSinceLast: stats.pullsSinceLastFive,
            title: t.stats.timelineAllTitle,
            nowText: t.stats.timelineNowAll(n: stats.pullsSinceLastFive),
            showPool: true,
          ),
        ],
        const SizedBox(height: 12),
        _ChartCard(
          title: t.stats.pityPerType,
          icon: Icons.bar_chart,
          child: Column(
            children: [for (final p in stats.pools) _PityBar(summary: p)],
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: groupDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }
}

/// A pull type's current pity as a bar, with how many pulls since its last 5★.
class _PityBar extends StatelessWidget {
  const _PityBar({required this.summary});

  final PoolSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final empty = summary.total == 0;
    final hard = summary.pool.hardPity5;
    final gold = rarityColor(scheme, 5);
    final fraction = empty ? 0.0 : (summary.pity5 / hard).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  summary.pool.label(t),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: empty ? scheme.onSurfaceVariant : null,
                  ),
                ),
              ),
              if (!empty)
                Text.rich(
                  TextSpan(
                    text: '${summary.pity5}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: gold,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: ' / $hard',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _PillBar(fraction: fraction, color: gold),
          const SizedBox(height: 6),
          Text(
            empty
                ? t.stats.noPulls
                : summary.fiveStars == 0
                ? t.stats.noFiveYet
                : t.stats.sinceLastFive(n: summary.pity5),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// How many 5★ each pull type has produced, as bars scaled to the busiest one,
/// with the pulls since that pull type's last 5★ underneath.
class _TopRarityBars extends StatelessWidget {
  const _TopRarityBars({required this.pools});

  final List<PoolSummary> pools;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shown = [
      for (final p in pools)
        if (p.total > 0) p,
    ];
    final most = shown.fold<int>(
      1,
      (m, p) => p.fiveStars > m ? p.fiveStars : m,
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          for (final p in shown)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.pool.label(t),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${formatNumber(p.fiveStars)} ${t.stats.fiveStars}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: rarityColor(scheme, 5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _PillBar(
                    fraction: p.fiveStars / most,
                    color: rarityColor(scheme, 5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.stats.sinceLastFive(n: p.pity5),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A rounded track with a gradient fill that grows in, [fraction] of the width.
class _PillBar extends StatelessWidget {
  const _PillBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Container(
        height: 12,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value,
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.55), color],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}
