import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/number_format.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_theme.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/donut_chart.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../stats/domain/overview_stats.dart';
import '../../stats/domain/pity_calculator.dart';
import '../../stats/domain/pool_type.dart';
import '../../stats/presentation/five_star_bubbles.dart';
import '../../stats/presentation/five_star_vertical_timeline.dart';
import '../../stats/presentation/stat_cards.dart';

/// Fixed width of the exported image, so it never depends on the window.
const shareCardWidth = 1200.0;

/// Most 5★ shown on a card, so a long history keeps a sensible height.
const shareMaxFiveStars = 48;

/// Rows of the timeline panel.
const shareTimelineRows = 10;

const _repoUrl = 'github.com/Kirara02/solaris-record';

/// Theme the card renders with, independent of the app's current theme except
/// for the style: with [mornye] set the card uses the Mornye palette and flat
/// surfaces instead of the seeded Material scheme.
ThemeData shareThemeFor(
  Color seed,
  Brightness brightness, {
  MornyeTheme? mornye,
}) => mornye != null
    ? MornyeTheme.build(brightness, mornye)
    : ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: brightness,
        ),
        extensions: const [AppTokens.standard],
      );

/// What a card shows: a pool's numbers, or the all-pools overview.
sealed class ShareContent {
  const ShareContent();

  /// Distinct items to preload before capturing.
  Iterable<({int resourceId, String resourceType})> get icons;
}

class ShareOverview extends ShareContent {
  const ShareOverview(this.stats);

  final OverviewStats stats;

  @override
  Iterable<({int resourceId, String resourceType})> get icons => _unique([
    for (final i in stats.timeline.take(shareMaxFiveStars)) i.entry,
  ]);
}

class SharePool extends ShareContent {
  const SharePool(this.pool, this.stats, this.typeCounts);

  final PoolType pool;
  final PoolStats stats;

  /// Item types (API `resourceType`) with counts, most common first.
  final List<(String, int)> typeCounts;

  @override
  Iterable<({int resourceId, String resourceType})> get icons =>
      _unique(stats.fiveStarHistory.reversed.take(shareMaxFiveStars));
}

Iterable<({int resourceId, String resourceType})> _unique(
  Iterable<FiveStarEntry> entries,
) {
  final seen = <int>{};
  return [
    for (final e in entries)
      if (e.resourceId > 0 && seen.add(e.resourceId))
        (resourceId: e.resourceId, resourceType: e.resourceType),
  ];
}

/// The shareable summary. Self-contained: own theme, fixed width, text scale
/// pinned to 1, so the exported image looks the same on every device.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.theme,
    required this.accountName,
    required this.uid,
    required this.content,
    required this.date,
    required this.appVersion,
  });

  final ThemeData theme;
  final String accountName;

  /// Already masked or in full, as the user chose.
  final String uid;
  final ShareContent content;

  /// Generation date shown in the header.
  final String date;
  final String appVersion;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: SizedBox(
          width: shareCardWidth,
          child: Builder(builder: _build),
        ),
      ),
    );
  }

  Widget _build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = switch (content) {
      ShareOverview() => t.stats.overviewTitle,
      SharePool(:final pool) => pool.label(t),
    };
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Material(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appVersion.isEmpty
                            ? t.appName
                            : '${t.appName} v$appVersion',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(_repoUrl, style: muted),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$accountName · ${t.accounts.uid(uid: uid)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(t.share.generated(date: date), style: muted),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            switch (content) {
              ShareOverview(:final stats) => _OverviewBody(stats: stats),
              SharePool(:final pool, :final stats, :final typeCounts) =>
                _PoolBody(pool: pool, stats: stats, typeCounts: typeCounts),
            },
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: groupDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Left column of the lower section (rarity and type donuts) beside the
/// timeline panel on the right.
class _ChartsAndTimeline extends StatelessWidget {
  const _ChartsAndTimeline({
    required this.fiveStars,
    required this.fourStars,
    required this.threeStars,
    required this.typeCounts,
    required this.timelineTitle,
    required this.timeline,
  });

  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final List<(String, int)> typeCounts;
  final String timelineTitle;
  final Widget timeline;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final typeColors = [scheme.primary, scheme.tertiary, scheme.secondary];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _Panel(
                title: t.stats.rarityDistribution,
                child: Center(
                  child: DonutChart(
                    size: 160,
                    segments: [
                      DonutSegment(
                        label: t.stats.fiveStars,
                        value: fiveStars,
                        color: rarityColor(scheme, 5),
                      ),
                      DonutSegment(
                        label: t.stats.fourStars,
                        value: fourStars,
                        color: rarityColor(scheme, 4),
                      ),
                      DonutSegment(
                        label: t.stats.threeStars,
                        value: threeStars,
                        color: scheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _Panel(
                title: t.stats.typeDistribution,
                child: Center(
                  child: DonutChart(
                    size: 160,
                    segments: [
                      for (final (i, e) in typeCounts.indexed)
                        DonutSegment(
                          label: e.$1,
                          value: e.$2,
                          color: typeColors[i % typeColors.length],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 7,
          child: _Panel(title: timelineTitle, child: timeline),
        ),
      ],
    );
  }
}

class _FiveStarPanel extends StatelessWidget {
  const _FiveStarPanel({required this.entries, required this.threshold});

  final List<FiveStarEntry> entries;
  final int threshold;

  @override
  Widget build(BuildContext context) => _Panel(
    title: context.t.stats.fiveStarTimeline,
    child: Wrap(
      spacing: 10,
      runSpacing: 14,
      children: [
        for (final e in entries) FiveStarBubble(entry: e, threshold: threshold),
      ],
    ),
  );
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

    final uniqueFives = <int>{};
    final fives = [
      for (final i in stats.timeline)
        if (i.entry.resourceId <= 0 || uniqueFives.add(i.entry.resourceId))
          i.entry,
    ].take(shareMaxFiveStars).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCardsLayout(
          singleRow: true,
          cards: [
            StatCard(
              label: t.stats.total,
              value: formatNumber(stats.total),
              accent: scheme.primary,
              detail: t.stats.overviewAll,
            ),
            StatCard(
              label: t.stats.countFive,
              value: '${stats.fiveStars}',
              accent: rarityColor(scheme, 5),
              detail: detail(stats.fiveStars, stats.averagePullsPerFiveStar),
            ),
            StatCard(
              label: t.stats.countFour,
              value: '${stats.fourStars}',
              accent: rarityColor(scheme, 4),
              detail: detail(stats.fourStars, stats.averagePullsPerFourStar),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ChartsAndTimeline(
          fiveStars: stats.fiveStars,
          fourStars: stats.fourStars,
          threeStars: stats.threeStars,
          typeCounts: stats.typeCounts,
          timelineTitle: t.stats.timelineAllTitle,
          timeline: stats.timeline.isEmpty
              ? const SizedBox.shrink()
              : FiveStarVerticalTimeline(
                  items: stats.timeline.take(shareTimelineRows).toList(),
                  nowText: t.stats.timelineNowAll(n: stats.pullsSinceLastFive),
                  showPool: true,
                ),
        ),
        if (fives.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FiveStarPanel(entries: fives, threshold: hardPity5),
        ],
      ],
    );
  }
}

class _PoolBody extends StatelessWidget {
  const _PoolBody({
    required this.pool,
    required this.stats,
    required this.typeCounts,
  });

  final PoolType pool;
  final PoolStats stats;
  final List<(String, int)> typeCounts;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final fives = stats.fiveStarHistory.reversed
        .take(shareMaxFiveStars)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCardsRow(stats: stats, pool: pool),
        const SizedBox(height: 16),
        _ChartsAndTimeline(
          fiveStars: stats.fiveStars,
          fourStars: stats.fourStars,
          threeStars: stats.threeStars,
          typeCounts: typeCounts,
          timelineTitle: t.stats.timelineTitle(n: stats.fiveStarHistory.length),
          timeline: fives.isEmpty
              ? const SizedBox.shrink()
              : FiveStarVerticalTimeline(
                  items: [
                    for (final e in fives.take(shareTimelineRows))
                      TimelineItem(e, pool),
                  ],
                  nowText: t.stats.sinceLastFive(n: stats.pity5),
                ),
        ),
        if (fives.isNotEmpty) ...[
          const SizedBox(height: 12),
          _FiveStarPanel(entries: fives, threshold: pool.hardPity5),
        ],
      ],
    );
  }
}
