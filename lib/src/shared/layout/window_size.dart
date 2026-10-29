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
    this.clearBottomInset = true,
  });

  final Widget sliver;

  /// Space under the content, on top of the bottom inset the shell reports
  /// (the phone's bottom bar, which the body extends under, or the system's
  /// gesture area).
  final double bottom;

  /// Whether to add the shell's bottom inset. Only the last block of a screen
  /// needs it; one above more content does not.
  final bool clearBottomInset;

  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(
    builder: (context, constraints) {
      // A page can extend under the wide layout's rail; the rail's width
      // arrives as left padding. The margin is sized to what is left of it.
      final rail = MediaQuery.paddingOf(context).left;
      final inset = WindowSize.sideInset(constraints.crossAxisExtent - rail);
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          rail + inset,
          0,
          inset,
          bottom +
              (clearBottomInset ? MediaQuery.paddingOf(context).bottom : 0),
        ),
        // The rail is cleared by the padding above; what is inside no longer
        // sees it (see [SliverFillBody]).
        sliver: MediaQuery.removePadding(
          context: context,
          removeLeft: true,
          child: sliver,
        ),
      );
    },
  );
}

/// Fills the rest of the viewport with [child], centred in the area that is
/// actually visible: the wide layout's rail can sit over the page's left edge
/// (its width arrives as left padding), so the child is inset by it.
class SliverFillBody extends StatelessWidget {
  const SliverFillBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SliverFillRemaining(
    hasScrollBody: false,
    child: Padding(
      padding: EdgeInsets.only(left: MediaQuery.paddingOf(context).left),
      // Used up here, so a child that insets by the rail itself (EmptyState)
      // does not count it twice.
      child: MediaQuery.removePadding(
        context: context,
        removeLeft: true,
        child: child,
      ),
    ),
  );
}
