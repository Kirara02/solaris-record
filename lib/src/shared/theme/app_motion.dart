import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:material_3_expressive/material_3_expressive.dart';

import 'mornye_theme.dart';

/// A [Curve] that follows an [M3ESpring] released from rest at 0 toward 1.
///
/// [duration] is the spring's settling time, so an animation driven by this
/// curve ends exactly when the physical motion does.
class SpringCurve extends Curve {
  SpringCurve(M3ESpring spring)
    : this._(SpringSimulation(spring.toDescription(), 0, 1, 0));

  SpringCurve._(this._simulation) : duration = _settleTime(_simulation);

  final SpringSimulation _simulation;
  final Duration duration;

  static Duration _settleTime(SpringSimulation simulation) {
    const step = 1 / 1000;
    var settledSince = 0.0;
    for (var t = 0.0; t < 2; t += step) {
      final settled =
          (simulation.x(t) - 1).abs() < 0.002 && simulation.dx(t).abs() < 0.02;
      if (!settled) {
        settledSince = t + step;
      } else if (t - settledSince >= 0.05) {
        break;
      }
    }
    return Duration(microseconds: (settledSince * 1e6).round());
  }

  @override
  double transformInternal(double t) =>
      _simulation.x(t * duration.inMicroseconds / 1e6);
}

/// Material 3 Expressive motion. The Mornye style and reduced motion keep the
/// platform's own transitions.
abstract final class AppMotion {
  static final _spatialSlow = SpringCurve(M3EMotion.expressiveSpatialSlow);

  /// Entrance for sheets and menus. The slow spatial spring is critically
  /// damped, so a surface never overshoots its own size and shows what is
  /// behind it. Null keeps the platform transition.
  static AnimationStyle? surfaceEntrance(BuildContext context) =>
      !context.isMornye && !MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle(
          duration: _spatialSlow.duration,
          curve: _spatialSlow,
          reverseDuration: const Duration(milliseconds: 200),
        )
      : null;
}
