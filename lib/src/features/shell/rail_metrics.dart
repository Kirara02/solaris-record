/// Sizes shared by the rail theme (see app.dart) and the hand-drawn rail
/// widgets, so both look like the same family.
abstract final class RailMetrics {
  /// Height of a rail item and of its selection indicator.
  static const itemHeight = 44.0;

  /// Height of the nested pull-type items.
  static const shortItemHeight = 40.0;

  /// Diameter of the round indicator of an icon-only (collapsed) item.
  static const collapsedIndicator = 48.0;

  /// Corner radius of the selection indicator: a rounded rectangle, not a pill.
  static const indicatorRadius = 12.0;
}
