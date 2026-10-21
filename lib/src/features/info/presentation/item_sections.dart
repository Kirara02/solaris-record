import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/theme/mornye_theme.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/item_info.dart';

/// Game icon on a dark disc: the art is drawn light, so the backing keeps it
/// readable in both themes.
class GameIcon extends StatelessWidget {
  const GameIcon(this.url, {super.key, this.size = 40});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.14),
    decoration: const BoxDecoration(
      color: Colors.black87,
      shape: BoxShape.circle,
    ),
    child: url == null
        ? null
        : CachedNetworkImage(
            imageUrl: url!,
            memCacheWidth: 128,
            fadeInDuration: Duration.zero,
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
  );
}

/// A row with a game icon, a title and a description that folds to a few
/// lines until it is tapped.
class _DetailRow extends StatefulWidget {
  const _DetailRow({
    required this.title,
    this.overline,
    this.description,
    this.iconUrl,
    this.showDivider = true,
  });

  final String title;
  final String? overline;
  final String? description;
  final String? iconUrl;
  final bool showDivider;

  @override
  State<_DetailRow> createState() => _DetailRowState();
}

class _DetailRowState extends State<_DetailRow> {
  static const _foldedLines = 3;
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final description = widget.description;
    final long =
        description != null &&
        (description.length > 110 || description.contains('\n'));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: long ? () => setState(() => _open = !_open) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.rowPaddingH,
              vertical: tokens.rowPaddingV,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GameIcon(widget.iconUrl),
                SizedBox(width: tokens.rowIconGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.overline != null)
                        Text(
                          widget.overline!,
                          style: text.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      Text(widget.title, style: text.bodyLarge),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          alignment: Alignment.topCenter,
                          child: Text(
                            description,
                            maxLines: long && !_open ? _foldedLines : null,
                            overflow: long && !_open
                                ? TextOverflow.ellipsis
                                : null,
                            style: text.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (long) ...[
                  const SizedBox(width: 8),
                  AdaptiveIcon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: context.isMornye ? 20 : 24,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(
            height: 1,
            indent: tokens.rowIconDividerIndent,
            endIndent: tokens.rowPaddingH,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}

/// Every skill with its icon, type and full description.
class ItemSkillsGroup extends StatelessWidget {
  const ItemSkillsGroup({super.key, required this.skills});

  final List<ItemSkill> skills;

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      for (final (i, s) in skills.indexed)
        _DetailRow(
          title: s.name,
          overline: s.type,
          description: s.description,
          iconUrl: s.iconUrl,
          showDivider: i != skills.length - 1,
        ),
    ],
  );
}

/// The resonance chain, S1 first; long descriptions fold until tapped.
class ItemChainGroup extends StatelessWidget {
  const ItemChainGroup({super.key, required this.chain});

  final List<ItemChainNode> chain;

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      for (final (i, n) in chain.indexed)
        _DetailRow(
          title: n.name,
          overline: 'S${i + 1}',
          description: n.description,
          iconUrl: n.iconUrl,
          showDivider: i != chain.length - 1,
        ),
    ],
  );
}

/// Birthday, region, affiliation and the voice actor for [lang].
class ItemProfileGroup extends StatelessWidget {
  const ItemProfileGroup({
    super.key,
    required this.profile,
    required this.lang,
  });

  final ItemProfile profile;

  /// Data language tag; picks which voice actor leads.
  final String lang;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final voice =
        profile.voiceActors[_voiceKey(lang)] ??
        profile.voiceActors['en'] ??
        profile.voiceActors.values.firstOrNull;
    final rows = [
      (Icons.cake_outlined, t.info.birthday, profile.birthday),
      (Icons.public, t.info.region, profile.country),
      (Icons.groups_outlined, t.info.affiliation, profile.influence),
      (Icons.mic_none, t.info.voiceActor, voice),
    ].where((r) => r.$3 != null).toList();
    return SettingsGroup(
      children: [
        for (final (i, r) in rows.indexed)
          SettingsItem(
            icon: r.$1,
            title: r.$3!,
            subtitle: r.$2,
            showDivider: i != rows.length - 1,
          ),
      ],
    );
  }

  static String _voiceKey(String lang) => lang.startsWith('zh')
      ? 'zh'
      : lang.startsWith('ja')
      ? 'ja'
      : lang.startsWith('ko')
      ? 'ko'
      : 'en';
}
