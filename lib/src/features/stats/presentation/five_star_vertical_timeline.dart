import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/item_name.dart';
import '../domain/overview_stats.dart';
import 'five_star_bubbles.dart';
import 'five_star_timeline.dart';

/// Vertical timeline of 5★ pulls (newest first) under a "Now" row, colored by
/// luck. Long histories show a page at a time with a "show more" button.
class FiveStarVerticalTimeline extends StatefulWidget {
  const FiveStarVerticalTimeline({
    super.key,
    required this.items,
    required this.nowText,
    this.showPool = false,
  });

  final List<TimelineItem> items;

  /// Text of the "Now" row, e.g. the pulls since the last 5★.
  final String nowText;

  /// Names the pull type on each row (for timelines spanning several).
  final bool showPool;

  @override
  State<FiveStarVerticalTimeline> createState() =>
      _FiveStarVerticalTimelineState();
}

class _FiveStarVerticalTimelineState extends State<FiveStarVerticalTimeline> {
  static const _pageSize = 10;

  int _shown = _pageSize;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final visible = widget.items.take(_shown).toList();
    final remaining = widget.items.length - visible.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VerticalRow(
          isFirst: true,
          isLast: visible.isEmpty,
          hollow: true,
          nodeColor: scheme.outline,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              '${t.stats.timelineNow} · ${widget.nowText}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: rarityColor(scheme, 5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        for (final (i, item) in visible.indexed)
          _VerticalRow(
            isFirst: false,
            isLast: remaining == 0 && i == visible.length - 1,
            nodeColor: luckNodeColor(
              scheme,
              luckTier(item.entry.pullsUsed, threshold: item.pool.hardPity5),
            ),
            onTap: () => showFiveStarDetail(
              context,
              item.entry,
              threshold: item.pool.hardPity5,
            ),
            child: _ItemContent(item: item, showPool: widget.showPool),
          ),
        if (remaining > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 28),
              child: TextButton(
                onPressed: () => setState(() => _shown += _pageSize),
                child: Text(t.stats.timelineLoadMore(n: remaining)),
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemContent extends StatelessWidget {
  const _ItemContent({required this.item, required this.showPool});

  final TimelineItem item;
  final bool showPool;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final e = item.entry;
    final tint = luckNodeColor(
      scheme,
      luckTier(e.pullsUsed, threshold: item.pool.hardPity5),
    );
    final when = shortDate(e.time);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ItemIcon(
            resourceId: e.resourceId,
            resourceType: e.resourceType,
            rarity: 5,
            size: 40,
            circular: true,
            ringColor: ringFor(scheme, e.result),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemName(
                  resourceId: e.resourceId,
                  fallback: e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  showPool ? '${item.pool.label(t)} · $when' : when,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t.stats.pullsUsed(n: e.pullsUsed),
            style: theme.textTheme.labelLarge?.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// One timeline row: the node and its connecting line on the left, [child] on
/// the right. The first and last rows only draw their inner half of the line.
class _VerticalRow extends StatelessWidget {
  const _VerticalRow({
    required this.isFirst,
    required this.isLast,
    required this.nodeColor,
    required this.child,
    this.hollow = false,
    this.onTap,
  });

  final bool isFirst;
  final bool isLast;
  final Color nodeColor;
  final bool hollow;
  final VoidCallback? onTap;
  final Widget child;

  static const double _node = 14;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final line = scheme.outlineVariant;

    Widget segment(bool visible) => Expanded(
      child: Center(
        child: Container(width: 2, color: visible ? line : Colors.transparent),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  segment(!isFirst),
                  Container(
                    width: _node,
                    height: _node,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hollow ? scheme.surface : nodeColor,
                      border: Border.all(color: nodeColor, width: 2),
                    ),
                  ),
                  segment(!isLast),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
