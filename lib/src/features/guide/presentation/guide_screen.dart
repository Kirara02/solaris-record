import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/assets/assets.gen.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_card.dart';
import '../../settings/settings_providers.dart';
import '../domain/guide_entry.dart';
import '../guide_providers.dart';
import 'guide_card.dart';
import 'guide_filter_sheet.dart';

/// Lists every resonator, weapon and echo as portrait cards, with search and
/// a filter sheet. Tapping a card opens its detail screen.
class GuideScreen extends ConsumerStatefulWidget {
  const GuideScreen({super.key});

  @override
  ConsumerState<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends ConsumerState<GuideScreen> {
  GuideKind _kind = GuideKind.resonator;
  bool _searching = false;
  final _filter = GuideFilter();

  /// The search text. Typing only rebuilds the results (and never the field
  /// itself), so the field keeps its focus and the IME session between keys.
  final _query = ValueNotifier('');

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _toggleSearch() => setState(() {
    _searching = !_searching;
    if (!_searching) _query.value = '';
  });

  void _setKind(GuideKind kind) => setState(() {
    _kind = kind;
    _filter.clear();
  });

  List<GuideEntry> _visible(List<GuideEntry> all, String query) {
    final q = query.trim().toLowerCase();
    final out = [
      for (final e in all)
        if ((q.isEmpty || e.name.toLowerCase().contains(q)) &&
            _filter.matches(e))
          e,
    ];
    // Highest rarity first, then by name.
    out.sort((a, b) {
      final byRarity = b.rarity.compareTo(a.rarity);
      return byRarity != 0 ? byRarity : a.name.compareTo(b.name);
    });
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final kind = _kind;
    final compact = context.windowSize == WindowSize.compact;
    final provider = guideEntriesProvider(kind, lang);
    final entries = ref.watch(provider);
    final inset = WindowSize.sideInset(
      MediaQuery.sizeOf(context).width - MediaQuery.paddingOf(context).left,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            // The wide layout's sidebar already leads back.
            titleSpacing: compact ? 0 : inset + 8,
            leading: compact
                ? IconButton(
                    tooltip: MaterialLocalizations.of(context)
                        .backButtonTooltip,
                    icon: AdaptiveIcon(Icons.arrow_back, color: scheme.primary),
                    onPressed: () => context.pop(),
                  )
                : null,
            title: Text(t.guide.title),
            actionsPadding: EdgeInsets.only(right: inset),
            actions: [
              IconButton(
                tooltip: t.guide.search,
                icon: AdaptiveIcon(_searching ? Icons.close : Icons.search),
                onPressed: _toggleSearch,
              ),
              IconButton(
                tooltip: t.guide.filter,
                icon: Badge(
                  label: Text('${_filter.count}'),
                  isLabelVisible: _filter.count > 0,
                  child: const AdaptiveIcon(Icons.filter_list),
                ),
                onPressed: entries.value == null
                    ? null
                    : () => showGuideFilterSheet(
                        context,
                        kind: kind,
                        entries: entries.value!,
                        filter: _filter,
                        onChanged: () => setState(() {}),
                      ),
              ),
            ],
          ),
          if (_searching)
            SliverAdaptivePadding(
              clearBottomInset: false,
              sliver: SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: _SearchField(
                    hint: t.guide.search,
                    onChanged: (v) => _query.value = v,
                  ),
                ),
              ),
            ),
          SliverAdaptivePadding(
            clearBottomInset: false,
            bottom: 12,
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _KindChip(
                        art: Assets.images.guideResonator,
                        label: t.guide.resonators,
                        selected: kind == GuideKind.resonator,
                        onTap: () => _setKind(GuideKind.resonator),
                      ),
                      const SizedBox(width: 8),
                      _KindChip(
                        art: Assets.images.guideWeapon,
                        label: t.guide.weapons,
                        selected: kind == GuideKind.weapon,
                        onTap: () => _setKind(GuideKind.weapon),
                      ),
                      const SizedBox(width: 8),
                      _KindChip(
                        art: Assets.images.guideEcho,
                        label: t.guide.echoes,
                        selected: kind == GuideKind.echo,
                        onTap: () => _setKind(GuideKind.echo),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: _query,
            builder: (context, query, _) => SliverMainAxisGroup(
              slivers: entries.when(
                loading: () => [
                  const SliverFillBody(
                    child: Center(child: AppLoadingIndicator()),
                  ),
                ],
                error: (_, _) => [
                  SliverAdaptivePadding(
                    sliver: SliverToBoxAdapter(
                      child: ErrorCard(
                        message: t.guide.error,
                        retryLabel: t.import.retry,
                        onRetry: () => ref.invalidate(provider),
                      ),
                    ),
                  ),
                ],
                data: (all) {
                  final shown = _visible(all, query);
                  if (shown.isEmpty) {
                    return [
                      SliverFillBody(
                        child: Center(child: Text(t.guide.noResults)),
                      ),
                    ];
                  }
                  return [
                    SliverAdaptivePadding(
                      sliver: SliverGrid.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 170,
                              childAspectRatio: 0.72,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                        itemCount: shown.length,
                        itemBuilder: (context, i) => GuideCard(entry: shown[i]),
                      ),
                    ),
                  ];
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill tab for a guide kind: filled with the primary colour when selected.
class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.art,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AssetGenImage art;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(context.tokens.radiusSheet),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The art is drawn white; tint it to the chip's text colour.
              art.image(
                width: 20,
                height: 20,
                color: fg,
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: fg, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The search box. It owns its controller and focus node so the screen can
/// rebuild around it without disturbing typing.
class _SearchField extends StatefulWidget {
  const _SearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: _controller,
    autofocus: true,
    outlined: true,
    hint: widget.hint,
    prefix: const AdaptiveIcon(Icons.search),
    textInputAction: TextInputAction.search,
    onChanged: widget.onChanged,
    // The list already follows every key; submitting just closes the keyboard.
    onSubmitted: (_) => FocusScope.of(context).unfocus(),
  );
}
