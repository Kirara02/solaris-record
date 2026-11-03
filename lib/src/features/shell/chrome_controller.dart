import 'package:flutter/widgets.dart';

/// Whether the Mornye tab bar is minimized. A deliberate vertical drag folds
/// the bar into one capsule until the page returns to its top, the tab changes
/// or the capsule is tapped. Horizontal rows, programmatic scrolling and the
/// overscroll bounce must not minimize it.
class ChromeController extends ValueNotifier<bool> {
  ChromeController() : super(false);

  /// Distance dragged in one direction since the last turn or stop.
  double _distance = 0;

  /// Dragging this far folds the bar.
  static const _foldDistance = 28.0;

  /// Within this of the top the bar is always expanded.
  static const _topSlack = 12.0;

  void expand() {
    _distance = 0;
    value = false;
  }

  /// Feed every scroll notification of the page; returns false so it keeps
  /// bubbling.
  bool handleScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollStartNotification ||
        notification is ScrollEndNotification) {
      _distance = 0;
    }
    if (notification is! ScrollUpdateNotification) return false;
    final metrics = notification.metrics;
    if (metrics.pixels <= metrics.minScrollExtent + _topSlack) {
      expand();
      return false;
    }
    // Bounce past an edge and scrolling that is not a finger drag do not count.
    if (metrics.outOfRange || notification.dragDetails == null) return false;
    final delta = notification.scrollDelta ?? 0;
    if (delta == 0) return false;
    if (_distance.sign != delta.sign) _distance = 0;
    _distance += delta;
    if (_distance >= _foldDistance) {
      value = true;
      _distance = 0;
    }
    return false;
  }
}
