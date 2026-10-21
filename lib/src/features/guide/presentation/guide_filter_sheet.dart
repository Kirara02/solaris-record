import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../domain/guide_entry.dart';
import 'echo_labels.dart';

/// The facets a guide list is narrowed by. Empty sets mean "any".
class GuideFilter {
  final elements = <GuideFacet>{};
  final weapons = <GuideFacet>{};
  final sonatas = <GuideFacet>{};
  final rarities = <int>{};

  int get count =>
      elements.length + weapons.length + sonatas.length + rarities.length;

  void clear() {
    elements.clear();
    weapons.clear();
    sonatas.clear();
    rarities.clear();
  }

  bool matches(GuideEntry e) =>
      (elements.isEmpty ||
          (e.element != null && elements.contains(e.element))) &&
      (weapons.isEmpty || (e.weapon != null && weapons.contains(e.weapon))) &&
      (sonatas.isEmpty || e.sets.any(sonatas.contains)) &&
      (rarities.isEmpty || rarities.contains(e.rarity));
}

/// Opens the filter sheet. Choices apply to [filter] right away and
/// [onChanged] lets the grid behind the sheet follow.
Future<void> showGuideFilterSheet(
  BuildContext context, {
  required GuideKind kind,
  required List<GuideEntry> entries,
  required GuideFilter filter,
  required VoidCallback onChanged,
}) => showAdaptiveSheet(
  context,
  (_) => _FilterBody(
    kind: kind,
    entries: entries,
    filter: filter,
    onChanged: onChanged,
  ),
);

List<GuideFacet> _facets(
  List<GuideEntry> entries,
  Iterable<GuideFacet> Function(GuideEntry) pick,
) {
  final byName = {
    for (final e in entries)
      for (final f in pick(e)) f.name: f,
  };
  return byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
}

class _FilterBody extends StatefulWidget {
  const _FilterBody({
    required this.kind,
    required this.entries,
    required this.filter,
    required this.onChanged,
  });

  final GuideKind kind;
  final List<GuideEntry> entries;
  final GuideFilter filter;
  final VoidCallback onChanged;

  @override
  State<_FilterBody> createState() => _FilterBodyState();
}

class _FilterBodyState extends State<_FilterBody> {
  void _toggle<T>(Set<T> set, T value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final filter = widget.filter;
    final kind = widget.kind;
    final entries = widget.entries;

    final rarities = ({for (final e in entries) e.rarity}.toList()
      ..sort((a, b) => b.compareTo(a)));

    Widget section(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: theme.textTheme.titleSmall),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );

    Widget facetChip(Set<GuideFacet> set, GuideFacet f) => _FilterChip(
      label: f.name,
      iconUrl: f.iconUrl,
      selected: set.contains(f),
      onTap: () => _toggle(set, f),
    );

    final elements = _facets(entries, (e) => [?e.element]);
    final weapons = _facets(entries, (e) => [?e.weapon]);
    final sonatas = _facets(entries, (e) => e.sets);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.guide.filter, style: theme.textTheme.titleLarge),
              ),
              IconButton(
                tooltip: t.guide.reset,
                icon: const AdaptiveIcon(Icons.refresh),
                onPressed: filter.count == 0
                    ? null
                    : () {
                        setState(filter.clear);
                        widget.onChanged();
                      },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (kind != GuideKind.weapon && elements.isNotEmpty)
            section(t.guide.element, [
              for (final f in elements) facetChip(filter.elements, f),
            ]),
          if (kind != GuideKind.echo && weapons.isNotEmpty)
            section(t.guide.weapon, [
              for (final f in weapons) facetChip(filter.weapons, f),
            ]),
          if (kind == GuideKind.echo && sonatas.isNotEmpty)
            section(t.guide.sonata, [
              for (final f in sonatas) facetChip(filter.sonatas, f),
            ]),
          section(kind == GuideKind.echo ? t.guide.kClass : t.guide.rarity, [
            for (final r in rarities)
              _FilterChip(
                label: kind == GuideKind.echo ? echoClassLabel(t, r) : '$r',
                star: kind == GuideKind.echo ? null : theme.colorScheme,
                starRarity: r,
                selected: filter.rarities.contains(r),
                onTap: () => _toggle(filter.rarities, r),
              ),
          ]),
        ],
      ),
    );
  }
}

/// Outlined pill with an optional game icon (or a rarity star); filled with
/// the primary container when selected.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconUrl,
    this.star,
    this.starRarity = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iconUrl;

  /// Set to draw a rarity star in front of the label.
  final ColorScheme? star;
  final int starRarity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.tokens.radiusControl);
    final fg = selected ? scheme.onSecondaryContainer : scheme.onSurface;
    return Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? Colors.transparent : scheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null) ...[
                // Game icons are drawn light; a dark disc keeps them readable
                // on any theme.
                Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: iconUrl!,
                    memCacheWidth: 64,
                    fadeInDuration: Duration.zero,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(label, style: TextStyle(color: fg)),
              if (star != null) ...[
                const SizedBox(width: 4),
                AdaptiveIcon(
                  Icons.star,
                  size: 18,
                  color: rarityColor(star!, starRarity),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
