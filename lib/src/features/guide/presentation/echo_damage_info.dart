import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/guide_entry.dart';

/// The echo skill's hits: rate (by skill level), energy, hardness, toughness
/// and off-tune, as in encore.moe's "Damage info" table but one block per hit
/// instead of a wide table. Folded until opened.
class EchoDamageInfo extends StatefulWidget {
  const EchoDamageInfo({super.key, required this.info, required this.level});

  final EchoInfo info;

  /// The skill level the rates are shown at.
  final int level;

  @override
  State<EchoDamageInfo> createState() => _EchoDamageInfoState();
}

class _EchoDamageInfoState extends State<EchoDamageInfo> {
  bool _open = false;

  static String _number(num? v) => v == null
      ? ''
      : v == v.roundToDouble()
      ? '${v.round()}'
      : '$v';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final info = widget.info;

    // One block per hit: what it is and its rate on top, then the other
    // numbers wrapping underneath, so nothing needs sideways scrolling.
    Widget stat(String label, num? value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _number(value),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget hit(EchoHit h) {
      final what = [?h.property, ?h.type, ?h.damageType].join(' · ');
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${h.number}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(what, style: theme.textTheme.bodyMedium)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      t.guide.colRate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      h.rateAt(widget.level) ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 24,
              runSpacing: 10,
              children: [
                stat(t.guide.colResonanceEnergy, h.resonanceEnergy),
                stat(t.guide.colConcertoEnergy, h.concertoEnergy),
                stat(t.guide.colHardness, h.hardness),
                stat(t.guide.colToughness, h.toughness),
                stat(t.guide.colOffTune, h.offTune),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: t.guide.damageInfo,
          trailing: IconButton(
            tooltip: t.guide.damageInfo,
            icon: AdaptiveIcon(_open ? Icons.remove : Icons.add),
            onPressed: () => setState(() => _open = !_open),
          ),
        ),
        if (_open) ...[
          Container(
            decoration: groupDecoration(context),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, h) in info.hits.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  hit(h),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
