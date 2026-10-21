import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/item_info.dart';
import '../domain/item_kind.dart';
import 'item_gallery.dart';
import 'item_sections.dart';

class _Stars extends StatelessWidget {
  const _Stars(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = rarityColor(Theme.of(context).colorScheme, count);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AdaptiveIcon(Icons.star, size: 18, color: color),
      ],
    );
  }
}

/// The details of an item: gallery, badges, effect, stats and skills. Shared by
/// the dialog and the guide's detail screen.
class ItemInfoBody extends StatelessWidget {
  const ItemInfoBody({
    super.key,
    required this.info,
    required this.resourceId,
    required this.lang,
  });

  final ItemInfo info;
  final int resourceId;

  /// Data language tag, for language-dependent bits such as the voice actor.
  final String lang;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = rarityColor(scheme, info.rarity);
    final isResonator = info.kind == ItemKind.resonator;

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: title),
        child,
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (info.gallery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ItemGalleryCard(
              groups: info.gallery,
              accent: color,
              shiftLeft: info.kind == ItemKind.weapon,
            ),
          )
        else if (info.imageUrl != null)
          Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: context.tokens.borderRadiusCard,
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: info.imageUrl!,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(child: M3ELoadingIndicator()),
              errorWidget: (_, _, _) => AdaptiveIcon(
                Icons.image_not_supported_outlined,
                color: color,
              ),
            ),
          ),
        Center(
          child: Text(
            info.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(child: _Stars(info.rarity)),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusBadge(label: isResonator ? t.info.resonator : t.info.weapon),
            if (info.elementName != null && info.elementName!.isNotEmpty)
              StatusBadge(
                label: '${t.info.element}: ${info.elementName}',
                background: scheme.tertiaryContainer,
                foreground: scheme.onTertiaryContainer,
              ),
            if (info.typeName != null && info.typeName!.isNotEmpty)
              StatusBadge(
                label: '${t.info.weaponType}: ${info.typeName}',
                background: scheme.primaryContainer,
                foreground: scheme.onPrimaryContainer,
              ),
          ],
        ),
        if (info.description != null)
          section(
            t.info.introduction,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(info.description!, style: theme.textTheme.bodyMedium),
            ),
          ),
        if (info.effectName != null || info.effectDescription != null)
          section(
            t.info.effect,
            SettingsGroup(
              children: [
                SettingsItem(
                  icon: Icons.auto_fix_high,
                  title: info.effectName ?? t.info.effect,
                  subtitle: info.effectDescription,
                  showDivider: false,
                ),
              ],
            ),
          ),
        if (info.stats.isNotEmpty)
          section(
            info.stats.any((s) => s.byLevel.isNotEmpty)
                ? t.info.baseStatsAtLevel
                : t.info.baseStats,
            _StatsGroup(stats: info.stats),
          ),
        if (info.skills.isNotEmpty)
          section(t.info.skills, ItemSkillsGroup(skills: info.skills)),
        if (info.chain.isNotEmpty)
          section(t.info.chain, ItemChainGroup(chain: info.chain)),
        if (info.profile != null)
          section(
            t.info.profile,
            ItemProfileGroup(profile: info.profile!, lang: lang),
          ),
        if (info.tags.isNotEmpty)
          section(
            t.info.tags,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in info.tags) StatusBadge(label: tag),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            t.info.source,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// Base stats. When they scale with level (weapons), a slider picks the level.
class _StatsGroup extends StatelessWidget {
  const _StatsGroup({required this.stats});

  final List<ItemStat> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.any((s) => s.byLevel.isNotEmpty)) {
      return _LevelStats(stats: stats);
    }
    return _rows(context, stats, null);
  }
}

Widget _rows(BuildContext context, List<ItemStat> stats, int? level) {
  final theme = Theme.of(context);
  return SettingsGroup(
    children: [
      for (final (i, s) in stats.indexed)
        SettingsItem(
          title: s.name,
          showDivider: i != stats.length - 1,
          trailing: Text(
            level == null ? s.value : s.valueAt(level),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );
}

class _LevelStats extends StatefulWidget {
  const _LevelStats({required this.stats});

  final List<ItemStat> stats;

  @override
  State<_LevelStats> createState() => _LevelStatsState();
}

class _LevelStatsState extends State<_LevelStats> {
  int _level = weaponMaxLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                context.t.info.level,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Slider(
                  min: weaponMinLevel.toDouble(),
                  max: weaponMaxLevel.toDouble(),
                  divisions: weaponMaxLevel - weaponMinLevel,
                  value: _level.toDouble(),
                  label: '$_level',
                  onChanged: (v) => setState(() => _level = v.round()),
                ),
              ),
            ],
          ),
        ),
        _rows(context, widget.stats, _level),
      ],
    );
  }
}
