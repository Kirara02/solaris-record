import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../announcements/domain/announcement.dart';
import '../data/redeem_service.dart';
import '../domain/redeem_code.dart';
import '../redeem_providers.dart';

/// Redeem codes the maintainer keeps in `redeem-codes.json`. Working codes
/// first, expired ones below; tapping the copy button puts a code on the
/// clipboard.
class RedeemScreen extends ConsumerWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final feed = ref.watch(redeemCodesProvider);
    final lang = LocaleSettings.currentLocale.languageTag;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(redeemCodesProvider);
          await ref
              .read(redeemCodesProvider.future)
              .catchError((_) => const RedeemFeed([]));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            AppSliverHeader(
              title: t.redeem.title,
              showBack: context.windowSize == WindowSize.compact,
              actions: [
                IconButton(
                  tooltip: t.redeem.refresh,
                  icon: const AdaptiveIcon(Icons.refresh),
                  onPressed: () => ref.invalidate(redeemCodesProvider),
                ),
              ],
            ),
            ...feed.when(
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
                      message: t.redeem.error,
                      retryLabel: t.import.retry,
                      onRetry: () => ref.invalidate(redeemCodesProvider),
                    ),
                  ),
                ),
              ],
              data: (data) => _content(context, ref, data, lang),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    RedeemFeed data,
    String lang,
  ) {
    final t = context.t;
    final now = DateTime.now();
    final active = [
      for (final c in data.codes)
        if (!c.isExpired(now)) c,
    ];
    final expired = [
      for (final c in data.codes)
        if (c.isExpired(now)) c,
    ];
    if (data.codes.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: Icons.card_giftcard_outlined,
            title: t.redeem.empty,
            body: t.redeem.emptyBody,
          ),
        ),
      ];
    }

    Widget header(String title) =>
        SliverToBoxAdapter(child: SettingsSectionHeader(title: title));
    SliverList list(List<RedeemCode> codes, {required bool expired}) =>
        SliverList.separated(
          itemCount: codes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _CodeCard(code: codes[i], lang: lang, expired: expired),
        );

    return [
      SliverAdaptivePadding(
        clearBottomInset: expired.isEmpty,
        bottom: expired.isEmpty ? 24 : 0,
        sliver: SliverMainAxisGroup(
          slivers: [
            if (data.fromCache)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: StatusBadge(label: t.redeem.offline),
                ),
              ),
            header(t.redeem.active),
            if (active.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(t.redeem.noneActive),
                ),
              )
            else
              list(active, expired: false),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  t.redeem.howTo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      if (expired.isNotEmpty)
        SliverAdaptivePadding(
          sliver: SliverMainAxisGroup(
            slivers: [header(t.redeem.expired), list(expired, expired: true)],
          ),
        ),
    ];
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.lang,
    required this.expired,
  });

  final RedeemCode code;
  final String lang;
  final bool expired;

  static String _date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rewards = pickText(code.rewards, lang);
    final source = pickText(code.source, lang);
    final muted = scheme.onSurfaceVariant;

    return Opacity(
      opacity: expired ? 0.6 : 1,
      child: AppCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    code.code,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (rewards != null) ...[
                    const SizedBox(height: 4),
                    Text(rewards, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (source != null)
                        StatusBadge(
                          label: source,
                          background: scheme.tertiaryContainer,
                          foreground: scheme.onTertiaryContainer,
                        ),
                      Text(
                        code.expires == null
                            ? t.redeem.noExpiry
                            : t.redeem.expires(date: _date(code.expires!)),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!expired)
              IconButton(
                tooltip: t.redeem.copy,
                icon: const AdaptiveIcon(Icons.content_copy),
                onPressed: () => _copy(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copied = context.t.redeem.copied(code: code.code);
    await Clipboard.setData(ClipboardData(text: code.code));
    messenger?.showSnackBar(SnackBar(content: Text(copied)));
  }
}
