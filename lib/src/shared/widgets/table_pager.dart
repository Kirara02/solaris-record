import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../i18n/gen/strings.g.dart';
import 'outlined_icon_button.dart';

/// Row counts offered by the "rows per page" menu.
const pageSizeOptions = [10, 20, 30, 50, 100];

/// 1-based inclusive range shown on [page] (0-based) as `(from, to)`; `(0, 0)`
/// when there is nothing to show.
(int, int) pageRange(int page, int pageSize, int total) {
  if (total <= 0 || pageSize <= 0) return (0, 0);
  final from = page * pageSize + 1;
  final to = (from + pageSize - 1).clamp(from, total);
  return (from, to);
}

/// Table footer: the "Rows per page" menu on the left, "1–10 of 56" with
/// first / previous / next / last buttons on the right, always on one line.
/// When the width is too small for the "Rows per page" caption it is dropped
/// (the menu keeps it as a tooltip) and the buttons shrink.
class TablePager extends StatelessWidget {
  const TablePager({
    super.key,
    required this.page,
    required this.pageCount,
    required this.pageSize,
    required this.total,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  /// Below this width the "Rows per page" caption is hidden.
  static const captionBreakpoint = 560.0;

  /// Narrowest width the single-line footer is laid out at.
  static const minRowWidth = 320.0;

  final int page;
  final int pageCount;
  final int pageSize;
  final int total;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (from, to) = pageRange(page, pageSize, total);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomy = constraints.maxWidth >= captionBreakpoint;
          final button = roomy ? 40.0 : 36.0;
          final gap = roomy ? 6.0 : 4.0;

          Widget nav(IconData icon, String tooltip, int? target) =>
              OutlinedIconButton(
                icon: icon,
                tooltip: tooltip,
                size: button,
                onPressed: target == null ? null : () => onPageChanged(target),
              );

          final row = Row(
            children: [
              if (roomy) ...[
                Text(
                  t.stats.rowsPerPage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              _PageSizeMenu(value: pageSize, onChanged: onPageSizeChanged),
              const Spacer(),
              Text(
                t.stats.rangeOf(from: from, to: to, total: total),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: roomy ? 16 : 8),
              nav(Icons.first_page, t.stats.firstPage, page > 0 ? 0 : null),
              SizedBox(width: gap),
              nav(
                Icons.chevron_left,
                t.stats.previousPage,
                page > 0 ? page - 1 : null,
              ),
              SizedBox(width: gap),
              nav(
                Icons.chevron_right,
                t.stats.nextPage,
                page < pageCount - 1 ? page + 1 : null,
              ),
              SizedBox(width: gap),
              nav(
                Icons.last_page,
                t.stats.lastPage,
                page < pageCount - 1 ? pageCount - 1 : null,
              ),
            ],
          );

          // The row is laid out at no less than [minRowWidth]; narrower windows
          // scale it down instead of overflowing.
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: math.max(constraints.maxWidth, minRowWidth),
              child: row,
            ),
          );
        },
      ),
    );
  }
}

class _PageSizeMenu extends StatelessWidget {
  const _PageSizeMenu({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return PopupMenuButton<int>(
      tooltip: context.t.stats.rowsPerPage,
      // The default 8px padding would add 16px of dead space to the footer.
      padding: EdgeInsets.zero,
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in pageSizeOptions)
          PopupMenuItem(value: option, child: Text('$option')),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 14, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$value', style: theme.textTheme.bodyLarge),
            const SizedBox(width: 6),
            Icon(Icons.expand_more, size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
