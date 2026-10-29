import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_slider.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../guide/presentation/guide_detail_screen.dart';
import '../../info/domain/encore_links.dart';
import '../../info/presentation/item_sections.dart';
import '../../settings/settings_providers.dart';
import '../challenge_providers.dart';
import '../domain/challenge_models.dart';
import '../domain/monster_info.dart';
import 'challenge_markup.dart';
import 'challenge_widgets.dart';

/// Full-screen details of one enemy, opened from the Tower of Adversity or
/// Whimpering Wastes. [preview] is the enemy as the tile showed it; it titles
/// the page while the details load.
class MonsterScreen extends ConsumerWidget {
  const MonsterScreen({super.key, required this.id, this.preview});

  final int id;
  final ChallengeMonster? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final provider = monsterInfoProvider(id, lang);
    final info = ref.watch(provider);

    // Offered whatever the outcome: the page may still exist on encore.moe.
    final linkButton = AppButton(
      style: AppButtonStyle.tonal,
      icon: const AdaptiveIcon(Icons.open_in_new),
      label: Text(t.info.viewOnEncore),
      onPressed: () => _open(context, ref, encoreMonsterUrl(id, lang)),
    );

    // Long lines are hard to read on a wide window, so the page keeps a
    // reading width, centred in the body.
    Widget framed(List<Widget> children) => SliverAdaptivePadding(
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: GuideDetailScreen.contentMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [const SizedBox(height: 8), ...children],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: info.value?.name ?? preview?.name ?? '',
            showBack: true,
          ),
          ...info.when(
            loading: () => [
              const SliverFillBody(child: Center(child: AppLoadingIndicator())),
            ],
            error: (_, _) => [
              framed([
                ErrorCard(
                  message: t.info.error,
                  retryLabel: t.import.retry,
                  onRetry: () => ref.invalidate(provider),
                ),
                const SizedBox(height: 16),
                linkButton,
              ]),
            ],
            data: (data) => data == null
                ? [
                    SliverFillBody(
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        title: t.info.notFound,
                        action: linkButton,
                      ),
                    ),
                  ]
                : [
                    framed([
                      _MonsterBody(info: data),
                      const SizedBox(height: 16),
                      linkButton,
                    ]),
                  ],
          ),
        ],
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

class _MonsterBody extends StatefulWidget {
  const _MonsterBody({required this.info});

  final MonsterInfo info;

  @override
  State<_MonsterBody> createState() => _MonsterBodyState();
}

class _MonsterBodyState extends State<_MonsterBody> {
  static const _minLevel = 1;
  static final _number = NumberFormat.decimalPattern();
  static final _percent = NumberFormat('#,##0.##');

  int _level = _minLevel;

  MonsterInfo get info => widget.info;

  String _value(MonsterProperty p) {
    final v = info.valueAt(p, _level);
    return p.isPercent ? '${_percent.format(v)}%' : _number.format(v.round());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = rarityColor(info.rarityId);
    final element = info.element;

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
        if (info.iconUrl != null)
          Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: context.tokens.borderRadiusCard,
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: info.iconUrl!,
              fit: BoxFit.contain,
              placeholder: (_, _) => const Center(child: AppLoadingIndicator()),
              errorWidget: (_, _, _) => Center(
                child: AdaptiveIcon(
                  Icons.image_not_supported_outlined,
                  color: color,
                ),
              ),
            ),
          ),
        Center(
          child: Text(
            info.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (element?.iconUrl != null) GameIcon(element!.iconUrl, size: 28),
            if (info.rarity != null)
              StatusBadge(
                label: info.rarity!,
                background: color.withValues(alpha: 0.18),
                foreground: color,
              ),
            if (element != null)
              StatusBadge(
                label: element.name,
                background: attributeBadgeColors(context, primary: false).$1,
                foreground: attributeBadgeColors(context, primary: false).$2,
              ),
          ],
        ),
        if (info.description != null)
          section(
            t.info.introduction,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MarkupText(
                info.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        if (info.properties.isNotEmpty)
          section(
            // The level only changes the numbers when the enemy scales.
            info.maxLevel > _minLevel
                ? t.info.baseStatsAtLevel
                : t.info.baseStats,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (info.maxLevel > _minLevel)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          t.info.level,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
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
                          child: AppSlider(
                            min: _minLevel.toDouble(),
                            max: info.maxLevel.toDouble(),
                            divisions: info.maxLevel - _minLevel,
                            value: _level.toDouble(),
                            label: '$_level',
                            onChanged: (v) =>
                                setState(() => _level = v.round()),
                          ),
                        ),
                      ],
                    ),
                  ),
                SettingsGroup(
                  children: [
                    for (final (i, p) in info.properties.indexed)
                      SettingsItem(
                        leading: p.iconUrl == null
                            ? null
                            : GameIcon(p.iconUrl, size: 28),
                        title: p.name,
                        showDivider: i != info.properties.length - 1,
                        trailing: Text(
                          _value(p),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
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
