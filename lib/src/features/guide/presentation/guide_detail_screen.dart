import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../info/domain/encore_links.dart';
import '../../info/domain/item_kind.dart';
import '../../info/presentation/item_gallery.dart';
import '../../info/presentation/item_info_body.dart';
import '../../info/presentation/item_sections.dart';
import '../../settings/settings_providers.dart';
import '../domain/guide_entry.dart';
import '../guide_providers.dart';

/// Full-screen details of one guide entry. Resonators and weapons reuse the
/// item info body; echoes have their own.
class GuideDetailScreen extends ConsumerWidget {
  const GuideDetailScreen({super.key, required this.kind, required this.id});

  final GuideKind kind;
  final int id;

  /// Widest the page content gets on large windows.
  static const contentMaxWidth = 840.0;

  /// Key of the "View on encore.moe" button, for tests.
  static const viewOnEncoreKey = ValueKey('guide-view-on-encore');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;

    final String link;
    final AsyncValue<Widget?> state;
    String? title;
    VoidCallback retry;
    if (kind == GuideKind.echo) {
      final provider = echoInfoProvider(id, lang);
      final info = ref.watch(provider);
      link = encoreEchoUrl(id, lang);
      title = info.value?.name;
      retry = () => ref.invalidate(provider);
      state = info.whenData((d) => d == null ? null : _EchoBody(info: d));
    } else {
      final type = kind == GuideKind.resonator ? 'resonator' : 'weapon';
      final provider = itemInfoProvider(id, type, lang);
      final info = ref.watch(provider);
      link = encoreItemUrl(
        kind == GuideKind.resonator ? ItemKind.resonator : ItemKind.weapon,
        id,
        lang,
      );
      title = info.value?.name;
      retry = () => ref.invalidate(provider);
      state = info.whenData(
        (d) => d == null
            ? null
            : ItemInfoBody(info: d, resourceId: id, lang: lang),
      );
    }

    // Offered even when the info could not be loaded: the page may still
    // exist on encore.moe.
    final linkButton = AppButton(
      key: viewOnEncoreKey,
      style: AppButtonStyle.tonal,
      icon: const AdaptiveIcon(Icons.open_in_new),
      label: Text(t.info.viewOnEncore),
      onPressed: () => _open(context, ref, link),
    );

    // Long lines are hard to read on a wide window, so the page keeps a
    // reading width, centred in the body.
    Widget framed(List<Widget> children) => SliverAdaptivePadding(
      sliver: SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: contentMaxWidth),
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
          AppSliverHeader(title: title ?? t.guide.title, showBack: true),
          // Loading and the empty state sit in the middle of the body.
          ...state.when(
            loading: () => [
              const SliverFillBody(child: Center(child: AppLoadingIndicator())),
            ],
            error: (_, _) => [
              framed([
                ErrorCard(
                  message: t.info.error,
                  retryLabel: t.import.retry,
                  onRetry: retry,
                ),
                const SizedBox(height: 16),
                linkButton,
              ]),
            ],
            data: (body) => body == null
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
                    framed([body, const SizedBox(height: 16), linkButton]),
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

class _EchoBody extends StatelessWidget {
  const _EchoBody({required this.info});

  final EchoInfo info;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: title),
        child,
      ],
    );

    Widget textBlock(String text) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );

    final cooldown = info.cooldown;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (info.gallery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ItemGalleryCard(
              groups: info.gallery,
              accent: scheme.primary,
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
          spacing: 8,
          runSpacing: 8,
          children: [
            if (info.elementIconUrl != null)
              GameIcon(info.elementIconUrl, size: 28),
            StatusBadge(label: t.guide.echo),
            if (info.className != null) StatusBadge(label: info.className!),
            if (info.elementName != null)
              StatusBadge(
                label: '${t.info.element}: ${info.elementName}',
                background: attributeBadgeColors(context, primary: false).$1,
                foreground: attributeBadgeColors(context, primary: false).$2,
              ),
            if (info.family != null)
              StatusBadge(
                label: info.family!,
                background: attributeBadgeColors(context, primary: true).$1,
                foreground: attributeBadgeColors(context, primary: true).$2,
              ),
          ],
        ),
        if (info.place != null)
          section(
            t.guide.location,
            SettingsGroup(
              children: [
                SettingsItem(
                  icon: Icons.place_outlined,
                  title: info.place!,
                  showDivider: false,
                ),
              ],
            ),
          ),
        if (info.skill != null)
          section(
            cooldown == null
                ? t.guide.echoSkill
                : '${t.guide.echoSkill} · ${t.guide.cooldown(n: _seconds(cooldown))}',
            textBlock(info.skill!),
          ),
        if (info.mainStats != null)
          section(t.guide.mainStats, textBlock(info.mainStats!)),
        if (info.sets.isNotEmpty)
          section(
            t.guide.sonata,
            SettingsGroup(
              children: [
                for (final (i, set) in info.sets.indexed)
                  SettingsItem(
                    leading: GameIcon(set.iconUrl, size: 36),
                    title: set.name,
                    subtitle: [
                      for (final (pieces, text) in set.effects)
                        '${t.guide.pieces(n: pieces)}: $text',
                    ].join('\n'),
                    showDivider: i != info.sets.length - 1,
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

  static String _seconds(num v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}
