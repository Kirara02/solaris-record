import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/settings/settings_providers.dart';
import 'marquee_text.dart';
import 'mornye_glass.dart';

/// Segmented control of the Mornye style: a glass capsule with a pill that
/// slides under the selected label. Tap a segment, or drag across the control
/// and let go on the one to pick.
///
/// It sits on a plain page or card as often as over content, so the glass only
/// tints; there is nothing behind it to blur.
class MornyeSegmentedControl extends ConsumerStatefulWidget {
  const MornyeSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  ConsumerState<MornyeSegmentedControl> createState() =>
      _MornyeSegmentedControlState();
}

class _MornyeSegmentedControlState
    extends ConsumerState<MornyeSegmentedControl> {
  /// Pill position while dragging, in alignment units (-1 first .. 1 last).
  double? _dragAlignment;
  int? _dragIndex;

  int get _count => widget.labels.length;

  int _indexAt(double x, double width) =>
      (x / width * _count).floor().clamp(0, _count - 1);

  void _drag(double x, double width) {
    if (width <= 0 || _count < 2) return;
    final half = width / _count / 2;
    final clamped = x.clamp(half, width - half);
    setState(() {
      _dragAlignment = (clamped - half) / (width - 2 * half) * 2 - 1;
      _dragIndex = _indexAt(x, width);
    });
  }

  void _endDrag() {
    final index = _dragIndex;
    setState(() {
      _dragAlignment = null;
      _dragIndex = null;
    });
    if (index != null && index != widget.selectedIndex) {
      widget.onChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final level = ref.watch(glassLevelProvider);
    // At least 56, so each segment keeps a 48 target inside the capsule.
    final height = (MediaQuery.textScalerOf(context).scale(15) + 36).clamp(
      56.0,
      double.infinity,
    );
    final radius = height / 2;
    final pillRadius = radius - 4;
    final shown = _dragIndex ?? widget.selectedIndex;
    final alignment =
        _dragAlignment ??
        (_count > 1 ? -1 + 2 * widget.selectedIndex / (_count - 1) : 0.0);
    final still =
        _dragAlignment != null || MediaQuery.disableAnimationsOf(context);
    return Semantics(
      container: true,
      child: SizedBox(
        height: height,
        child: MornyeGlass(
          level: level,
          samplesBackdrop: false,
          borderRadius: BorderRadius.circular(radius),
          fill: scheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (e) =>
                      widget.onChanged(_indexAt(e.localPosition.dx, width)),
                  onHorizontalDragStart: (e) =>
                      _drag(e.localPosition.dx, width),
                  onHorizontalDragUpdate: (e) =>
                      _drag(e.localPosition.dx, width),
                  onHorizontalDragEnd: (_) => _endDrag(),
                  onHorizontalDragCancel: () => setState(() {
                    _dragAlignment = null;
                    _dragIndex = null;
                  }),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedAlign(
                          duration: still
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment(alignment, 0),
                          child: FractionallySizedBox(
                            widthFactor: 1 / _count,
                            heightFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: scheme.onSurface.withValues(
                                  alpha: dark ? 0.12 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(pillRadius),
                                border: Border.all(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.05,
                                  ),
                                  width: 0.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 1,
                                    offset: const Offset(0, 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (final (i, label) in widget.labels.indexed)
                            Expanded(
                              child: Semantics(
                                button: true,
                                selected: i == widget.selectedIndex,
                                child: Center(
                                  child: MarqueeText(
                                    label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: i == shown
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
