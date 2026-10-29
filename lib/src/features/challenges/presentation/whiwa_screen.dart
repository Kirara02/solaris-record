import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_segmented_control.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../challenge_providers.dart';
import '../domain/challenge_models.dart';
import '../domain/challenge_season.dart';
import 'challenge_markup.dart';
import 'challenge_widgets.dart';
import 'season_screen.dart';

/// Whimpering Wastes, laid out like encore.moe: pick a floor number (the
/// groups run on through the numbers, e.g. 7-11 Chasm and 12 Torrents), then
/// read its rule, tokens, target scores and each stage's enemies.
class WhiwaScreen extends StatelessWidget {
  const WhiwaScreen({super.key});

  @override
  Widget build(BuildContext context) => SeasonScreen(
    title: context.t.challenges.whiwa,
    watchSeasons: (ref, lang) => ref.watch(whiwaSeasonsProvider(lang)),
    retry: (ref, lang) => ref.invalidate(whiwaSeasonsProvider(lang)),
    body: (season, lang) => _WhiwaBody(season: season, lang: lang),
  );
}

class _WhiwaBody extends ConsumerStatefulWidget {
  const _WhiwaBody({required this.season, required this.lang});

  final ChallengeSeason season;
  final String lang;

  @override
  ConsumerState<_WhiwaBody> createState() => _WhiwaBodyState();
}

class _WhiwaBodyState extends ConsumerState<_WhiwaBody> {
  int? _floor;

  /// Group names usually share a lead ("Respawning Waters: Chasm" and
  /// "...: Torrents"). On narrow screens only the rest labels the segments and
  /// the lead becomes a title; wide screens have room for the full names.
  static (String?, List<String>) _labels(List<WhiwaGroup> groups) {
    final names = [for (final g in groups) g.name];
    final cut = [for (final n in names) n.indexOf(': ')];
    if (names.length < 2 || cut.any((c) => c < 0)) return (null, names);
    final lead = names.first.substring(0, cut.first);
    if (!names.every((n) => n.startsWith('$lead: '))) return (null, names);
    return (lead, [for (final n in names) n.substring(lead.length + 2)]);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final provider = whiwaSeasonProvider(widget.season.id, widget.lang);
    final wide = MediaQuery.sizeOf(context).width >= _wideAt;
    return ref
        .watch(provider)
        .when(
          loading: () =>
              const SliverFillBody(child: Center(child: AppLoadingIndicator())),
          error: (_, _) => SliverToBoxAdapter(
            child: ErrorCard(
              message: t.challenges.error,
              retryLabel: t.import.retry,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
          data: (data) {
            final floors = data.floors;
            if (floors.isEmpty) {
              return SliverFillBody(
                child: Center(child: Text(t.challenges.empty)),
              );
            }
            final floor = floors.contains(_floor) ? _floor! : floors.first;
            final groupIndex = data.groups.indexWhere(
              (g) => g.levels.any((l) => l.orderIndex == floor),
            );
            final level = data.groups[groupIndex].levels.firstWhere(
              (l) => l.orderIndex == floor,
            );
            final tokens = [
              for (final b in data.buffs)
                if (b.orderIndex == floor) b,
            ];
            final (lead, labels) = _labels(data.groups);
            final short = !wide && lead != null;
            return SliverMainAxisGroup(
              slivers: [
                if (short)
                  SliverToBoxAdapter(child: SettingsSectionHeader(title: lead)),
                if (data.groups.length > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: short ? 0 : 12),
                      child: AppSegmentedControl<int>(
                        segments: [
                          for (final (i, g) in data.groups.indexed)
                            AppSegment(
                              value: i,
                              label: short ? labels[i] : g.name,
                            ),
                        ],
                        selected: groupIndex,
                        // A group opens on its first floor.
                        onChanged: (i) => setState(
                          () => _floor = data.groups[i].levels
                              .map((l) => l.orderIndex)
                              .reduce((a, b) => a < b ? a : b),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final f in floors)
                            _FloorButton(
                              floor: f,
                              selected: f == floor,
                              onTap: () => setState(() => _floor = f),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: _LevelCard(
                      level: level,
                      tokens: tokens,
                      lang: widget.lang,
                      wide: wide,
                    ),
                  ),
                ),
              ],
            );
          },
        );
  }
}

/// From this width the level's sections sit side by side, like the web page.
const _wideAt = 600.0;

class _FloorButton extends StatelessWidget {
  const _FloorButton({
    required this.floor,
    required this.selected,
    required this.onTap,
  });

  final int floor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.tokens.radiusControl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              '$floor',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The chosen floor: title and rule, then tokens and target scores, then the
/// stages. On wide screens the pairs sit side by side.
class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.tokens,
    required this.lang,
    required this.wide,
  });

  final WhiwaLevel level;
  final List<WhiwaBuff> tokens;
  final String lang;
  final bool wide;

  static String _scoreImage(String grade) =>
      'https://api.encore.moe/resource/Data/Game/Aki/UI/UIResources/UiActivity/'
      'Image/ActivityMowingTower/T_Score$grade.webp';

  /// [children] in a row of equal columns when [wide], else stacked.
  Widget _pair(List<Widget> children) {
    if (!wide || children.length < 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 20),
            c,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) const SizedBox(width: 24),
          Expanded(child: c),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final tokensColumn = tokens.isEmpty
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(t.challenges.tokens),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final b in tokens)
                    _TokenTile(
                      token: b,
                      onTap: () => showAdaptiveSheet(
                        context,
                        (_) => _BuffSheet(buff: b, lang: lang),
                      ),
                    ),
                ],
              ),
            ],
          );

    final scoresColumn = level.scores.isEmpty
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(t.challenges.targetScores),
              Wrap(
                spacing: 24,
                runSpacing: 12,
                children: [
                  for (final s in level.scores)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CachedNetworkImage(
                          imageUrl: _scoreImage(s.$1),
                          height: 22,
                          fadeInDuration: Duration.zero,
                          errorWidget: (_, _, _) => Text(
                            s.$1,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          NumberFormat.decimalPattern().format(s.$2),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          );

    Widget stage(int i, WhiwaStage s) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(t.challenges.stage(n: i + 1)),
        if (s.description != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(context.tokens.radiusControl),
            ),
            child: MarkupText(
              s.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        for (final b in s.buffs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (b.iconUrl != null) ...[
                  CachedNetworkImage(
                    imageUrl: b.iconUrl!,
                    width: 20,
                    height: 20,
                    memCacheWidth: 48,
                    fadeInDuration: Duration.zero,
                    errorWidget: (_, _, _) => const SizedBox(width: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: b.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (b.description != b.name)
                        Text(
                          b.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [for (final m in s.monsters) MonsterTile(monster: m)],
        ),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(level.title),
          if (level.description != null) ...[
            MarkupText(level.description!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
          ],
          if (tokensColumn != null || scoresColumn != null)
            _pair([?tokensColumn, ?scoresColumn]),
          if (level.stages.isNotEmpty) ...[
            const SizedBox(height: 20),
            _pair([for (final (i, s) in level.stages.indexed) stage(i, s)]),
          ],
        ],
      ),
    );
  }
}

Color _qualityColor(int? id) => switch (id) {
  2 => const Color(0xFF22C55E),
  3 => const Color(0xFF3B82F6),
  4 => const Color(0xFFA855F7),
  5 => const Color(0xFFEAB308),
  _ => const Color(0xFF6B7280),
};

/// A token: icon on a quality-coloured edge with its name; tap for details.
class _TokenTile extends StatelessWidget {
  const _TokenTile({required this.token, required this.onTap});

  final WhiwaBuff token;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: scheme.surfaceContainerHighest,
          child: InkWell(
            onTap: onTap,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: token.iconUrl == null
                      ? const SizedBox.shrink()
                      : CachedNetworkImage(
                          imageUrl: token.iconUrl!,
                          memCacheWidth: 200,
                          fit: BoxFit.contain,
                          fadeInDuration: Duration.zero,
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                ),
                Container(height: 4, color: _qualityColor(token.qualityId)),
                Container(
                  width: double.infinity,
                  color: Colors.black.withValues(alpha: 0.7),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  child: Text(
                    token.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// What a token does, loaded when it is tapped; the name and icon show at once.
class _BuffSheet extends ConsumerWidget {
  const _BuffSheet({required this.buff, required this.lang});

  final WhiwaBuff buff;
  final String lang;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final provider = whiwaBuffInfoProvider(buff.itemId, lang);
    final info = ref.watch(provider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: buff.iconUrl == null
                    ? null
                    : CachedNetworkImage(
                        imageUrl: buff.iconUrl!,
                        memCacheWidth: 128,
                        fadeInDuration: Duration.zero,
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(buff.name, style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 12),
          info.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: AppLoadingIndicator()),
            ),
            error: (_, _) => ErrorCard(
              message: t.challenges.error,
              retryLabel: t.import.retry,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data?.effect != null)
                  Text(data!.effect!, style: theme.textTheme.bodyLarge),
                if (data?.story != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    data!.story!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (data?.effect == null && data?.story == null)
                  Text(t.challenges.empty),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
