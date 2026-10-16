import 'package:material_ui/material_ui.dart';

/// Material window size classes, resolved from the available width.
enum WindowSize {
  compact,
  medium,
  expanded;

  static WindowSize fromWidth(double width) => width >= 840
      ? expanded
      : width >= 600
      ? medium
      : compact;

  /// Outer page margin.
  double get margin => switch (this) {
    compact => 16,
    medium => 24,
    expanded => 32,
  };

  /// Horizontal page inset. Content spans the full window width; only this
  /// margin grows with the window size class.
  static double sideInset(double width) => fromWidth(width).margin;
}

extension WindowSizeContext on BuildContext {
  WindowSize get windowSize =>
      WindowSize.fromWidth(MediaQuery.sizeOf(this).width);
}

/// Pads a sliver horizontally by the window-size margin. Content is full
/// width on every platform; headers placed outside it use the same margin.
class SliverAdaptivePadding extends StatelessWidget {
  const SliverAdaptivePadding({
    super.key,
    required this.sliver,
    this.bottom = 24,
  });

  final Widget sliver;
  final double bottom;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) => SliverPadding(
      padding: EdgeInsets.fromLTRB(
        WindowSize.sideInset(constraints.crossAxisExtent),
        0,
        WindowSize.sideInset(constraints.crossAxisExtent),
        bottom,
      ),
      sliver: sliver,
    ),
  );
}
