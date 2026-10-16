import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/item_name.dart';
import '../../../shared/widgets/outlined_icon_button.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/table_pager.dart';
import '../../info/presentation/item_info_dialog.dart';
import '../domain/history_view.dart';
import '../domain/pity_calculator.dart';
import '../domain/pool_type.dart';
import '../item_names.dart';
import '../stats_providers.dart';
import 'five_star_bubbles.dart';
import 'five_star_timeline.dart';
import 'history_filter_dialog.dart';
import 'stat_cards.dart';

/// Slivers for one pool of one account: pity hero, overview, 5★ timeline and a
/// lazily built history list (histories can run into the thousands).
class PoolSlivers extends ConsumerWidget {
  const PoolSlivers({super.key, required this.uid, required this.pool});

  final String uid;
  final PoolType pool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final stats = ref.watch(poolStatsProvider(uid, pool));
    final records = ref.watch(recordsProvider(uid, pool)).value ?? const [];

    return stats.when(
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: M3ELoadingIndicator()),
      ),
      error: (e, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('$e')),
      ),
      data: (s) {
        if (s.total == 0) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.inbox_outlined,
              title: t.stats.noPulls,
            ),
          );
        }
        final history = numberedNewestFirst(records);
        return SliverAdaptivePadding(
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: _OverviewBlock(stats: s, pool: pool),
              ),
              _HistorySection(entries: history),
            ],
          ),
        );
      },
    );
  }
}

/// Pity cards, stat cards (total / 5★ / 4★), the 5★ timeline and the 5★ pull
/// bubbles, stacked at full width. The stat cards and the pity row reflow with
/// the available width.
class _OverviewBlock extends StatelessWidget {
  const _OverviewBlock({required this.stats, required this.pool});

  final PoolStats stats;
  final PoolType pool;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final hasFives = stats.fiveStarHistory.isNotEmpty;
    final newestFirst = stats.fiveStarHistory.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _PityHero(stats: stats, pool: pool),
        SettingsSectionHeader(title: t.stats.sectionOverview),
        StatCardsRow(stats: stats, pool: pool),
        const SizedBox(height: 16),
        FiveStarTimeline(
          entries: newestFirst,
          pullsSinceLast: stats.pity5,
          threshold: pool.hardPity5,
          pool: pool,
        ),
        if (hasFives) ...[
          SettingsSectionHeader(title: t.stats.fiveStarTimeline),
          FiveStarBubbles(entries: newestFirst, pool: pool),
        ],
      ],
    );
  }
}

class _PityHero extends StatelessWidget {
  const _PityHero({required this.stats, required this.pool});

  final PoolStats stats;
  final PoolType pool;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final cards = [
      _PityCard(
        title: t.stats.fiveStarPity,
        value: stats.pity5,
        max: pool.hardPity5,
        accent: rarityColor(scheme, 5),
        container: scheme.tertiaryContainer,
        onContainer: scheme.onTertiaryContainer,
      ),
      _PityCard(
        title: t.stats.fourStarPity,
        value: stats.pity4,
        max: hardPity4,
        accent: rarityColor(scheme, 4),
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 340) {
          return Column(
            children: [cards[0], const SizedBox(height: 12), cards[1]],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        );
      },
    );
  }
}

class _PityCard extends StatelessWidget {
  const _PityCard({
    required this.title,
    required this.value,
    required this.max,
    required this.accent,
    required this.container,
    required this.onContainer,
  });

  final String title;
  final int value;
  final int max;
  final Color accent;
  final Color container;
  final Color onContainer;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final text = Theme.of(context).textTheme;
    return AppCard(
      color: container,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(title, style: text.labelLarge?.copyWith(color: onContainer)),
          const SizedBox(height: 16),
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: M3EProgressIndicator.circular(
                    value: (value / max).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    color: accent,
                    trackColor: onContainer.withValues(alpha: 0.15),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value',
                      style: text.headlineMedium?.copyWith(
                        color: onContainer,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ $max',
                      style: text.labelMedium?.copyWith(
                        color: onContainer.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            t.stats.pullsUntilHard(n: (max - value).clamp(0, max)),
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: onContainer),
          ),
        ],
      ),
    );
  }
}

/// History with a name search, a filter dialog and numbered pages. State lives
/// here, and the parent keys [PoolSlivers] by account and pool, so it resets on
/// either change.
class _HistorySection extends ConsumerStatefulWidget {
  const _HistorySection({required this.entries});

  /// Newest first, numbered over the whole pool.
  final List<HistoryEntry> entries;

  @override
  ConsumerState<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends ConsumerState<_HistorySection> {
  final _headerKey = GlobalKey();
  final _search = TextEditingController();
  HistoryFilter _filter = const HistoryFilter();
  int _page = 0;
  int _pageSize = historyPageSize;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setFilter(HistoryFilter filter) => setState(() {
    _filter = filter;
    _page = 0;
  });

  Future<void> _openFilterDialog() async {
    final result = await showHistoryFilterDialog(
      context,
      current: _filter,
      entries: widget.entries,
    );
    if (result != null) _setFilter(result);
  }

  void _clearAll() {
    _search.clear();
    _setFilter(const HistoryFilter());
  }

  void _goTo(int page) {
    setState(() => _page = page);
    // Without this the viewport would stay at the old page's bottom. Scrolled
    // by hand because Scrollable.ensureVisible didn't move the nested sliver
    // group here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _headerKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final target = ctx.findRenderObject();
      if (target == null) return;
      final position = Scrollable.of(ctx).position;
      final pinnedBar = kToolbarHeight + MediaQuery.paddingOf(ctx).top;
      final offset =
          RenderAbstractViewport.of(target)
              .getOffsetToReveal(target, 0)
              .offset -
          pinnedBar;
      position.animateTo(
        offset.clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: context.tokens.motionMedium,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final resolve = ref.watch(itemNameResolverProvider);
    final page = paginateHistory(
      widget.entries,
      nameOf: (r) => resolve(r.resourceId, r.name),
      filter: _filter,
      page: _page,
      pageSize: _pageSize,
    );

    // One removable chip per active dialog option.
    final active = <(String, VoidCallback)>[
      if (_filter.rarities.isNotEmpty)
        (
          [
            for (final r in [5, 4, 3])
              if (_filter.rarities.contains(r)) '$r★',
          ].join(' · '),
          () => _setFilter(_filter.copyWith(rarities: {})),
        ),
      if (_filter.types.isNotEmpty)
        (
          _filter.types.join(' · '),
          () => _setFilter(_filter.copyWith(types: {})),
        ),
      if (!_filter.isDefaultSort)
        (
          _filter.sortField == HistorySortField.time
              ? t.stats.sortOldest
              : '${sortFieldLabel(t, _filter.sortField)} '
                    '${_filter.newestFirst ? '↓' : '↑'}',
          () => _setFilter(
            _filter.copyWith(
              sortField: HistorySortField.time,
              newestFirst: true,
            ),
          ),
        ),
    ];

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          // Keyed on a box (not the sliver) so the scroll target can be found.
          child: KeyedSubtree(
            key: _headerKey,
            child: SettingsSectionHeader(
              title: t.stats.history,
              trailing: Text(
                page.matching == 1
                    ? t.stats.resultsOne(n: 1)
                    : t.stats.results(n: page.matching),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _search,
                  hint: t.stats.searchHint,
                  outlined: true,
                  prefix: const Icon(Icons.search),
                  suffix: _filter.query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            _setFilter(_filter.copyWith(query: ''));
                          },
                        ),
                  onChanged: (v) => _setFilter(_filter.copyWith(query: v)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedIconButton(
                tooltip: t.stats.filter,
                icon: Icons.filter_alt_outlined,
                badge: _filter.dialogCount,
                size: 56,
                onPressed: _openFilterDialog,
              ),
            ],
          ),
        ),
        if (active.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final (label, onRemove) in active)
                    InputChip(label: Text(label), onDeleted: onRemove),
                  TextButton(
                    onPressed: _clearAll,
                    child: Text(t.stats.clearFilters),
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (page.matching == 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  t.stats.noMatches,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else ...[
          _HistorySliver(items: page.items),
          SliverToBoxAdapter(
            child: TablePager(
              page: page.page,
              pageCount: page.pageCount,
              pageSize: _pageSize,
              total: page.matching,
              onPageChanged: _goTo,
              onPageSizeChanged: (size) => setState(() {
                _pageSize = size;
                _page = 0;
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _HistorySliver extends StatelessWidget {
  const _HistorySliver({required this.items});

  /// Width from which history rows switch from a list to a column grid.
  static const twoColumnBreakpoint = 1000.0;

  final List<HistoryEntry> items;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    return DecoratedSliver(
      decoration: BoxDecoration(
        color: groupColor(context),
        borderRadius: tokens.borderRadiusCard,
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            Widget row(int i) => _HistoryRow(entry: items[i]);
            // Wide windows lay the rows out in columns of at most 640px, so
            // a 2560px monitor gets four instead of two very long rows.
            if (constraints.crossAxisExtent >= twoColumnBreakpoint) {
              return SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 640,
                  mainAxisExtent: 60,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => row(i),
              );
            }
            return SliverList.builder(
              itemCount: items.length,
              itemBuilder: (context, i) => row(i),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final record = entry.record;
    final number = entry.number;
    final theme = Theme.of(context);
    final color = rarityColor(theme.colorScheme, record.rarity);
    final notable = record.rarity >= 4;
    return InkWell(
      onTap: record.resourceId > 0
          ? () => showItemInfo(
              context,
              resourceId: record.resourceId,
              resourceType: record.resourceType,
              name: record.name,
              rarity: record.rarity,
            )
          : null,
      child: Container(
        color: record.rarity == 5 ? color.withValues(alpha: 0.08) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ItemIcon(
              resourceId: record.resourceId,
              resourceType: record.resourceType,
              rarity: record.rarity,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: ItemName(
                          resourceId: record.resourceId,
                          fallback: record.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: notable ? FontWeight.w600 : null,
                            color: notable ? color : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.resourceType.isEmpty
                            ? '${record.rarity}★'
                            : '${record.rarity}★ · ${record.resourceType}',
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    record.time,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t.stats.pullNumber(n: number),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  t.stats.pityShort(n: entry.pity),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: record.rarity >= 5
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
