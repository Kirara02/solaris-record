import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/horizontal_scroll_area.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/item_name.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/overview_stats.dart';
import 'five_star_bubbles.dart';
import 'five_star_vertical_timeline.dart';

/// "MM/dd" from an API time string ("2025-01-26 12:00:40"), kept as-is (no
/// time-zone conversion), or the raw string if it doesn't match.
String shortDate(String time) {
  if (time.length >= 10 && time[4] == '-' && time[7] == '-') {
    return '${time.substring(5, 7)}/${time.substring(8, 10)}';
  }
  return time;
}

/// Horizontal timeline of every 5★, newest first, starting at a "Now" node
/// showing the pulls since the last one. Nodes are coloured by luck.
class FiveStarTimeline extends StatefulWidget {
  const FiveStarTimeline({
    super.key,
    required this.items,
    required this.pullsSinceLast,
    this.title,
    this.nowText,
    this.showPool = false,
  });

  /// Newest first. Each item carries its pull type, whose hard pity scales the
  /// luck colours.
  final List<TimelineItem> items;
  final int pullsSinceLast;

  /// Card title; defaults to the 5★ count.
  final String? title;

  /// Text of the "Now" row in the vertical view; defaults to the pulls since
  /// the last 5★.
  final String? nowText;

  /// Names the pull type on each vertical row (for several pull types).
  final bool showPool;

  @override
  State<FiveStarTimeline> createState() => _FiveStarTimelineState();
}

class _FiveStarTimelineState extends State<FiveStarTimeline> {
  static const double _nodeWidth = 92;

  bool _vertical = false;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: groupDecoration(context),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(Icons.timeline, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title ?? t.stats.timelineTitle(n: widget.items.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _vertical
                    ? t.stats.timelineHorizontal
                    : t.stats.timelineVertical,
                icon: AdaptiveIcon(
                  _vertical ? Icons.view_week_outlined : Icons.view_list,
                ),
                onPressed: () => setState(() => _vertical = !_vertical),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_vertical)
            FiveStarVerticalTimeline(
              items: widget.items,
              nowText:
                  widget.nowText ??
                  t.stats.sinceLastFive(n: widget.pullsSinceLast),
              showPool: widget.showPool,
            )
          else
            SizedBox(
              height: 140,
              child: HorizontalScrollArea(
                builder: (context, controller) => ListView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  // A null padding makes ListView add MediaQuery.padding, which
                  // on desktop includes the rail width (280) on the left.
                  padding: EdgeInsets.zero,
                  children: [
                    _TimelineNode(
                      width: _nodeWidth,
                      isFirst: true,
                      isLast: widget.items.isEmpty,
                      nodeColor: scheme.outline,
                      hollow: true,
                      top: Text(
                        t.stats.timelineNow,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: rarityColor(scheme, 5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      bottom: t.stats.pullsUsed(n: widget.pullsSinceLast),
                    ),
                    for (final (i, item) in widget.items.indexed)
                      _TimelineNode(
                        width: _nodeWidth,
                        onTap: () => showFiveStarDetail(
                          context,
                          item.entry,
                          threshold: item.pool.hardPity5,
                        ),
                        isFirst: false,
                        isLast: i == widget.items.length - 1,
                        nodeColor: luckNodeColor(
                          context,
                          luckTier(
                            item.entry.pullsUsed,
                            threshold: item.pool.hardPity5,
                          ),
                        ),
                        top: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ItemIcon(
                              resourceId: item.entry.resourceId,
                              resourceType: item.entry.resourceType,
                              rarity: 5,
                              size: 40,
                              circular: true,
                              ringColor: ringFor(context, item.entry.result),
                            ),
                            const SizedBox(height: 4),
                            ItemName(
                              resourceId: item.entry.resourceId,
                              fallback: item.entry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: luckNodeColor(
                                  context,
                                  luckTier(
                                    item.entry.pullsUsed,
                                    threshold: item.pool.hardPity5,
                                  ),
                                ),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // Date and pulls on separate lines so neighbours don't touch.
                        bottom:
                            '${shortDate(item.entry.time)}\n${t.stats.pullsUsed(n: item.entry.pullsUsed)}',
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final tier in LuckTier.values)
                _LegendDot(luckNodeColor(context, tier), switch (tier) {
                  LuckTier.lucky => t.stats.luckLucky,
                  LuckTier.average => t.stats.luckAverage,
                  LuckTier.unlucky => t.stats.luckUnlucky,
                }),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({
    required this.width,
    this.onTap,
    required this.isFirst,
    required this.isLast,
    required this.nodeColor,
    required this.top,
    required this.bottom,
    this.hollow = false,
  });

  final double width;
  final VoidCallback? onTap;
  final bool isFirst;
  final bool isLast;
  final Color nodeColor;
  final bool hollow;
  final Widget top;
  final String bottom;

  static const double _topHeight = 64;
  static const double _node = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final line = scheme.outlineVariant;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.tokens.radiusCover),
        child: Column(
          children: [
            SizedBox(
              height: _topHeight,
              child: Align(alignment: Alignment.bottomCenter, child: top),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: _node,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The connecting line runs through every node; the first and
                  // last only cover their inner half.
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isFirst ? Colors.transparent : line,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isLast ? Colors.transparent : line,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: _node,
                    height: _node,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hollow ? scheme.surface : nodeColor,
                      border: Border.all(
                        color: nodeColor,
                        width: hollow ? 3 : 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              bottom,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.25,
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
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
