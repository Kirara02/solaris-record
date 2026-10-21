import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/error_card.dart';
import '../../settings/settings_providers.dart';
import '../domain/challenge_season.dart';
import 'challenge_widgets.dart';

/// Shared frame of the Tower of Adversity and Whimpering Wastes screens: the
/// season list on top, a season header, and the chosen season's [body].
class SeasonScreen extends ConsumerStatefulWidget {
  const SeasonScreen({
    super.key,
    required this.title,
    required this.watchSeasons,
    required this.retry,
    required this.body,
  });

  final String title;

  /// Watches the season list for a data language.
  final AsyncValue<List<ChallengeSeason>> Function(WidgetRef ref, String lang)
  watchSeasons;

  /// Reloads the season list after a failure.
  final void Function(WidgetRef ref, String lang) retry;

  /// A sliver with the details of [season] in [lang].
  final Widget Function(ChallengeSeason season, String lang) body;

  @override
  ConsumerState<SeasonScreen> createState() => _SeasonScreenState();
}

class _SeasonScreenState extends ConsumerState<SeasonScreen> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final lang =
        ref.watch(dataLanguageProvider) ??
        LocaleSettings.currentLocale.languageTag;
    final seasons = widget.watchSeasons(ref, lang);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: widget.title,
            // The wide layout's sidebar already leads back.
            showBack: context.windowSize == WindowSize.compact,
          ),
          ...seasons.when(
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
                    message: t.challenges.error,
                    retryLabel: t.import.retry,
                    onRetry: () => widget.retry(ref, lang),
                  ),
                ),
              ),
            ],
            data: (all) {
              final selected =
                  all.where((s) => s.id == _picked).firstOrNull ??
                  defaultSeason(all, DateTime.now());
              if (selected == null) {
                return [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(t.challenges.empty)),
                  ),
                ];
              }
              return [
                SliverAdaptivePadding(
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SeasonHeader(
                          season: selected,
                          seasons: all,
                          onSelected: (s) => setState(() => _picked = s.id),
                        ),
                      ),
                      widget.body(selected, lang),
                    ],
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
