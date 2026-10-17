import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../settings/data/storage_usage.dart';
import '../data/update_service.dart';
import '../domain/update_info.dart';
import '../domain/update_platform.dart';
import '../update_providers.dart';
import 'update_actions.dart';

final _log = Logger('update');

/// Tells the user a newer version exists, with its release notes. On Android
/// the update can be downloaded and installed from here; on desktop the
/// download opens in the browser.
Future<void> showUpdateDialog(BuildContext context, UpdateAvailable update) =>
    showDialog<void>(
      context: context,
      builder: (context) => UpdateDialog(update: update),
    );

class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({super.key, required this.update});

  final UpdateAvailable update;

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _downloading = false;
  int _received = 0;
  int _total = 0;
  String? _error;
  CancelToken? _cancel;

  UpdateInfo get _info => widget.update.info;
  UpdateAsset? get _asset => _info.asset;

  /// Installing from inside the app needs a checksum to verify the download.
  bool get _installInApp =>
      canInstallInApp && _asset != null && _asset!.sha256 != null;

  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final opened = await ref.read(urlOpenerProvider).open(Uri.parse(url));
    if (!opened) {
      messenger?.showSnackBar(SnackBar(content: Text(t.info.openFailed)));
    }
  }

  Future<void> _primary() async {
    if (_installInApp) return _downloadAndInstall();
    await _open(_asset?.url ?? _info.pageUrl);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _downloadAndInstall() async {
    final t = context.t;
    final service = ref.read(updateServiceProvider);
    setState(() {
      _downloading = true;
      _received = 0;
      _total = _asset!.size;
      _error = null;
    });
    _cancel = CancelToken();
    try {
      final file = await service.download(
        _asset!,
        cancelToken: _cancel,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            if (total > 0) _total = total;
          });
        },
      );
      if (!mounted) return;
      if (await service.openInstaller(file)) {
        if (mounted) Navigator.pop(context);
      } else if (mounted) {
        setState(() {
          _downloading = false;
          _error = t.update.installFailed;
        });
      }
    } on Object catch (e, st) {
      if (e is DioException && CancelToken.isCancel(e)) {
        _log.info('Update download cancelled');
      } else {
        _log.warning('Update download failed', e, st);
      }
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = switch (e) {
          DioException() when CancelToken.isCancel(e) => null,
          UpdateException(message: 'checksum mismatch') =>
            t.update.checksumFailed,
          _ => t.update.downloadFailed,
        };
      });
    }
  }

  void _skip() {
    ref.read(skippedUpdateVersionProvider.notifier).set(_info.version);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = context.tokens;
    final notes = formatReleaseNotes(_info.notes);
    final progress = _total > 0 ? (_received / _total).clamp(0.0, 1.0) : 0.0;

    final primaryLabel = _installInApp
        ? t.update.downloadInstall
        : _asset != null
        ? t.update.download
        : t.update.openRelease;

    return PopScope(
      canPop: !_downloading,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.system_update,
                        color: scheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.update.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t.update.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(tokens.radiusControl),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _VersionChip(
                        label: t.update.current,
                        version: widget.update.currentVersion,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _VersionChip(
                        label: t.update.latest,
                        version: _info.version,
                        highlighted: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_downloading)
                  _DownloadProgress(
                    progress: progress,
                    received: _received,
                    total: _total,
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.update.whatsNew,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(t.update.releasePage),
                        onPressed: () => _open(_info.pageUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(tokens.radiusControl),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        notes.isEmpty ? t.update.noNotes : notes,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (_downloading)
                  SizedBox(
                    width: double.infinity,
                    // A label without an icon is not rendered by M3EButton, so
                    // icon-less buttons pass their text as the child.
                    child: M3EButton(
                      style: M3EButtonStyle.outlined,
                      size: M3EButtonSize.md,
                      onPressed: () => _cancel?.cancel(),
                      child: Text(t.update.cancel),
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: M3EButton(
                      size: M3EButtonSize.md,
                      icon: Icon(
                        _installInApp ? Icons.download : Icons.open_in_new,
                      ),
                      label: Text(primaryLabel),
                      onPressed: _primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: M3EButton(
                          style: M3EButtonStyle.text,
                          size: M3EButtonSize.md,
                          onPressed: _skip,
                          child: Text(t.update.skip),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: M3EButton(
                          style: M3EButtonStyle.outlined,
                          size: M3EButtonSize.md,
                          onPressed: () => Navigator.pop(context),
                          child: Text(t.update.later),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.version,
    this.highlighted = false,
  });

  final String label;
  final String version;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: highlighted
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'v$version',
            style: theme.textTheme.labelLarge?.copyWith(
              color: highlighted
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadProgress extends StatelessWidget {
  const _DownloadProgress({
    required this.progress,
    required this.received,
    required this.total,
  });

  final double progress;
  final int received;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(context.tokens.radiusControl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: M3EProgressIndicator.circular(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                t.update.downloading,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          M3EProgressIndicator.linear(
            value: progress,
            color: scheme.primary,
            trackColor: scheme.surfaceContainerHighest,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total > 0
                    ? '${formatBytes(received)} / ${formatBytes(total)}'
                    : formatBytes(received),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
