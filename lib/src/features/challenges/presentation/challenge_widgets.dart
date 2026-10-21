import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/challenge_models.dart';
import '../domain/challenge_season.dart';

String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _range(ChallengeSeason s) =>
    '${formatDate(s.start!)} – '
    '${formatDate(s.finish!.subtract(const Duration(days: 1)))}';

/// Name, dates and a status badge of the chosen season, with a button that
/// opens the season picker.
class SeasonHeader extends StatelessWidget {
  const SeasonHeader({
    super.key,
    required this.season,
    required this.seasons,
    required this.onSelected,
  });

  final ChallengeSeason season;
  final List<ChallengeSeason> seasons;
  final ValueChanged<ChallengeSeason> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();
    final badge = season.isCurrent(now)
        ? StatusBadge(
            label: t.challenges.current,
            background: scheme.primary,
            foreground: scheme.onPrimary,
          )
        : season.isUpcoming(now)
        ? StatusBadge(label: t.challenges.upcoming)
        : null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AppCard(
        // A soft wash of the accent; container roles are neutral grey in
        // Mornye, so tint the primary instead.
        color: Color.alphaBlend(
          scheme.primary.withValues(alpha: 0.14),
          scheme.surfaceContainerHigh,
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ?badge,
                  if (badge != null) const SizedBox(height: 6),
                  Text(
                    season.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  if (season.hasDates) ...[
                    const SizedBox(height: 2),
                    Text(
                      _range(season),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    if (season.group != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        season.group!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (season.endVersion != null)
                      Text(
                        t.challenges.endsVersion(version: season.endVersion!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (seasons.length > 1)
              IconButton.filledTonal(
                tooltip: t.challenges.changeSeason,
                icon: const AdaptiveIcon(Icons.swap_vert),
                onPressed: () => _pick(context),
              ),
          ],
        ),
      ),
    );
  }

  void _pick(BuildContext context) {
    final now = DateTime.now();
    showAdaptiveSheet(context, (sheetContext) {
      final t = sheetContext.t;
      final scheme = Theme.of(sheetContext).colorScheme;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              t.challenges.selectSeason,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          for (final s in seasons.reversed)
            ListTile(
              selected: s.id == season.id,
              title: Text(s.name),
              subtitle: s.hasDates
                  ? Text(_range(s))
                  : s.group != null
                  ? Text(s.group!)
                  : null,
              trailing: s.isCurrent(now)
                  ? StatusBadge(
                      label: t.challenges.current,
                      background: scheme.primary,
                      foreground: scheme.onPrimary,
                    )
                  : s.isUpcoming(now)
                  ? StatusBadge(label: t.challenges.upcoming)
                  : null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onSelected(s);
              },
            ),
        ],
      );
    });
  }
}

Color rarityColor(int? id) => switch (id) {
  1 => const Color(0xFF22C55E),
  2 => const Color(0xFF3B82F6),
  3 => const Color(0xFFA855F7),
  4 => const Color(0xFFEAB308),
  _ => const Color(0xFF6B7280),
};

/// An enemy tile: art with element icons on the corner, a rarity edge, the
/// name, and a +/- button that shows its stats.
class MonsterTile extends StatelessWidget {
  const MonsterTile({
    super.key,
    required this.monster,
    this.statsOpen = false,
    this.onToggleStats,
  });

  final ChallengeMonster monster;
  final bool statsOpen;

  /// Taps of the +/- button; the button only shows for monsters with stats.
  final VoidCallback? onToggleStats;

  static const _width = 80.0;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      width: _width,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: scheme.surfaceContainerHighest,
              child: Column(
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: monster.iconUrl == null
                            ? const SizedBox.shrink()
                            : CachedNetworkImage(
                                imageUrl: monster.iconUrl!,
                                memCacheWidth: 200,
                                fit: BoxFit.contain,
                                fadeInDuration: Duration.zero,
                                errorWidget: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Column(
                          children: [
                            for (final e in monster.elements)
                              if (e.iconUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Tooltip(
                                    message: e.name,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: e.iconUrl!,
                                        memCacheWidth: 48,
                                        fadeInDuration: Duration.zero,
                                        errorWidget: (_, _, _) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(height: 4, color: rarityColor(monster.rarityId)),
                  Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 5,
                    ),
                    child: Text(
                      monster.name,
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
          if (monster.stats.isNotEmpty && onToggleStats != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Tooltip(
                message: statsOpen
                    ? t.challenges.hideStats
                    : t.challenges.showStats,
                child: InkResponse(
                  onTap: onToggleStats,
                  radius: 20,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: AdaptiveIcon(
                      statsOpen ? Icons.remove : Icons.add,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The open enemy's attribute table.
class StatsTable extends StatelessWidget {
  const StatsTable({super.key, required this.monster});

  final ChallengeMonster monster;

  static final _number = NumberFormat.decimalPattern();

  static String _value(MonsterStat s) =>
      s.isPercent ? '${s.value}%' : _number.format(s.value);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.tokens.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(monster.name, style: theme.textTheme.titleSmall),
          if (monster.rarity != null)
            Text(
              monster.rarity!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.challenges.attribute,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                t.challenges.value,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Divider(height: 12, color: scheme.outlineVariant),
          for (final (i, s) in monster.stats.indexed)
            Container(
              color: i.isEven
                  ? scheme.surfaceContainerHighest.withValues(alpha: 0.4)
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  if (s.iconUrl != null) ...[
                    CachedNetworkImage(
                      imageUrl: s.iconUrl!,
                      width: 18,
                      height: 18,
                      memCacheWidth: 48,
                      fadeInDuration: Duration.zero,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      s.name == 'PropertyIndex_139_Name' ? 'Max Tune' : s.name,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    _value(s),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
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

/// A section title, with a rule under it unless [rule] is false.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.rule = true});

  final String text;
  final bool rule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: rule ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: theme.textTheme.titleLarge),
          if (rule) ...[
            const SizedBox(height: 8),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}
