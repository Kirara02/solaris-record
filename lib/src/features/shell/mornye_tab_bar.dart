import 'package:flutter/physics.dart';
import 'package:liquid_glass_easy/liquid_glass_easy.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/theme/mornye_icons.dart';
import '../../shared/theme/mornye_theme.dart';
import '../../shared/widgets/mornye_glass.dart';
import 'nav_destination.dart';

/// Floating glass capsule tab bar: a rounded glass pill inset from the screen
/// edges, icon over label, the selected tab in the accent colour.
///
/// The selection capsule springs between tabs (a little overshoot on landing).
/// Holding a tab or dragging across the bar swells the capsule and turns it
/// into a glass lens that follows the finger; releasing lets it settle back
/// with a bounce.
class MornyeTabBar extends StatefulWidget {
  const MornyeTabBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.blur,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool blur;

  @override
  State<MornyeTabBar> createState() => MornyeTabBarState();
}

class MornyeTabBarState extends State<MornyeTabBar>
    with TickerProviderStateMixin {
  static const _height = 64.0;
  static const _radius = 32.0;
  static const _pillRadius = _radius - 4;
  static const _widthGrowth = 0.22;
  static const _heightGrowth = 0.1;
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 380,
    damping: 21,
  );

  /// Held amount, 0..1 (overshoots on press for the swell).
  late final _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 380),
  );
  late final _pressCurve = CurvedAnimation(
    parent: _press,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeOutCubic,
  );

  /// Capsule position in alignment units (-1 first tab .. 1 last tab).
  late final _pos = AnimationController.unbounded(
    vsync: this,
    value: _alignmentOf(widget.selectedIndex),
  );

  int? _previewIndex;

  /// Tab under the finger of the current drag. Kept apart from the preview,
  /// which the pointer-up listener clears before the drag end arrives.
  int? _dragIndex;
  bool _dragging = false;

  int get _count => widget.destinations.length;

  double _alignmentOf(int index) =>
      _count > 1 ? -1 + 2 * index / (_count - 1) : 0;

  void _settle(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pos.value = _alignmentOf(index);
      return;
    }
    _pos.animateWith(
      SpringSimulation(
        _spring,
        _pos.value,
        _alignmentOf(index),
        _pos.isAnimating ? _pos.velocity : 0,
      ),
    );
  }

  int _indexAt(double x, double width) =>
      (x / width * _count).floor().clamp(0, _count - 1);

  void _hold(int index) {
    if (_previewIndex == null) _press.forward();
    setState(() => _previewIndex = index);
    _settle(index);
  }

  void _release() {
    _press.reverse();
    setState(() => _previewIndex = null);
  }

  void _drag(double x, double width) {
    if (width <= 0) return;
    final half = width / _count / 2;
    final clamped = x.clamp(half, width - half);
    _dragging = true;
    _pos.stop();
    _pos.value = width <= half * 2
        ? 0
        : (clamped - half) / (width - 2 * half) * 2 - 1;
    _dragIndex = _indexAt(x, width);
    setState(() => _previewIndex = _dragIndex);
  }

  @override
  void didUpdateWidget(MornyeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex && !_dragging) {
      _settle(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _pressCurve.dispose();
    _press.dispose();
    _pos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final shown = _previewIndex ?? widget.selectedIndex;
    // High contrast turns the see-through effects off, like the bar itself.
    final lens = widget.blur && !MediaQuery.highContrastOf(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          height: _height,
          child: MornyeGlass(
            level: widget.blur
                ? MornyeGlassLevel.liquid
                : MornyeGlassLevel.flat,
            borderRadius: BorderRadius.circular(_radius),
            fill: scheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return Listener(
                    onPointerDown: (e) =>
                        _hold(_indexAt(e.localPosition.dx, width)),
                    onPointerUp: (_) => _release(),
                    onPointerCancel: (_) {
                      _release();
                      _settle(widget.selectedIndex);
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (e) => widget.onSelected(
                        _indexAt(e.localPosition.dx, width),
                      ),
                      onHorizontalDragStart: (e) =>
                          _drag(e.localPosition.dx, width),
                      onHorizontalDragUpdate: (e) =>
                          _drag(e.localPosition.dx, width),
                      onHorizontalDragEnd: (_) {
                        final index = _dragIndex ?? widget.selectedIndex;
                        _dragging = false;
                        _dragIndex = null;
                        _settle(index);
                        widget.onSelected(index);
                      },
                      onHorizontalDragCancel: () {
                        _dragging = false;
                        _dragIndex = null;
                        _settle(widget.selectedIndex);
                      },
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pos, _pressCurve]),
                        builder: (context, _) {
                          final held = _pressCurve.value;
                          final heldAlpha = held.clamp(0.0, 1.0);
                          Widget capsule(Widget child) => Positioned.fill(
                            child: IgnorePointer(
                              child: Align(
                                alignment: Alignment(_pos.value, 0),
                                child: FractionallySizedBox(
                                  widthFactor: 1 / _count,
                                  heightFactor: 1,
                                  child: Transform.scale(
                                    scaleX: 1 + _widthGrowth * held,
                                    scaleY: 1 + _heightGrowth * held,
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          );
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              capsule(
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: scheme.onSurface.withValues(
                                      alpha:
                                          (1 - heldAlpha) *
                                          (dark ? 0.16 : 0.08),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      _pillRadius,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  for (final (i, d)
                                      in widget.destinations.indexed)
                                    Expanded(
                                      child: _TabItem(
                                        destination: d,
                                        selected: i == shown,
                                      ),
                                    ),
                                ],
                              ),
                              if (lens && heldAlpha > 0.01)
                                capsule(
                                  Opacity(
                                    opacity: heldAlpha,
                                    child: LiquidGlassLens(
                                      style: LiquidGlassStyle(
                                        shape:
                                            LiquidGlassShape.roundedRectangle(
                                              cornerRadius: _pillRadius,
                                            ),
                                        color: Colors.white.withValues(
                                          alpha: dark ? 0.08 : 0.22,
                                        ),
                                        // Outlines off drops the lens rim too.
                                        specular: context.mornye.glassOutlines
                                            ? null
                                            : const LiquidGlassLight.specular(
                                                intensity: 0,
                                                oppositeIntensity: 0,
                                              ),
                                        // Clearer glass bends more.
                                        refractionIndex:
                                            1.02 +
                                            0.04 * context.mornye.glassClarity,
                                        refractionWidth: 18,
                                      ),
                                    ),
                                  ),
                                )
                              else if (heldAlpha > 0.01)
                                capsule(
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: heldAlpha * (dark ? 0.1 : 0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        _pillRadius,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.destination, required this.selected});

  final NavDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = selected ? scheme.primary : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: ExcludeSemantics(
        child: IconTheme(
          data: IconThemeData(size: 25, color: color),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selected
                  ? destination.selectedIcon
                  : AdaptiveIcon(destination.icon),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
