import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/number_format.dart';
import '../../../shared/theme/app_colors.dart';
import '../domain/pity_calculator.dart';
import '../domain/pool_type.dart';
import 'stat_cards.dart';

/// Pity distribution of the 5★ pulls plus Astrite spent and the worst case to
/// the next (featured) 5★.
class PityAnalysis extends StatelessWidget {
  const PityAnalysis({super.key, required this.stats, required this.pool});

  final PoolStats stats;
  final PoolType pool;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final maxPulls = maxPullsToNext(pool, stats);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatCardsLayout(
          singleRow: true,
          cards: [
            StatCard(
              label: t.stats.astriteSpent,
              value: formatNumber(stats.total * astritePerPull),
              accent: scheme.primary,
              dense: true,
            ),
            StatCard(
              label: pool.hasFiftyFifty
                  ? t.stats.maxPullsFeatured
                  : t.stats.maxPullsNext,
              value: formatNumber(maxPulls),
              accent: rarityColor(scheme, 5),
              detail: t.stats.astriteValue(
                n: formatNumber(maxPulls * astritePerPull),
              ),
              dense: true,
            ),
          ],
        ),
        if (stats.fiveStarHistory.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Histogram(stats: stats, pool: pool),
        ],
      ],
    );
  }
}

class _Histogram extends StatelessWidget {
  const _Histogram({required this.stats, required this.pool});

  final PoolStats stats;
  final PoolType pool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const size = 10;
    final buckets = pityHistogram(
      stats.fiveStarHistory,
      pool.hardPity5,
      bucketSize: size,
    );
    const chartHeight = 130.0;
    const countHeight = 20.0;
    final peak = buckets.fold<int>(1, (m, c) => c > m ? c : m);
    final gold = rarityColor(scheme, 5);
    return Container(
      width: double.infinity,
      decoration: accentCardDecoration(context, gold),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.t.stats.pityDistribution.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '5★ ${formatNumber(stats.fiveStars)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: chartHeight + countHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  top: countHeight,
                  child: CustomPaint(
                    painter: _GridPainter(
                      color: scheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < buckets.length; i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _Bar(
                            count: buckets[i],
                            fraction: buckets[i] / peak,
                            isPeak: buckets[i] == peak,
                            maxHeight: chartHeight,
                            color: gold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < buckets.length; i++)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _label(i, size),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(int i, int size) {
    final end = (i + 1) * size;
    return '${i * size + 1}-${end > pool.hardPity5 ? pool.hardPity5 : end}';
  }
}

/// One column: the count on top of a rounded, gradient bar that grows in. The
/// tallest column is drawn at full strength, the others softer.
class _Bar extends StatelessWidget {
  const _Bar({
    required this.count,
    required this.fraction,
    required this.isPeak,
    required this.maxHeight,
    required this.color,
  });

  final int count;
  final double fraction;
  final bool isPeak;
  final double maxHeight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final empty = count == 0;
    final strength = isPeak ? 1.0 : 0.72;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            empty ? '' : formatNumber(count),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: isPeak ? FontWeight.w800 : FontWeight.w600,
              color: isPeak ? color : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: empty ? 3 : (maxHeight - 20) * value + 4,
            decoration: BoxDecoration(
              gradient: empty
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withValues(alpha: strength),
                        color.withValues(alpha: strength * 0.45),
                      ],
                    ),
              color: empty
                  ? scheme.outlineVariant.withValues(alpha: 0.6)
                  : null,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(8),
                bottom: Radius.circular(empty ? 2 : 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Faint guide lines at the base, half and top of the plot area.
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (final f in const [0.0, 0.5, 1.0]) {
      final y = size.height * (1 - f);
      if (f == 0) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        continue;
      }
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
