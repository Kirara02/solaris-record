import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../shared/theme/mornye_icons.dart';
import 'nav_destination.dart';
import 'rail_brand.dart';
import 'rail_metrics.dart';

/// Sidebar content of the Mornye style, replacing the Material rail: brand,
/// the main destinations, the pull-type group, and the pinned bottom
/// destination. Every row draws its own selection capsule, which springs in
/// and firms up slightly while the row is pressed.
class MornyeSidebar extends StatelessWidget {
  const MornyeSidebar({
    super.key,
    required this.main,
    required this.bottom,
    required this.bottomKey,
    required this.selectedIndex,
    required this.bottomSelected,
    required this.groupHeader,
    required this.poolLabels,
    required this.groupOpen,
    required this.onSelected,
    required this.onBottomTap,
  });

  final List<NavDestination> main;
  final NavDestination bottom;
  final Key bottomKey;

  /// Index into [main] followed by the pull types; -1 for none.
  final int selectedIndex;
  final bool bottomSelected;
  final Widget groupHeader;
  final List<String> poolLabels;
  final bool groupOpen;
  final ValueChanged<int> onSelected;
  final VoidCallback onBottomTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      // The pinned bottom row must span the panel: its content is positioned,
      // so with loose width it would collapse to nothing.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: RailBrand(expanded: true),
        ),
        Divider(color: scheme.outlineVariant),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final (i, d) in main.indexed)
                MornyeSidebarItem(
                  icon: i == selectedIndex
                      ? d.selectedIcon
                      : AdaptiveIcon(d.icon),
                  label: d.label,
                  selected: i == selectedIndex,
                  onTap: () => onSelected(i),
                ),
              groupHeader,
              if (groupOpen)
                for (final (i, label) in poolLabels.indexed)
                  MornyeSidebarItem(
                    label: label,
                    selected: main.length + i == selectedIndex,
                    short: true,
                    onTap: () => onSelected(main.length + i),
                  ),
            ],
          ),
        ),
        Divider(color: scheme.outlineVariant),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: MornyeSidebarItem(
            key: bottomKey,
            icon: bottomSelected
                ? bottom.selectedIcon
                : AdaptiveIcon(bottom.icon),
            label: bottom.label,
            selected: bottomSelected,
            onTap: onBottomTap,
          ),
        ),
      ],
    );
  }
}

/// One sidebar row. The capsule behind the selected row springs in (a little
/// overshoot) and, while the row is pressed, swells slightly and darkens.
class MornyeSidebarItem extends StatefulWidget {
  const MornyeSidebarItem({
    super.key,
    this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.short = false,
  });

  final Widget? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Nested pull-type rows: no icon, a little shorter and indented.
  final bool short;

  @override
  State<MornyeSidebarItem> createState() => _MornyeSidebarItemState();
}

class _MornyeSidebarItemState extends State<MornyeSidebarItem>
    with TickerProviderStateMixin {
  // Rows sit close together, so the press swell stays small: a lens or a
  // bigger capsule would refract or cover the text of the rows next to it.
  static const _widthGrowth = 0.02;
  static const _heightGrowth = 0.05;

  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    reverseDuration: const Duration(milliseconds: 360),
  );
  late final _pressCurve = CurvedAnimation(
    parent: _press,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeOutCubic,
  );
  late final _select = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    reverseDuration: const Duration(milliseconds: 180),
    value: widget.selected ? 1 : 0,
  );
  late final _selectCurve = CurvedAnimation(
    parent: _select,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeOut,
  );

  @override
  void didUpdateWidget(MornyeSidebarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _select.value = widget.selected ? 1 : 0;
      } else {
        widget.selected ? _select.forward() : _select.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pressCurve.dispose();
    _selectCurve.dispose();
    _press.dispose();
    _select.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final height = widget.short
        ? RailMetrics.shortItemHeight
        : RailMetrics.itemHeight;
    final radius = BorderRadius.circular(height / 2);
    final color = widget.selected ? scheme.primary : scheme.onSurface;

    Widget capsule(Widget child) => Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pressCurve, _selectCurve]),
          builder: (context, _) {
            final held = _pressCurve.value;
            return Transform.scale(
              scaleX: (0.94 + 0.06 * _selectCurve.value) + _widthGrowth * held,
              scaleY: (0.9 + 0.1 * _selectCurve.value) + _heightGrowth * held,
              child: child,
            );
          },
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Listener(
        onPointerDown: (_) => _press.forward(),
        onPointerUp: (_) => _press.reverse(),
        onPointerCancel: (_) => _press.reverse(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Semantics(
            button: true,
            selected: widget.selected,
            label: widget.label,
            child: ExcludeSemantics(
              child: SizedBox(
                height: height,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    capsule(
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _pressCurve,
                          _selectCurve,
                        ]),
                        builder: (context, _) {
                          final held = _pressCurve.value.clamp(0.0, 1.0);
                          final selected = _selectCurve.value.clamp(0.0, 1.0);
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              // Selected: soft fill. Pressed: a firmer one.
                              color: scheme.onSurface.withValues(
                                alpha: math.max(
                                  selected * (dark ? 0.16 : 0.08),
                                  held * (dark ? 0.26 : 0.14),
                                ),
                              ),
                              borderRadius: radius,
                            ),
                          );
                        },
                      ),
                    ),
                    // Fill the row so the content is centred vertically; a plain
                    // Stack child would sit at the top.
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: widget.short ? 44 : 16,
                          right: 16,
                        ),
                        child: Row(
                          children: [
                            if (widget.icon != null) ...[
                              IconTheme(
                                data: IconThemeData(size: 22, color: color),
                                child: widget.icon!,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: color,
                                  fontWeight: widget.selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
