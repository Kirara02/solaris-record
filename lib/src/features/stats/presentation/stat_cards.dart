import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/number_format.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/pity_calculator.dart';
import '../domain/pool_type.dart';

/// Card surface washed with a soft [accent] tint and a matching hairline.
BoxDecoration accentCardDecoration(BuildContext context, Color accent) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: Color.alphaBlend(
      accent.withValues(alpha: 0.10),
      groupColor(context),
    ),
    borderRadius: context.tokens.borderRadiusCard,
    border: Border.all(color: accent.withValues(alpha: 0.28)),
    boxShadow: [
      BoxShadow(
        color: scheme.shadow.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

/// Label with an accent dot, big number and a detail line, on an accent-tinted
/// surface.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.detail,
    this.extra,
    this.dense = false,
  });

  final String label;
  final String value;
  final Color accent;
  final String? detail;

  /// Optional widget under the detail line (e.g. a status chip).
  final Widget? extra;

  /// Tighter padding and a smaller number, for three cards sharing a phone row.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      decoration: accentCardDecoration(context, accent),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: dense
            ? const EdgeInsets.fromLTRB(12, 12, 10, 12)
            : const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style:
                  (dense
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.headlineMedium)
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.1),
            ),
            if (detail != null) ...[
              const SizedBox(height: 4),
              Text(
                detail!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (extra != null) ...[const SizedBox(height: 8), extra!],
          ],
        ),
      ),
    );
  }
}

/// Total pulls, 5★ count, 4★ count (each with share of total and average
/// pulls between hits) and, on the featured resonator banner, the 50/50 record.
class StatCardsRow extends StatelessWidget {
  const StatCardsRow({super.key, required this.stats, required this.pool});

  final PoolStats stats;
  final PoolType pool;

  static String percent(int count, int total) =>
      total == 0 ? '0' : (count * 100 / total).toStringAsFixed(2);

  String fiftyFiftyDetail(BuildContext context) {
    final t = context.t;
    final won = stats.fiftyFiftyWon;
    final lost = stats.fiftyFiftyLost;
    final rate = stats.fiftyFiftyWinRate;
    final record = t.stats.fiftyFiftyRecord(won: won, lost: lost);
    if (rate == null) return record;
    final longest = t.stats.longestStreaks(
      win: stats.longestWinStreak,
      loss: stats.longestLossStreak,
    );
    return '$record · ${t.stats.fiftyFiftyRate(pct: percent(won, won + lost))}'
        '\n$longest';
  }

  Widget? fiftyFiftyBadges(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final streak = stats.currentStreak;
    final badges = <Widget>[
      if (stats.nextFiveStarGuaranteed)
        StatusBadge(
          label: t.stats.nextGuaranteed,
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        ),
      if (streak != null)
        if (streak.result == FiftyFiftyResult.won)
          StatusBadge(
            label: t.stats.winStreak(n: streak.length),
            background: scheme.tertiaryContainer,
            foreground: scheme.onTertiaryContainer,
          )
        else
          StatusBadge(
            label: t.stats.lossStreak(n: streak.length),
            background: scheme.errorContainer,
            foreground: scheme.onErrorContainer,
          ),
    ];
    return badges.isEmpty
        ? null
        : Wrap(spacing: 6, runSpacing: 6, children: badges);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final total = stats.total;

    String detail(int count, double? avg) => avg == null
        ? t.stats.ofTotal(pct: percent(count, total))
        : t.stats.ofTotalAvg(
            pct: percent(count, total),
            avg: avg.toStringAsFixed(2),
          );

    final cards = <Widget>[
      StatCard(
        label: t.stats.total,
        value: formatNumber(total),
        accent: scheme.primary,
        detail: t.stats.totalDetail(n: formatNumber(stats.threeStars)),
      ),
      StatCard(
        label: t.stats.countFive,
        value: formatNumber(stats.fiveStars),
        accent: rarityColor(scheme, 5),
        detail: detail(stats.fiveStars, stats.averagePullsPerFiveStar),
      ),
      StatCard(
        label: t.stats.countFour,
        value: formatNumber(stats.fourStars),
        accent: rarityColor(scheme, 4),
        detail: detail(stats.fourStars, stats.averagePullsPerFourStar),
      ),
      if (pool.hasFiftyFifty)
        StatCard(
          label: t.stats.fiftyFifty,
          value: '${stats.fiftyFiftyWon} / ${stats.fiftyFiftyLost}',
          accent: scheme.tertiary,
          detail: fiftyFiftyDetail(context),
          extra: fiftyFiftyBadges(context),
        ),
    ];

    return StatCardsLayout(cards: cards);
  }
}

/// Lays [cards] out in one row on wide layouts and two per row on phones (or
/// always one row with [singleRow]); the cards of a row share the tallest
/// card's height.
class StatCardsLayout extends StatelessWidget {
  const StatCardsLayout({
    super.key,
    required this.cards,
    this.singleRow = false,
  });

  final List<Widget> cards;
  final bool singleRow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = singleRow || constraints.maxWidth >= 720
            ? cards.length
            : 2;
        return Column(
          children: [
            for (var start = 0; start < cards.length; start += columns) ...[
              if (start > 0) const SizedBox(height: gap),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < columns; i++) ...[
                      if (i > 0) const SizedBox(width: gap),
                      Expanded(
                        child: start + i < cards.length
                            ? cards[start + i]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
