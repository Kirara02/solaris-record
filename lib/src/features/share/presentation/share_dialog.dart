import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/logging/log_sanitize.dart';
import '../../accounts/accounts_providers.dart';
import '../../accounts/domain/account.dart';
import '../../accounts/presentation/account_widgets.dart';
import '../../settings/settings_providers.dart';
import '../../stats/domain/pool_type.dart';
import '../../stats/stats_providers.dart';
import '../data/share_image.dart';
import 'share_card.dart';

final _log = Logger('share');

/// Opens the share dialog for [account]: the overview when [pool] is null,
/// otherwise that pool.
Future<void> showShareDialog(
  BuildContext context, {
  required Account account,
  PoolType? pool,
}) => showContentDialog<void>(
  context,
  (_) => _ShareDialog(account: account, pool: pool),
);

class _ShareDialog extends ConsumerStatefulWidget {
  const _ShareDialog({required this.account, required this.pool});

  final Account account;
  final PoolType? pool;

  @override
  ConsumerState<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends ConsumerState<_ShareDialog> {
  final _boundaryKey = GlobalKey();
  bool? _dark;

  /// Null follows the "Mask UID" setting until the user flips the switch.
  bool? _fullUid;
  bool _busy = false;
  String? _version;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then(
      (info) {
        if (mounted) setState(() => _version = info.version);
      },
      onError: (Object _) {
        if (mounted) setState(() => _version = '');
      },
    );
  }

  ShareContent? _content() {
    final uid = widget.account.uid;
    final pool = widget.pool;
    if (pool == null) {
      final stats = ref.watch(overviewStatsProvider(uid)).value;
      return stats == null ? null : ShareOverview(stats);
    }
    final stats = ref.watch(poolStatsProvider(uid, pool)).value;
    final records = ref.watch(recordsProvider(uid, pool)).value;
    if (stats == null || records == null) return null;
    final types = <String, int>{};
    for (final r in records) {
      if (r.resourceType.isNotEmpty) {
        types[r.resourceType] = (types[r.resourceType] ?? 0) + 1;
      }
    }
    return SharePool(
      pool,
      stats,
      (types.entries.map((e) => (e.key, e.value)).toList()
        ..sort((a, b) => b.$2.compareTo(a.$2))),
    );
  }

  static String _date(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _share(ShareContent content) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    final uid = widget.account.uid;
    setState(() => _busy = true);
    try {
      await preloadIcons(context, ref, content);
      final png = await capturePng(_boundaryKey);
      final prefix = uid.length < 3 ? uid : uid.substring(0, 3);
      final scope = widget.pool == null ? 'overview' : 'pool${widget.pool!.id}';
      final name = 'solaris-record-$prefix-$scope-${_date(DateTime.now())}.png';

      final result = await deliverPng(png, name, origin: origin);
      final outcome = result.outcome;
      _log.info(
        'Share ${widget.pool == null ? 'overview' : 'pool ${widget.pool!.id}'} '
        'uid=${sanitizeUid(uid)} outcome=${outcome.name}',
      );
      if (outcome == ShareOutcome.done) {
        if (!hasShareSheet) {
          messenger.showSnackBar(
            SnackBar(content: Text(t.share.saved(name: result.name ?? name))),
          );
        }
        if (mounted) Navigator.pop(context);
      }
    } on Object catch (e, st) {
      _log.warning('Share failed uid=${sanitizeUid(uid)}', e, st);
      messenger.showSnackBar(SnackBar(content: Text(t.share.failed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final seed = ref.watch(themeSettingsControllerProvider).seedColor;
    final dark = _dark ?? theme.brightness == Brightness.dark;
    final fullUid = _fullUid ?? !ref.watch(maskUidProvider);
    final content = _content();
    final uid = widget.account.uid;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.share.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(t.share.themeDark),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(t.share.themeLight),
                  ),
                ],
                selected: {dark},
                onSelectionChanged: (v) => setState(() => _dark = v.first),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.share.showFullUid),
                value: fullUid,
                onChanged: (v) => setState(() => _fullUid = v),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: content == null
                    ? const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: M3ELoadingIndicator()),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            child: RepaintBoundary(
                              key: _boundaryKey,
                              child: ShareCard(
                                theme: shareThemeFor(
                                  seed,
                                  dark ? Brightness.dark : Brightness.light,
                                ),
                                accountName: accountName(t, widget.account),
                                uid: fullUid ? uid : maskUid(uid),
                                content: content,
                                date: _date(DateTime.now()),
                                appVersion: _version ?? '',
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    child: Text(t.accounts.cancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _busy || content == null || _version == null
                        ? null
                        : () => _share(content),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.ios_share),
                    label: Text(t.share.share),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
