// The package draws the lens with this exact curve but does not export it. The
// version is pinned (see pubspec.yaml), so the internal path is stable.
// ignore: implementation_imports
import 'package:liquid_glass_easy/src/widgets/utils/liquid_glass_shape.dart'
    show liquidGlassSquirclePath;
import 'package:material_ui/material_ui.dart';

/// The continuous-corner outline of a squircle lens. The fill, shadow, clip
/// and rim must all use it, or the clipped glass cuts into the lens' edge.
class MornyeSquircleBorder extends ShapeBorder {
  const MornyeSquircleBorder(this.radius);

  final double radius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => MornyeSquircleBorder(radius * t);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      liquidGlassSquirclePath(rect.size, radius, 1).shift(rect.topLeft);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  bool operator ==(Object other) =>
      other is MornyeSquircleBorder && other.radius == radius;

  @override
  int get hashCode => radius.hashCode;
}
