import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
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
  String _query = '';
  bool _searching = false;
  final _searchController = TextEditingController();
  final _filter = GuideFilter();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() => setState(() {
    _searching = !_searching;
    if (!_searching) {
      _searchController.clear();
      _query = '';
    }
  });

  void _setKind(GuideKind kind) => setState(() {
    _kind = kind;
    _filter.clear();
  });

  List<GuideEntry> _visible(List<GuideEntry> all) {
    final q = _query.trim().toLowerCase();
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
    final tokens = context.tokens;
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final provider = guideEntriesProvider(_kind, lang);
    final entries = ref.watch(provider);
    final inset = WindowSize.sideInset(
      MediaQuery.sizeOf(context).width - MediaQuery.paddingOf(context).left,
    );

    OutlineInputBorder noBorder() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radiusSheet),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: AdaptiveIcon(Icons.arrow_back, color: scheme.primary),
              onPressed: () => context.pop(),
            ),
            title: _searching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: t.guide.search,
                      prefixIcon: const AdaptiveIcon(Icons.search),
                      filled: true,
                      fillColor: scheme.surfaceContainerHigh,
                      border: noBorder(),
                      enabledBorder: noBorder(),
                      focusedBorder: noBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  )
                : Text(t.guide.title),
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
                        kind: _kind,
                        entries: entries.value!,
                        filter: _filter,
                        onChanged: () => setState(() {}),
                      ),
              ),
            ],
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
                        icon: Icons.person,
                        label: t.guide.resonators,
                        selected: _kind == GuideKind.resonator,
                        onTap: () => _setKind(GuideKind.resonator),
                      ),
                      const SizedBox(width: 8),
                      _KindChip(
                        icon: Icons.gavel,
                        label: t.guide.weapons,
                        selected: _kind == GuideKind.weapon,
                        onTap: () => _setKind(GuideKind.weapon),
                      ),
                      const SizedBox(width: 8),
                      _KindChip(
                        icon: Icons.graphic_eq,
                        label: t.guide.echoes,
                        selected: _kind == GuideKind.echo,
                        onTap: () => _setKind(GuideKind.echo),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ...entries.when(
            loading: () => [
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: M3ELoadingIndicator()),
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
              final shown = _visible(all);
              if (shown.isEmpty) {
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
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
        ],
      ),
    );
  }
}

/// Pill tab for a guide kind: filled with the primary colour when selected.
class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
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
              AdaptiveIcon(icon, size: 18, color: fg),
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
