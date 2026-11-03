import 'package:flutter/cupertino.dart' show CupertinoButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import '../theme/mornye_icons.dart';
import '../theme/mornye_theme.dart';
import 'mornye_glass.dart';

/// A single choice or filter toggle in the current style.
///
/// Material draws an expressive filter chip. Mornye draws a flat tonal
/// capsule with a check when selected, which is what a sheet or dialog wants.
/// On a page, over content that scrolls, set [glass] for Mornye's glass
/// capsule instead: it does not blur (a plain page has nothing to blur), only
/// tints, and the selection is a wash of the accent.
class AppChoiceChip extends ConsumerWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.leadingBuilder,
    this.trailing,
    this.glass = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  /// A Material icon, swapped for its Cupertino twin under Mornye.
  final IconData? icon;

  /// Builds a leading widget from the chip's current foreground colour, for
  /// art that must follow it.
  final Widget Function(Color color)? leadingBuilder;

  /// Shown after the label.
  final Widget? trailing;

  /// Mornye only: the glass capsule for chips that sit on a page.
  final bool glass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    if (!context.isMornye) {
      final color = selected ? scheme.onSecondaryContainer : scheme.onSurface;
      final leading = leadingBuilder != null
          ? leadingBuilder!(color)
          : icon == null
          ? null
          : AdaptiveIcon(icon, size: 18);
      return M3EChip(
        label: label,
        type: M3EChipType.filter,
        selected: selected,
        leading: leading,
        trailing: trailing,
        onPressed: onSelected,
      );
    }

    final foreground = selected ? scheme.primary : scheme.onSurface;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: foreground,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    );
    final leading = leadingBuilder != null
        ? leadingBuilder!(foreground)
        : icon == null
        ? null
        : AdaptiveIcon(
            icon,
            size: 18,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 8)],
        if (!glass && selected) ...[
          AdaptiveIcon(Icons.check, size: 18, color: foreground),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, style: textStyle)),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );

    if (glass) {
      return Semantics(
        button: true,
        selected: selected,
        label: label,
        onTap: onSelected,
        excludeSemantics: true,
        // Scrolls with the page over a plain background, so tint only.
        child: MornyeGlass(
          level: ref.watch(glassLevelProvider),
          samplesBackdrop: false,
          borderRadius: BorderRadius.circular(24),
          fill: scheme.surfaceContainer,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSelected,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: selected
                    ? scheme.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: Size.zero,
        borderRadius: BorderRadius.circular(24),
        color: selected
            ? scheme.primary.withValues(alpha: 0.12)
            : MornyeTheme.controlFill(context),
        onPressed: onSelected,
        child: content,
      ),
    );
  }
}
