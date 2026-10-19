import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/settings_group.dart';
import '../domain/history_view.dart';

/// Localised name of a sort column.
String sortFieldLabel(Translations t, HistorySortField field) =>
    switch (field) {
      HistorySortField.time => t.stats.sortFieldTime,
      HistorySortField.name => t.stats.sortFieldName,
      HistorySortField.type => t.stats.sortFieldType,
      HistorySortField.rarity => t.stats.sortFieldRarity,
      HistorySortField.pity => t.stats.sortFieldPity,
    };

/// Filter dialog for the history: rarity, item type, and the sort column and
/// direction.
/// Resolves to the chosen filter (search text carried over) or `null` when
/// dismissed or cancelled.
Future<HistoryFilter?> showHistoryFilterDialog(
  BuildContext context, {
  required HistoryFilter current,
  required List<HistoryEntry> entries,
}) => showDialog<HistoryFilter>(
  context: context,
  builder: (context) =>
      _HistoryFilterDialog(current: current, entries: entries),
);

class _HistoryFilterDialog extends StatefulWidget {
  const _HistoryFilterDialog({required this.current, required this.entries});

  final HistoryFilter current;
  final List<HistoryEntry> entries;

  @override
  State<_HistoryFilterDialog> createState() => _HistoryFilterDialogState();
}

class _HistoryFilterDialogState extends State<_HistoryFilterDialog> {
  late Set<int> _rarities = {...widget.current.rarities};
  late Set<String> _types = {...widget.current.types};
  late HistorySortField _sortField = widget.current.sortField;
  late bool _newestFirst = widget.current.newestFirst;

  HistoryFilter get _result => widget.current.copyWith(
    rarities: _rarities,
    types: _types,
    sortField: _sortField,
    newestFirst: _newestFirst,
  );

  void _toggle<T>(Set<T> set, T value) => setState(() {
    set.contains(value) ? set.remove(value) : set.add(value);
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final counts = rarityCounts(widget.entries);
    final types = typeCounts(widget.entries);

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        child,
      ],
    );

    return AppAlertDialog(
      title: Text(t.stats.filterTitle),
      scrollable: true,
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            section(
              t.stats.filterRarity,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (rarity, label, count) in [
                    (5, t.stats.fiveStars, counts.five),
                    (4, t.stats.fourStars, counts.four),
                    (3, t.stats.threeStars, counts.three),
                  ])
                    SettingsChoiceChip(
                      label: '$label · $count',
                      isSelected: _rarities.contains(rarity),
                      onTap: () => _toggle(_rarities, rarity),
                    ),
                ],
              ),
            ),
            if (types.length > 1)
              section(
                t.stats.filterType,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (type, count) in types)
                      SettingsChoiceChip(
                        label: '$type · $count',
                        isSelected: _types.contains(type),
                        onTap: () => _toggle(_types, type),
                      ),
                  ],
                ),
              ),
            section(
              t.stats.filterSort,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final field in HistorySortField.values)
                    SettingsChoiceChip(
                      label: sortFieldLabel(t, field),
                      isSelected: _sortField == field,
                      onTap: () => setState(() {
                        // A new column starts in its natural direction.
                        if (_sortField != field) {
                          _sortField = field;
                          _newestFirst = field.startsDescending;
                        }
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SettingsChoiceChip(
                  label: _sortField == HistorySortField.time
                      ? t.stats.sortNewest
                      : t.stats.sortDesc,
                  isSelected: _newestFirst,
                  onTap: () => setState(() => _newestFirst = true),
                ),
                SettingsChoiceChip(
                  label: _sortField == HistorySortField.time
                      ? t.stats.sortOldest
                      : t.stats.sortAsc,
                  isSelected: !_newestFirst,
                  onTap: () => setState(() => _newestFirst = false),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _rarities = {};
            _types = {};
            _sortField = HistorySortField.time;
            _newestFirst = true;
          }),
          child: Text(t.stats.filterReset),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.accounts.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _result),
          child: Text(t.stats.filterApply),
        ),
      ],
    );
  }
}
