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
    required this.level,
    this.minimized = false,
    this.onExpand,
  });

  final List<NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final MornyeGlassLevel level;

  /// Folded into one capsule showing the selected tab (after a scroll down).
  final bool minimized;

  /// Called when the folded capsule is tapped.
  final VoidCallback? onExpand;

  @override
  State<MornyeTabBar> createState() => MornyeTabBarState();
}

class MornyeTabBarState extends State<MornyeTabBar>
    with TickerProviderStateMixin {
  static const _height = 64.0;

  /// Side of the folded capsule.
  static const _minimizedSize = 56.0;
  static const _radius = 32.0;
  static const _pillRadius = _radius - 4;
  // Mornye's capsule projects only slightly when held.
  static const _widthGrowth = 0.025;
  static const _heightGrowth = 0.06;
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

  /// Folded amount, 0 (full bar) to 1 (one capsule).
  late final _fold = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: widget.minimized ? 1 : 0,
  );
  late final _foldCurve = CurvedAnimation(
    parent: _fold,
    curve: Curves.easeInOutCubic,
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
    if (oldWidget.minimized != widget.minimized) {
      final target = widget.minimized ? 1.0 : 0.0;
      if (MediaQuery.disableAnimationsOf(context)) {
        _fold.value = target;
      } else {
        _fold.animateTo(target);
      }
    }
  }

  @override
  void dispose() {
    _foldCurve.dispose();
    _fold.dispose();
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
    final translucent =
        widget.level != MornyeGlassLevel.flat && !context.glassContrastBlocked;
    final lens = widget.level == MornyeGlassLevel.liquid && translucent;
    final content = Padding(
      padding: const EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Listener(
            onPointerDown: (e) => _hold(_indexAt(e.localPosition.dx, width)),
            onPointerUp: (_) => _release(),
            onPointerCancel: (_) {
              _release();
              _settle(widget.selectedIndex);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (e) =>
                  widget.onSelected(_indexAt(e.localPosition.dx, width)),
              onHorizontalDragStart: (e) => _drag(e.localPosition.dx, width),
              onHorizontalDragUpdate: (e) => _drag(e.localPosition.dx, width),
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
                        // Mornye draws the resting capsule as glass
                        // too, with the lighter navigation tint.
                        Opacity(
                          opacity: 1 - heldAlpha,
                          child: translucent
                              ? MornyeGlass(
                                  level: widget.level,
                                  borderRadius: BorderRadius.circular(
                                    _pillRadius,
                                  ),
                                  fill: scheme.surfaceContainerHigh,
                                  tintOpacity: dark ? 0.36 : 0.49,
                                  child: const SizedBox.expand(),
                                )
                              // Without blur (or on high contrast) a
                              // plain wash keeps the selection visible
                              // on the solid bar.
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: scheme.onSurface.withValues(
                                      alpha: dark ? 0.16 : 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      _pillRadius,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final (i, d) in widget.destinations.indexed)
                            Expanded(
                              child: _TabItem(
                                destination: d,
                                selected: i == shown,
                                color: scheme.onSurface,
                              ),
                            ),
                        ],
                      ),
                      // The accent layer is the same row, visible
                      // only inside the capsule: icons and labels
                      // change colour as the capsule slides under
                      // them, not when it lands.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ExcludeSemantics(
                            child: ClipPath(
                              clipper: _CapsuleClipper(
                                alignment: _pos.value,
                                count: _count,
                                scaleX: 1 + _widthGrowth * held,
                                scaleY: 1 + _heightGrowth * held,
                                radius: _pillRadius,
                              ),
                              child: Row(
                                children: [
                                  for (final (i, d)
                                      in widget.destinations.indexed)
                                    Expanded(
                                      child: _TabItem(
                                        destination: d,
                                        selected: i == shown,
                                        color: scheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (lens && heldAlpha > 0.01)
                        capsule(
                          // Excluded from the bar's batch: the
                          // lens must read the bar and its labels,
                          // not the page behind the bar, or the
                          // page shows through it sharp and
                          // untinted.
                          ClipRRect(
                            borderRadius: BorderRadius.circular(_pillRadius),
                            child: LiquidGlassBatch.exclude(
                              child: MornyeLiquidBackdrop(
                                borderRadius: BorderRadius.circular(
                                  _pillRadius,
                                ),
                                clarity: 1,
                                blurSigma: 0,
                                interaction: true,
                                progress: heldAlpha,
                                // A broad bevel shows the lens as it
                                // crosses the icons and leaves its
                                // centre undistorted.
                                refractionDepth: 0.18,
                                refractionWidth: 18,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      _pillRadius,
                                    ),
                                    color: Colors.white.withValues(
                                      alpha: heldAlpha * (dark ? 0.08 : 0.24),
                                    ),
                                    border: context.mornye.glassOutlines
                                        ? Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.6 * heldAlpha,
                                            ),
                                            width: 0.75,
                                          )
                                        : null,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
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
                              borderRadius: BorderRadius.circular(_pillRadius),
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
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SizedBox(
          // The slot keeps its height while the bar folds, so the page behind
          // does not shift.
          height: _height,
          child: AnimatedBuilder(
            animation: _foldCurve,
            builder: (context, _) {
              final t = _foldCurve.value;
              return LayoutBuilder(
                builder: (context, outer) {
                  final full = outer.maxWidth;
                  final size = _height + (_minimizedSize - _height) * t;
                  final width = full + (_minimizedSize - full) * t;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: width,
                      height: size,
                      child: MornyeGlass(
                        level: widget.level,
                        borderRadius: BorderRadius.circular(size / 2),
                        fill: scheme.surfaceContainer,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // The tabs keep their full-width layout while the
                            // bar folds, and fade out as it narrows.
                            IgnorePointer(
                              ignoring: t > 0.01,
                              child: Opacity(
                                opacity: 1 - t,
                                child: OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  minWidth: full,
                                  maxWidth: full,
                                  child: content,
                                ),
                              ),
                            ),
                            if (t > 0.01)
                              Opacity(
                                opacity: t,
                                child: _MinimizedTab(
                                  destination:
                                      widget.destinations[widget.selectedIndex],
                                  onTap: widget.onExpand,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Clips to the selection capsule: one tab wide, swollen by the hold.
class _CapsuleClipper extends CustomClipper<Path> {
  const _CapsuleClipper({
    required this.alignment,
    required this.count,
    required this.scaleX,
    required this.scaleY,
    required this.radius,
  });

  final double alignment;
  final int count;
  final double scaleX;
  final double scaleY;
  final double radius;

  @override
  Path getClip(Size size) {
    final tab = size.width / count;
    final centerX = (alignment + 1) / 2 * (size.width - tab) + tab / 2;
    final width = tab * scaleX;
    final height = size.height * scaleY;
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, size.height / 2),
          width: width,
          height: height,
        ),
        Radius.circular(radius),
      ),
    );
  }

  @override
  bool shouldReclip(_CapsuleClipper old) =>
      alignment != old.alignment ||
      count != old.count ||
      scaleX != old.scaleX ||
      scaleY != old.scaleY ||
      radius != old.radius;
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.destination,
    required this.selected,
    required this.color,
  });

  final NavDestination destination;
  final bool selected;

  /// The colour of the icon and label (the accent on the capsule layer).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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

/// What the folded bar shows: the selected tab's icon. Tapping it brings the
/// full bar back.
class _MinimizedTab extends StatelessWidget {
  const _MinimizedTab({required this.destination, required this.onTap});

  final NavDestination destination;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: IconTheme(
            data: IconThemeData(size: 25, color: primary),
            child: ExcludeSemantics(child: destination.selectedIcon),
          ),
        ),
      ),
    );
  }
}
