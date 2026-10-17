import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/artwork_palette.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/item_icon.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../settings/settings_providers.dart';
import '../domain/encore_links.dart';
import '../domain/item_info.dart';
import '../domain/item_kind.dart';
import 'item_gallery.dart';

/// Opens reference info (element, skills, weapon effect, ...) for a resonator
/// or weapon. This is about the item itself, not the pull that produced it.
Future<void> showItemInfo(
  BuildContext context, {
  required int resourceId,
  required String resourceType,
  required String name,
  required int rarity,
}) => showContentDialog<void>(
  context,
  (context) => ItemInfoDialog(
    resourceId: resourceId,
    resourceType: resourceType,
    fallbackName: name,
    rarity: rarity,
  ),
);

class ItemInfoDialog extends ConsumerWidget {
  const ItemInfoDialog({
    super.key,
    required this.resourceId,
    required this.resourceType,
    required this.fallbackName,
    required this.rarity,
  });

  /// Key of the "View on encore.moe" button, for tests.
  static const viewOnEncoreKey = ValueKey('item-info-view-on-encore');

  final int resourceId;
  final String resourceType;

  /// Name from the pull record, shown until (or instead of) the fetched one.
  final String fallbackName;
  final int rarity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final provider = itemInfoProvider(resourceId, resourceType, lang);
    final info = ref.watch(provider);
    // The encore.moe page of this item (null when it isn't a resonator/weapon).
    final link = encoreItemUrlFor(resourceId, resourceType, lang);

    return ArtworkAccent(
      resourceId: resourceId,
      resourceType: resourceType,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.info.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t.info.close,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: info.when(
                    loading: () => _Loading(
                      resourceId: resourceId,
                      resourceType: resourceType,
                      name: fallbackName,
                      rarity: rarity,
                    ),
                    error: (_, _) => ErrorCard(
                      message: t.info.error,
                      retryLabel: t.import.retry,
                      onRetry: () => ref.invalidate(provider),
                    ),
                    data: (data) => data == null
                        ? _NoInfo(
                            resourceId: resourceId,
                            resourceType: resourceType,
                            name: fallbackName,
                            rarity: rarity,
                          )
                        : _InfoBody(info: data, resourceId: resourceId),
                  ),
                ),
              ),
              if (link != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: M3EButton(
                    key: ItemInfoDialog.viewOnEncoreKey,
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.md,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(t.info.viewOnEncore),
                    onPressed: () => _open(context, ref, link),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Opens [url] in the browser; says so when that isn't possible.
  Future<void> _open(BuildContext context, WidgetRef ref, String url) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final failed = context.t.info.openFailed;
    final opened = await ref.read(urlOpenerProvider).open(Uri.parse(url));
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(failed)));
    }
  }
}

class _Loading extends StatelessWidget {
  const _Loading({
    required this.resourceId,
    required this.resourceType,
    required this.name,
    required this.rarity,
  });

  final int resourceId;
  final String resourceType;
  final String name;
  final int rarity;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(
        resourceId: resourceId,
        resourceType: resourceType,
        name: name,
        rarity: rarity,
      ),
      const SizedBox(height: 24),
      const M3ELoadingIndicator(),
      const SizedBox(height: 16),
    ],
  );
}

class _NoInfo extends StatelessWidget {
  const _NoInfo({
    required this.resourceId,
    required this.resourceType,
    required this.name,
    required this.rarity,
  });

  final int resourceId;
  final String resourceType;
  final String name;
  final int rarity;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(
        resourceId: resourceId,
        resourceType: resourceType,
        name: name,
        rarity: rarity,
      ),
      const SizedBox(height: 16),
      Text(
        context.t.info.notFound,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ],
  );
}

/// Round icon, name and stars: what we know before the details arrive.
class _Header extends StatelessWidget {
  const _Header({
    required this.resourceId,
    required this.resourceType,
    required this.name,
    required this.rarity,
  });

  final int resourceId;
  final String resourceType;
  final String name;
  final int rarity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ItemIcon(
          resourceId: resourceId,
          resourceType: resourceType,
          rarity: rarity,
          size: 96,
          circular: true,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: rarityColor(theme.colorScheme, rarity),
          ),
        ),
        const SizedBox(height: 4),
        _Stars(rarity),
      ],
    );
  }
}

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
          Icon(Icons.star, size: 18, color: color),
      ],
    );
  }
}

class _InfoBody extends StatelessWidget {
  const _InfoBody({required this.info, required this.resourceId});

  final ItemInfo info;
  final int resourceId;

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
            child: ItemGalleryCard(groups: info.gallery, accent: color),
          )
        else if (info.imageUrl != null)
          Container(
            height: 220,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: info.imageUrl!,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(child: M3ELoadingIndicator()),
              errorWidget: (_, _, _) =>
                  Icon(Icons.image_not_supported_outlined, color: color),
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
          section(
            t.info.skills,
            SettingsGroup(
              children: [
                for (final (i, s) in info.skills.indexed)
                  SettingsItem(
                    title: s.name,
                    subtitle: s.type,
                    showDivider: i != info.skills.length - 1,
                  ),
              ],
            ),
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
