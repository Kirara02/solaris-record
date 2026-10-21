import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_segmented_control.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../info/presentation/item_sections.dart';
import '../challenge_providers.dart';
import '../domain/challenge_models.dart';
import '../domain/challenge_season.dart';
import 'challenge_widgets.dart';
import 'season_screen.dart';

/// Tower of Adversity, laid out like encore.moe: pick a season and a tower,
/// read the buffs and objectives shared by its floors, then each floor with its
/// enemies (tap + to see an enemy's stats).
class TowerScreen extends StatelessWidget {
  const TowerScreen({super.key});

  @override
  Widget build(BuildContext context) => SeasonScreen(
    title: context.t.challenges.tower,
    watchSeasons: (ref, lang) => ref.watch(towerSeasonsProvider(lang)),
    retry: (ref, lang) => ref.invalidate(towerSeasonsProvider(lang)),
    body: (season, lang) => _TowerBody(season: season, lang: lang),
  );
}

class _TowerBody extends ConsumerStatefulWidget {
  const _TowerBody({required this.season, required this.lang});

  final ChallengeSeason season;
  final String lang;

  @override
  ConsumerState<_TowerBody> createState() => _TowerBodyState();
}

class _TowerBodyState extends ConsumerState<_TowerBody> {
  int _area = 0;

  /// The enemy whose stats are open ("floor/index"); one at a time, as on the
  /// web page.
  String? _openStats;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final provider = towerSeasonProvider(widget.season.id, widget.lang);
    return ref
        .watch(provider)
        .when(
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: M3ELoadingIndicator()),
          ),
          error: (_, _) => SliverToBoxAdapter(
            child: ErrorCard(
              message: t.challenges.error,
              retryLabel: t.import.retry,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
          data: (data) {
            if (data.areas.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(t.challenges.empty)),
              );
            }
            final index = _area.clamp(0, data.areas.length - 1);
            final area = data.areas[index];
            return SliverMainAxisGroup(
              slivers: [
                if (data.areas.length > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppSegmentedControl<int>(
                        segments: [
                          for (final (i, a) in data.areas.indexed)
                            AppSegment(value: i, label: a.name),
                        ],
                        selected: index,
                        onChanged: (v) => setState(() {
                          _area = v;
                          _openStats = null;
                        }),
                      ),
                    ),
                  ),
                if (area.buffGroups.isNotEmpty || area.targetGroups.isNotEmpty)
                  SliverToBoxAdapter(child: _EffectsCard(area: area)),
                SliverList.separated(
                  itemCount: area.stages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _FloorCard(
                    stage: area.stages[i],
                    openStats: _openStats,
                    onToggleStats: (key) => setState(
                      () => _openStats = _openStats == key ? null : key,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        );
  }
}

/// "Tower Buffs" and "Targets", each grouped by the floors it applies to and
/// folded until its heading is tapped (the texts are long).
class _EffectsCard extends StatefulWidget {
  const _EffectsCard({required this.area});

  final TowerArea area;

  @override
  State<_EffectsCard> createState() => _EffectsCardState();
}

class _EffectsCardState extends State<_EffectsCard> {
  // Null until the user taps: then it follows the width (open when wide).
  bool? _buffsOpen;
  bool? _targetsOpen;

  /// From this card width the two sections sit side by side, as on the web.
  static const _wideAt = 560.0;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final area = widget.area;

    Widget section({
      required String title,
      required List<TowerEffectGroup> groups,
      required bool open,
      required VoidCallback onToggle,
      required bool wide,
      required bool centered,
    }) => Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                if (wide) const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    textAlign: wide ? TextAlign.center : TextAlign.start,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                AdaptiveIcon(
                  open ? Icons.expand_less : Icons.expand_more,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: open
              ? Column(
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.stretch
                      : CrossAxisAlignment.start,
                  children: [
                    for (final g in groups) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 6),
                        child: Text(
                          t.challenges.floors(range: g.floorLabel),
                          textAlign: wide ? TextAlign.center : TextAlign.start,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      for (final e in g.effects)
                        _effect(context, e, centered: centered && wide),
                    ],
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _wideAt;
            final buffsOpen = _buffsOpen ?? wide;
            final targetsOpen = _targetsOpen ?? wide;
            final buffs = area.buffGroups.isEmpty
                ? null
                : section(
                    title: t.challenges.towerBuffs,
                    groups: area.buffGroups,
                    open: buffsOpen,
                    onToggle: () => setState(() => _buffsOpen = !buffsOpen),
                    wide: wide,
                    centered: false,
                  );
            final targets = area.targetGroups.isEmpty
                ? null
                : section(
                    title: t.challenges.targets,
                    groups: area.targetGroups,
                    open: targetsOpen,
                    onToggle: () => setState(() => _targetsOpen = !targetsOpen),
                    wide: wide,
                    centered: true,
                  );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (buffs != null) Expanded(child: buffs),
                  if (buffs != null && targets != null)
                    const SizedBox(width: 24),
                  if (targets != null) Expanded(child: targets),
                ],
              );
            }
            return Column(
              children: [
                ?buffs,
                if (buffs != null && targets != null)
                  Divider(height: 8, color: scheme.outlineVariant),
                ?targets,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _effect(BuildContext context, TowerEffect e, {bool centered = false}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.tokens.radiusControl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (e.iconUrl != null) ...[
            GameIcon(e.iconUrl, size: 28),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              e.text,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// One floor: its background with the cost, then the enemies.
class _FloorCard extends StatelessWidget {
  const _FloorCard({
    required this.stage,
    required this.openStats,
    required this.onToggleStats,
  });

  final TowerStage stage;
  final String? openStats;
  final ValueChanged<String> onToggleStats;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final open = stage.monsters.indexed
        .where((e) => openStats == '${stage.floor}/${e.$1}')
        .map((e) => e.$2)
        .firstOrNull;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: scheme.surfaceContainerHighest),
                if (stage.backgroundUrl != null)
                  CachedNetworkImage(
                    imageUrl: stage.backgroundUrl!,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration.zero,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: StatusBadge(
                    label: t.challenges.cost(n: stage.cost),
                    background: scheme.primary,
                    foreground: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.challenges.floor(n: stage.floor),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final (i, m) in stage.monsters.indexed)
                        MonsterTile(
                          monster: m,
                          statsOpen: openStats == '${stage.floor}/$i',
                          onToggleStats: () =>
                              onToggleStats('${stage.floor}/$i'),
                        ),
                    ],
                  ),
                ),
                if (open != null && open.stats.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  StatsTable(monster: open),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
