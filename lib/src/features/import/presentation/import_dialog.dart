import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/routing/app_routes.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_card.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../accounts/accounts_providers.dart';
import '../../accounts/presentation/account_widgets.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../stats/domain/pool_type.dart';
import '../domain/convene_api.dart';
import '../domain/convene_url.dart';
import '../import_controller.dart';
import '../saved_import_urls.dart';

/// Opens the import dialog. Reachable from the Convene screen and Settings, so
/// importing doesn't need a tab of its own.
Future<void> showImportDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const ImportDialog(),
);

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key});

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  final _controller = TextEditingController();

  /// The URL saved from the last successful update of the active account,
  /// prefilled so updating takes one tap.
  String? _saved;

  /// Result of importing a JSON file from this dialog, and whether one is
  /// being read.
  BackupImportOutcome? _fileOutcome;
  bool _fileBusy = false;

  @override
  void initState() {
    super.initState();
    final uid = ref.read(activeAccountProvider)?.uid;
    _saved = uid == null ? null : ref.read(savedImportUrlsProvider).get(uid);
    if (_saved != null) _controller.text = _saved!;
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) _controller.text = data!.text!.trim();
  }

  void _run() {
    setState(() => _fileOutcome = null);
    ref.read(importControllerProvider.notifier).run(_controller.text);
  }

  Future<void> _importFile() async {
    final t = context.t;
    setState(() => _fileBusy = true);
    final outcome = await pickAndImportBackup(ref, t);
    if (!mounted) return;
    setState(() {
      _fileBusy = false;
      if (outcome != null) _fileOutcome = outcome;
    });
  }

  String _errorText(Translations t, Object error) => switch (error) {
    ConveneUrlException(:final missing) when missing.isNotEmpty =>
      t.import.errorMissing(params: missing.join(', ')),
    ConveneUrlException() => t.import.errorInvalidUrl,
    ConveneApiException(:final error) => switch (error) {
      ConveneApiError.invalidOrExpired => t.import.errorExpired,
      ConveneApiError.rateLimited => t.import.errorRateLimited,
      ConveneApiError.network => t.import.errorNetwork,
      ConveneApiError.unexpected => t.import.errorUnexpected,
    },
    _ => t.import.errorUnexpected,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(importControllerProvider);
    final progress = ref.watch(importProgressProvider);
    final loading = state.isLoading;
    final hasText = _controller.text.trim().isNotEmpty;
    final done = state.value;
    // Hide the paste steps while the saved URL is untouched; an error brings
    // them back (the saved URL was just dropped as expired).
    final usingSaved =
        _saved != null && _controller.text.trim() == _saved && !state.hasError;

    return PopScope(
      // A running import can't be dismissed (back button / barrier tap).
      canPop: !loading && !_fileBusy,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.import.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: t.import.close,
                      icon: const Icon(Icons.close),
                      onPressed: loading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (usingSaved)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            t.import.savedHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else ...[
                        SettingsSectionHeader(title: t.import.stepsTitle),
                        SettingsGroup(
                          children: [
                            _Step(1, t.import.step1),
                            _Step(2, t.import.step2),
                            _Step(3, t.import.step3, last: true),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        controller: _controller,
                        minLines: 3,
                        maxLines: 5,
                        enabled: !loading,
                        label: t.import.urlLabel,
                        keyboardType: TextInputType.url,
                        suffix: hasText
                            ? IconButton(
                                tooltip: t.import.clear,
                                icon: const Icon(Icons.close),
                                onPressed: loading ? null : _controller.clear,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final paste = M3EButton(
                            style: M3EButtonStyle.tonal,
                            size: M3EButtonSize.md,
                            icon: const Icon(Icons.content_paste),
                            label: Text(t.import.paste),
                            onPressed: loading ? null : _paste,
                          );
                          final update = M3EButton(
                            size: M3EButtonSize.md,
                            icon: const Icon(Icons.sync),
                            label: Text(t.import.update),
                            onPressed: loading || !hasText ? null : _run,
                          );
                          // Side by side only when both labels fit.
                          if (constraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                update,
                                const SizedBox(height: 8),
                                paste,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: paste),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: update),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      M3EButton(
                        style: M3EButtonStyle.outlined,
                        size: M3EButtonSize.md,
                        icon: const Icon(Icons.file_open_outlined),
                        label: Text(t.import.fromFile),
                        onPressed: loading || _fileBusy ? null : _importFile,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                        child: Text(
                          t.import.fromFileHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (_fileOutcome case final outcome?) ...[
                        const SizedBox(height: 16),
                        if (outcome.ok)
                          _ResultCard(
                            message: outcome.message,
                            viewLabel: t.import.viewRecords,
                          )
                        else
                          ErrorCard(message: outcome.message),
                      ],
                      if (loading) ...[
                        SettingsSectionHeader(title: t.import.progressTitle),
                        _ProgressGroup(current: progress),
                      ],
                      if (state.hasError) ...[
                        const SizedBox(height: 16),
                        ErrorCard(
                          message: _errorText(t, state.error!),
                          retryLabel: t.import.retry,
                          onRetry: hasText ? _run : null,
                        ),
                      ],
                      if (done != null) ...[
                        SettingsSectionHeader(title: t.import.resultTitle),
                        _ResultCard(
                          message: t.import.done(
                            n: done.newRecords,
                            uid: displayUid(ref, done.uid),
                          ),
                          viewLabel: t.import.viewRecords,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success banner with a shortcut to the Convene screen.
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.message, required this.viewLabel});

  final String message;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: scheme.onPrimaryContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          M3EButton(
            size: M3EButtonSize.md,
            icon: const Icon(Icons.insights),
            label: Text(viewLabel),
            onPressed: () {
              // Capture the router before the dialog's context goes away.
              final router = GoRouter.of(context);
              Navigator.pop(context);
              router.go(AppRoutes.convene);
            },
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text, {this.last = false});

  final int number;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SettingsItem(
      showDivider: !last,
      leading: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
      title: text,
      titleStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

/// One row per pool: done, in progress (highlighted), or pending (dimmed).
class _ProgressGroup extends StatelessWidget {
  const _ProgressGroup({required this.current});

  final PoolType? current;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentIndex = current?.index ?? -1;
    return SettingsGroup(
      children: [
        for (final p in PoolType.values)
          _ProgressRow(
            active: p.index == currentIndex,
            child: SettingsItem(
              showDivider: p != PoolType.values.last,
              title: p.label(t),
              titleStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: p.index == currentIndex
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: p.index == currentIndex
                    ? scheme.onPrimaryContainer
                    : p.index < currentIndex
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              subtitle: p.index == currentIndex
                  ? t.import.fetching(pool: p.label(t))
                  : null,
              leading: SizedBox(
                width: 24,
                height: 24,
                child: p.index < currentIndex
                    ? Icon(Icons.check_circle, color: scheme.primary)
                    : p.index == currentIndex
                    ? const M3EProgressIndicator.circular(strokeWidth: 3)
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: scheme.outlineVariant,
                      ),
              ),
              trailing: Text(
                '${p.index + 1}/${PoolType.values.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: p.index == currentIndex
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tints the row that is currently being fetched.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: context.tokens.motionMedium,
    curve: Curves.easeOutCubic,
    color: active
        ? Theme.of(context).colorScheme.primaryContainer
        : Colors.transparent,
    child: child,
  );
}
