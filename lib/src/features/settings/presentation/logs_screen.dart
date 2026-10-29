import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/logging/app_log.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/settings_group.dart';
import 'log_actions.dart';

/// Which records the viewer shows.
enum _LevelFilter {
  all(Level.ALL),
  warnings(Level.WARNING),
  errors(Level.SEVERE);

  const _LevelFilter(this.min);

  final Level min;

  String label(Translations t) => switch (this) {
    all => t.logs.levelAll,
    warnings => t.logs.levelWarnings,
    errors => t.logs.levelErrors,
  };
}

/// In-app viewer for this session's debug log: search, filter by severity,
/// copy and export. Earlier days are only in the exported file.
class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final _search = TextEditingController();
  var _filter = _LevelFilter.all;
  Timer? _refresh;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    // New records arrive from anywhere, including during a build, so poll
    // instead of listening.
    _refresh = Timer.periodic(
      const Duration(seconds: 1),
      (_) => mounted ? setState(() {}) : null,
    );
  }

  @override
  void dispose() {
    _refresh?.cancel();
    _search.dispose();
    super.dispose();
  }

  List<LogEntry> _visible(List<LogEntry> all) {
    final query = _search.text.trim().toLowerCase();
    return [
      for (final e in all.reversed)
        if (e.level >= _filter.min &&
            (query.isEmpty ||
                e.message.toLowerCase().contains(query) ||
                e.logger.toLowerCase().contains(query)))
          e,
    ];
  }

  Future<void> _copy(List<LogEntry> entries) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(
      ClipboardData(text: entries.reversed.map((e) => e.text).join('\n')),
    );
    messenger.showSnackBar(
      SnackBar(content: Text(t.logs.copied(n: entries.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final all = AppLog.entries;
    final shown = _visible(all);
    final errors = all.where((e) => e.level >= Level.SEVERE).length;
    final warnings = all
        .where((e) => e.level >= Level.WARNING && e.level < Level.SEVERE)
        .length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(
            title: t.logs.title,
            showBack: true,
            actions: [
              IconButton(
                tooltip: t.logs.copy,
                icon: const AdaptiveIcon(Icons.copy_all_outlined),
                onPressed: shown.isEmpty ? null : () => _copy(shown),
              ),
              IconButton(
                tooltip: t.data.exportLogs,
                icon: const AdaptiveIcon(Icons.ios_share),
                onPressed: () => exportLogs(context, ref),
              ),
              IconButton(
                tooltip: t.logs.clear,
                icon: const AdaptiveIcon(Icons.delete_outline),
                onPressed: () async {
                  await clearLogs(context, ref);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
          SliverAdaptivePadding(
            clearBottomInset: false,
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: errors > 0
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      iconColor: errors > 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      title: errors + warnings == 0
                          ? t.logs.summaryClean
                          : t.logs.summaryCounts(
                              errors: errors,
                              warnings: warnings,
                            ),
                      subtitle: t.logs.sessionNote,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _search,
                  outlined: true,
                  hint: t.logs.searchHint,
                  prefix: const AdaptiveIcon(Icons.search),
                  suffix: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: t.import.clear,
                          icon: const AdaptiveIcon(Icons.close),
                          onPressed: _search.clear,
                        ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final f in _LevelFilter.values)
                      SettingsChoiceChip(
                        label: f.label(t),
                        isSelected: f == _filter,
                        onTap: () => setState(() => _filter = f),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (shown.isEmpty)
            SliverFillBody(
              child: Center(
                child: Text(
                  all.isEmpty ? t.logs.empty : t.logs.noMatch,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverAdaptivePadding(
              sliver: SliverList.separated(
                itemCount: shown.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, i) => _LogTile(entry: shown[i]),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

/// One record: a level-coloured bar, then time, logger and the message.
class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = entry.level >= Level.SEVERE
        ? scheme.error
        : entry.level >= Level.WARNING
        ? scheme.tertiary
        : entry.level >= Level.INFO
        ? scheme.primary
        : scheme.outline;
    final time = entry.time;
    String two(int v) => v.toString().padLeft(2, '0');
    final detail = [
      if (entry.error != null) entry.error!,
      if (entry.stackTrace != null) entry.stackTrace!,
    ].join('\n');

    return Container(
      decoration: BoxDecoration(
        color: groupColor(context),
        borderRadius: BorderRadius.circular(context.tokens.radiusCover),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${two(time.hour)}:${two(time.minute)}:'
                            '${two(time.second)}  ${entry.level.name}  '
                            '[${entry.logger}]\n',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: entry.message),
                      if (detail.isNotEmpty)
                        TextSpan(
                          text: '\n$detail',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
