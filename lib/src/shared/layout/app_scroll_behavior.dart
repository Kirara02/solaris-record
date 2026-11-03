import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:material_ui/material_ui.dart';

/// Desktop scrollbars mark long vertical content only. Rows that scroll
/// sideways (shelves, chip rows) read cleaner without a bar.
class _VerticalScrollbarBehavior extends MaterialScrollBehavior {
  const _VerticalScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => axisDirectionToAxis(details.direction) == Axis.horizontal
      ? child
      : super.buildScrollbar(context, child, details);
}

/// iOS-style fluid scroll: momentum glide and bounce instead of Android's
/// clamping stop. Lists that set their own physics are unaffected.
class _FluidScrollBehavior extends _VerticalScrollbarBehavior {
  const _FluidScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}

/// The scroll behavior of the app. The Mornye style scrolls fluid on phones
/// and macOS, and without the overscroll effect on a low-end device, where it
/// costs frames. Windows and Linux keep Material's desktop clamping, and the
/// Material style keeps the platform physics.
ScrollBehavior appScrollBehavior({required bool mornye, required bool lowEnd}) {
  const base = _VerticalScrollbarBehavior();
  if (!mornye) return base;
  if (lowEnd) return base.copyWith(overscroll: false);
  final desktop = const {
    TargetPlatform.windows,
    TargetPlatform.linux,
  }.contains(defaultTargetPlatform);
  return desktop ? base : const _FluidScrollBehavior();
}
