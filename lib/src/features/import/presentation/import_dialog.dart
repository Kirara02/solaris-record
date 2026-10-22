import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/i18n/pool_labels.dart';
import '../../../shared/routing/app_routes.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_segmented_control.dart';
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
Future<void> showImportDialog(BuildContext context, {String? initialUrl}) =>
    showDialog<void>(
      context: context,
      builder: (context) => ImportDialog(initialUrl: initialUrl),
    );

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key, this.initialUrl});

  /// A link to start with, e.g. one shared from another app.
  final String? initialUrl;

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

  /// Whether the dialog shows the JSON file import instead of the link one.
  bool _fileMode = false;

  /// Where the field's starting text came from, to say so under it.
  _Prefill? _prefill;

  /// Which app's export the file guide explains.
  _FileSource _fileSource = _FileSource.solaris;

  /// Index into the selected platform's methods.
  int _method = 0;

  late _Guide _guide = _Guide.forPlatform(defaultTargetPlatform);

  Future<void> _openFullGuide() => ref
      .read(urlOpenerProvider)
      .open(Uri.parse('https://wuwatracker.com/import'));

  @override
  void initState() {
    super.initState();
    final uid = ref.read(activeAccountProvider)?.uid;
    _saved = uid == null ? null : ref.read(savedImportUrlsProvider).get(uid);
    if (widget.initialUrl != null) {
      _controller.text = widget.initialUrl!;
      _prefill = _Prefill.shared;
    } else if (_saved != null) {
      _controller.text = _saved!;
    } else {
      _prefillFromClipboard();
    }
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fills the field with a convene link that is already on the clipboard, so
  /// copying it in the game and opening this dialog is all it takes.
  Future<void> _prefillFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final url = extractConveneUrl(data?.text ?? '');
    if (url == null || !mounted || _controller.text.isNotEmpty) return;
    setState(() {
      _controller.text = url;
      _prefill = _Prefill.clipboard;
    });
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
    final methods = _guide.methods(t);
    final method = methods[_method.clamp(0, methods.length - 1)];
    final steps = method.steps;
    final usingSaved =
        _saved != null && _controller.text.trim() == _saved && !state.hasError;

    final fileImport = <Widget>[
      M3EButton(
        style: M3EButtonStyle.outlined,
        size: M3EButtonSize.md,
        icon: const AdaptiveIcon(Icons.file_open_outlined),
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
    ];

    return PopScope(
      // A running import can't be dismissed (back button / barrier tap).
      canPop: !loading && !_fileBusy,
      child: AppDialog(
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
                      icon: const AdaptiveIcon(Icons.close),
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
                      AppSegmentedControl<bool>(
                        segments: [
                          AppSegment(
                            value: false,
                            label: t.import.modeLink,
                            icon: const AdaptiveIcon(Icons.link),
                          ),
                          AppSegment(
                            value: true,
                            label: t.import.modeFile,
                            icon: const AdaptiveIcon(Icons.file_open_outlined),
                          ),
                        ],
                        selected: _fileMode,
                        onChanged: loading || _fileBusy
                            ? (_) {}
                            : (v) => setState(() => _fileMode = v),
                      ),
                      const SizedBox(height: 16),
                      if (!_fileMode) ...[
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
                          AppSegmentedControl<_Guide>(
                            segments: [
                              for (final g in _Guide.values)
                                AppSegment(value: g, label: g.label),
                            ],
                            selected: _guide,
                            onChanged: (g) => setState(() {
                              _guide = g;
                              _method = 0;
                            }),
                          ),
                          if (methods.length > 1) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final (i, m) in methods.indexed)
                                  SettingsChoiceChip(
                                    label: m.label,
                                    isSelected: i == _method,
                                    onTap: () => setState(() => _method = i),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          SettingsGroup(
                            children: [
                              for (final (i, step) in steps.indexed)
                                _Step(
                                  i + 1,
                                  step.text,
                                  command: step.command,
                                  onOpenLink: step.url == null
                                      ? null
                                      : () => ref
                                            .read(urlOpenerProvider)
                                            .open(Uri.parse(step.url!)),
                                ),
                              _Step(
                                steps.length + 1,
                                t.import.finalStep,
                                last: true,
                              ),
                            ],
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              icon: const AdaptiveIcon(
                                Icons.open_in_new,
                                size: 18,
                              ),
                              label: Text(t.import.guideFull),
                              onPressed: _openFullGuide,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                                  icon: const AdaptiveIcon(Icons.close),
                                  onPressed: loading ? null : _controller.clear,
                                )
                              : null,
                        ),
                        if (_prefill != null &&
                            _controller.text.trim().isNotEmpty &&
                            !usingSaved)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                            child: Text(
                              switch (_prefill!) {
                                _Prefill.clipboard =>
                                  t.import.prefilledClipboard,
                                _Prefill.shared => t.import.prefilledShared,
                              },
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final paste = M3EButton(
                              style: M3EButtonStyle.tonal,
                              size: M3EButtonSize.md,
                              icon: const AdaptiveIcon(Icons.content_paste),
                              label: Text(t.import.paste),
                              onPressed: loading ? null : _paste,
                            );
                            final update = M3EButton(
                              size: M3EButtonSize.md,
                              icon: const AdaptiveIcon(Icons.sync),
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
                      ] else ...[
                        ...fileImport,
                        SettingsSectionHeader(title: t.import.fileGuideTitle),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            for (final source in _FileSource.values)
                              SettingsChoiceChip(
                                label: source.label,
                                isSelected: source == _fileSource,
                                onTap: () =>
                                    setState(() => _fileSource = source),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SettingsGroup(
                          children: [
                            for (final (i, step)
                                in _fileSource.steps(t).indexed)
                              _Step(
                                i + 1,
                                step.text,
                                onOpenLink: step.url == null
                                    ? null
                                    : () => ref
                                          .read(urlOpenerProvider)
                                          .open(Uri.parse(step.url!)),
                              ),
                            _Step(
                              _fileSource.steps(t).length + 1,
                              t.import.fileGuide.last,
                              last: true,
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                          child: Text(
                            t.import.trackerNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            icon: const AdaptiveIcon(
                              Icons.open_in_new,
                              size: 18,
                            ),
                            label: Text(t.import.guideFull),
                            onPressed: _openFullGuide,
                          ),
                        ),
                      ],
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

/// Where the link in the field came from before the user typed anything.
enum _Prefill { clipboard, shared }

/// The apps whose exported file can be imported here.
enum _FileSource {
  solaris('Solaris Record'),
  tracker('WuWa Tracker');

  const _FileSource(this.label);

  final String label;

  List<_GuideStep> steps(Translations t) {
    final g = t.import.fileGuide;
    return switch (this) {
      solaris => [_GuideStep(g.solaris.step1), _GuideStep(g.solaris.step2)],
      tracker => [
        _GuideStep(g.tracker.step1, url: _trackerDataUrl),
        _GuideStep(g.tracker.step2),
      ],
    };
  }
}

/// Platforms with their own way of finding the convene URL.
enum _Guide {
  windows('Windows'),
  android('Android'),
  macos('macOS'),
  linux('Linux');

  const _Guide(this.label);

  final String label;

  static _Guide forPlatform(TargetPlatform p) => switch (p) {
    TargetPlatform.windows => windows,
    TargetPlatform.iOS || TargetPlatform.android => android,
    TargetPlatform.macOS => macos,
    _ => linux,
  };

  /// The ways to get the link on this platform; one means no choice to show.
  List<_Method> methods(Translations t) {
    final g = t.import.guide;
    final i = t.import;
    return switch (this) {
      windows => [
        _Method(i.methodAutomatic, [
          _GuideStep(g.openGame),
          _GuideStep(g.windows.auto.step2, command: _windowsCommand),
          _GuideStep(g.windows.auto.step3),
        ]),
      ],
      android => [
        _Method(i.methodAirplane, [
          _GuideStep(g.android.airplane, url: _airplaneVideoUrl),
        ]),
        _Method('Ascent', [
          _GuideStep(g.android.ascent1, url: _ascentUrl),
          _GuideStep(g.android.ascent2, url: _ascentGuideUrl),
        ]),
      ],
      macos => [
        _Method(i.methodAutomatic, [
          _GuideStep(g.openGame),
          _GuideStep(g.macos.auto.step2, command: _macosCommand),
          _GuideStep(g.macos.auto.step3),
        ]),
      ],
      linux => [
        _Method(i.methodAutomatic, [
          _GuideStep(g.openGame),
          _GuideStep(g.linux.step2, command: _desktopCommand),
          _GuideStep(g.linux.step3),
        ]),
      ],
    };
  }
}

// The scripts are pinned to the commit WuWa Tracker itself links to, so what
// runs is the code that was reviewed, not whatever master holds later.
const _trackerRaw =
    'https://raw.githubusercontent.com/wuwatracker/wuwatracker/'
    '747a48b1b994baa9c372a4fb933ea7588428bd4b';
const _windowsCommand =
    'iwr -UseBasicParsing -Headers @{"User-Agent"="Mozilla/5.0"} '
    '$_trackerRaw/import.ps1 | iex';
const _desktopCommand = 'curl -sSL "$_trackerRaw/import.sh" | bash';
// macOS keeps the log in the game's sandbox container, so it has its own
// command (it decodes the obfuscated Client.log before searching it).
const _macosCommand =
    r'''log="$HOME/Library/Containers/com.kurogame.wutheringwaves.global/Data/Library/Logs/Client/Client.log"; pattern='https://aki-gm-resources(-oversea)?\.aki-game\.(net|com)/aki/gacha/index\.html#/record[^"[:space:]]*'; decode_client_log() { if command -v python3 >/dev/null 2>&1; then python3 -c 'import sys; data = sys.stdin.buffer.read(); sys.stdout.buffer.write(bytes(byte ^ (0xA5 if (byte & 0x0F) % 2 == 1 else 0xEF) for byte in data))'; elif command -v perl >/dev/null 2>&1; then perl -0777 -pe 's/(.)/chr((ord($1) & 0x0f) % 2 == 1 ? ord($1) ^ 0xa5 : ord($1) ^ 0xef)/gse'; else return 1; fi; }; url=$(decode_client_log < "$log" | grep -aEo "$pattern" | tail -n 1); [ -z "$url" ] && url=$(grep -aEo "$pattern" "$log" | tail -n 1); [ -n "$url" ] && echo "$url" | pbcopy && echo "Link copied to clipboard, paste it in wuwatracker.com and click the Import Data button." || echo "Cannot find the convene history URL in your Client.log! Please try another import method."''';
const _ascentUrl = 'https://github.com/4o3F/Ascent/releases/tag/2.1.6';
const _ascentGuideUrl =
    'https://gist.github.com/Mirai0009/8615e52e09083de9c0ea2dc00dc62ea8';
const _trackerDataUrl = 'https://wuwatracker.com/settings/data';
const _airplaneVideoUrl = 'https://www.youtube.com/watch?v=EP6ib3POGKE';

/// One way to get the data in, with its own steps.
class _Method {
  const _Method(this.label, this.steps);

  final String label;
  final List<_GuideStep> steps;
}

/// One guide step, optionally with a shell command or a link under it.
class _GuideStep {
  const _GuideStep(this.text, {this.command, this.url});

  final String text;
  final String? command;
  final String? url;
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
        borderRadius: context.tokens.borderRadiusCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdaptiveIcon(
                Icons.check_circle,
                color: scheme.onPrimaryContainer,
              ),
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
            icon: const AdaptiveIcon(Icons.insights),
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
  const _Step(
    this.number,
    this.text, {
    this.command,
    this.onOpenLink,
    this.last = false,
  });

  final int number;
  final String text;

  /// A shell command shown under the text, selectable and copyable.
  final String? command;

  /// Shows an "Open link" button under the text when set.
  final VoidCallback? onOpenLink;
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
      footer: command != null
          ? _CommandBox(command!)
          : onOpenLink == null
          ? null
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const AdaptiveIcon(Icons.open_in_new, size: 18),
                label: Text(context.t.import.openLink),
                onPressed: onOpenLink,
              ),
            ),
    );
  }
}

/// A selectable monospace command with a copy button.
class _CommandBox extends StatelessWidget {
  const _CommandBox(this.command);

  final String command;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsetsDirectional.only(start: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.tokens.radiusCover),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              command,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: scheme.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: context.t.import.copyCommand,
            icon: const AdaptiveIcon(Icons.copy, size: 18),
            onPressed: () => Clipboard.setData(ClipboardData(text: command)),
          ),
        ],
      ),
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
                    ? AdaptiveIcon(Icons.check_circle, color: scheme.primary)
                    : p.index == currentIndex
                    ? const M3EProgressIndicator.circular(strokeWidth: 3)
                    : AdaptiveIcon(
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
