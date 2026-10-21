import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/assets/assets.gen.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_segmented_control.dart';
import '../../../shared/widgets/error_card.dart';
import '../../info/presentation/item_sections.dart';
import '../challenge_providers.dart';
import '../domain/challenge_season.dart';
import '../domain/matrix_models.dart';
import 'challenge_markup.dart';
import 'challenge_widgets.dart';
import 'season_screen.dart';

/// Endstate Matrix, laid out like encore.moe: pick a cycle and a level, read
/// its buffs and target scores, then the bosses of each round, then the
/// character buffs of the cycle.
class MatrixScreen extends StatelessWidget {
  const MatrixScreen({super.key});

  @override
  Widget build(BuildContext context) => SeasonScreen(
    title: context.t.challenges.matrix,
    watchSeasons: (ref, lang) => ref.watch(matrixSeasonsProvider(lang)),
    retry: (ref, lang) => ref.invalidate(matrixSeasonsProvider(lang)),
    body: (season, lang) => _MatrixBody(season: season, lang: lang),
  );
}

class _MatrixBody extends ConsumerStatefulWidget {
  const _MatrixBody({required this.season, required this.lang});

  final ChallengeSeason season;
  final String lang;

  @override
  ConsumerState<_MatrixBody> createState() => _MatrixBodyState();
}

class _MatrixBodyState extends ConsumerState<_MatrixBody> {
  int? _level;
  int? _round;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final provider = matrixSeasonProvider(widget.season.id, widget.lang);
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
            if (data.levels.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text(t.challenges.empty)),
              );
            }
            final level = data.levels.firstWhere(
              (l) => l.id == _level,
              orElse: () => data.levels.first,
            );
            final rounds = level.rounds;
            final round = rounds.contains(_round) ? _round! : rounds.first;
            final waves = [
              for (final w in level.waves)
                if (w.round == round) w,
            ];
            return SliverMainAxisGroup(
              slivers: [
                if (data.levels.length > 1)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppSegmentedControl<int>(
                        segments: [
                          for (final (i, l) in data.levels.indexed)
                            AppSegment(
                              value: l.id,
                              label: l.name,
                              icon:
                                  (i == 0
                                          ? Assets.images.matrixStability
                                          : Assets.images.matrixSingularity)
                                      .image(width: 20, height: 20),
                            ),
                        ],
                        selected: level.id,
                        onChanged: (v) => setState(() {
                          _level = v;
                          _round = null;
                        }),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: _LevelBody(
                        level: level,
                        rounds: rounds,
                        round: round,
                        waves: waves,
                        onRound: (r) => setState(() => _round = r),
                      ),
                    ),
                  ),
                ),
                if (data.roles.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppCard(
                        padding: const EdgeInsets.all(16),
                        child: _RolesSection(roles: data.roles),
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

/// Lays [children] out in equal columns (as many as fit [minColumnWidth],
/// at most [maxColumns]; one on narrow widths). The cards of a row share the
/// height of the tallest.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.children,
    this.minColumnWidth = 280,
    this.maxColumns = 2,
  });

  final List<Widget> children;
  final double minColumnWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 12.0;
      final columns = (constraints.maxWidth / (minColumnWidth + gap))
          .floor()
          .clamp(1, maxColumns);
      return Column(
        children: [
          for (var i = 0; i < children.length; i += columns)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : gap),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var c = 0; c < columns; c++) ...[
                      if (c > 0) const SizedBox(width: gap),
                      Expanded(
                        child: i + c < children.length
                            ? children[i + c]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// The score targets in a grid of four columns (two when narrow), each entry
/// centred in its cell, as on the web page.
class _ScoreGrid extends StatelessWidget {
  const _ScoreGrid({required this.scores});

  final List<MatrixScore> scores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final number = NumberFormat.decimalPattern();
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 480 ? 4 : 2;
        return Column(
          children: [
            for (var i = 0; i < scores.length; i += columns)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
                child: Row(
                  children: [
                    for (var c = 0; c < columns; c++)
                      Expanded(
                        child: i + c < scores.length
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (scores[i + c].iconUrl != null)
                                    CachedNetworkImage(
                                      imageUrl: scores[i + c].iconUrl!,
                                      height: 40,
                                      fadeInDuration: Duration.zero,
                                      errorWidget: (_, _, _) =>
                                          const SizedBox(height: 40),
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    number.format(scores[i + c].value),
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A game icon: plain on the dark theme, where the art (drawn light) reads
/// as on the web page, and on a dark disc on the light theme.
class _Icon extends StatelessWidget {
  const _Icon(this.url, {required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return GameIcon(url, size: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: url == null
          ? null
          : CachedNetworkImage(
              imageUrl: url!,
              memCacheWidth: 160,
              fit: BoxFit.contain,
              fadeInDuration: Duration.zero,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
    );
  }
}

Decoration _panel(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surfaceContainerHighest
      .withValues(alpha: 0.5),
  borderRadius: BorderRadius.circular(context.tokens.radiusControl),
);

class _LevelBody extends StatelessWidget {
  const _LevelBody({
    required this.level,
    required this.rounds,
    required this.round,
    required this.waves,
    required this.onRound,
  });

  final MatrixLevel level;
  final List<int> rounds;
  final int round;
  final List<MatrixWave> waves;
  final ValueChanged<int> onRound;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (level.buffs.isNotEmpty) ...[
          SectionTitle(t.challenges.matrixBuffs, rule: false),
          _Grid(
            children: [
              for (final b in level.buffs)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: _panel(context),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Icon(b.iconUrl, size: 48),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 4),
                            MarkupText(
                              b.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        if (level.scores.isNotEmpty) ...[
          SectionTitle(t.challenges.targetScores, rule: false),
          _ScoreGrid(scores: level.scores),
          const SizedBox(height: 20),
        ],
        if (level.waves.isNotEmpty) ...[
          SectionTitle(t.challenges.info, rule: false),
          if (rounds.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppSegmentedControl<int>(
                segments: [
                  for (final r in rounds)
                    AppSegment(
                      value: r,
                      label: t.challenges.round(n: r),
                    ),
                ],
                selected: round,
                onChanged: onRound,
              ),
            ),
          for (final (i, w) in waves.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            _WaveCard(wave: w),
          ],
        ],
      ],
    );
  }
}

/// A boss: name and tags, rule, escalations and suggested buffs, with its art.
class _WaveCard extends StatelessWidget {
  const _WaveCard({required this.wave});

  final MatrixWave wave;

  static const _wideAt = 560.0;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget chip({
      required String label,
      String? iconUrl,
      Color? color,
      VoidCallback? onTap,
    }) => Material(
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null) ...[
                _Icon(iconUrl, size: 20),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(wave.name, style: theme.textTheme.titleLarge),
            for (final tag in wave.tags)
              chip(label: tag.name, iconUrl: tag.iconUrl, color: tag.color),
          ],
        ),
        if (wave.description != null) ...[
          const SizedBox(height: 8),
          MarkupText(
            wave.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        if (wave.escalations.isNotEmpty) ...[
          label(t.challenges.escalation),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in wave.escalations)
                chip(
                  label: e.title,
                  iconUrl: e.iconUrl,
                  color: e.color,
                  onTap: () =>
                      showAdaptiveSheet(context, (_) => _SkillSheet(skill: e)),
                ),
            ],
          ),
        ],
        if (wave.suggested.isNotEmpty) ...[
          label(t.challenges.suggestedBuff),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in wave.suggested)
                chip(label: s.title, iconUrl: s.iconUrl),
            ],
          ),
        ],
      ],
    );

    final image = wave.imageUrl == null
        ? null
        : CachedNetworkImage(
            imageUrl: wave.imageUrl!,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            fadeInDuration: Duration.zero,
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideAt;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: _panel(context),
          child: wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: text,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: image ?? const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (image != null) SizedBox(height: 150, child: image),
                    Padding(padding: const EdgeInsets.all(14), child: text),
                  ],
                ),
        );
      },
    );
  }
}

/// An escalation's name and effect, shown when its chip is tapped.
class _SkillSheet extends StatelessWidget {
  const _SkillSheet({required this.skill});

  final MatrixSkill skill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (skill.iconUrl != null) ...[
                _Icon(skill.iconUrl, size: 40),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  skill.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: skill.color,
                  ),
                ),
              ),
            ],
          ),
          if (skill.description != null) ...[
            const SizedBox(height: 12),
            Text(skill.description!, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}

/// "Character Buffs": the characters whose skills the cycle enhances.
class _RolesSection extends StatelessWidget {
  const _RolesSection({required this.roles});

  final List<MatrixRole> roles;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(t.challenges.characterBuffs, rule: false),
        _Grid(
          minColumnWidth: 240,
          maxColumns: 3,
          children: [
            for (final r in roles)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _panel(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Avatar(r.iconUrl, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            r.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    for (final s in r.skills) ...[
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: MarkupText(
                          s,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Round character head.
class _Avatar extends StatelessWidget {
  const _Avatar(this.url, {required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipOval(
    child: Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: url == null
          ? null
          : CachedNetworkImage(
              imageUrl: url!,
              memCacheWidth: 160,
              fit: BoxFit.cover,
              fadeInDuration: Duration.zero,
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
    ),
  );
}
