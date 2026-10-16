import 'package:material_ui/material_ui.dart';

/// Icon animations that play when a tab's selected icon appears, i.e. each
/// time that tab is chosen (the nav bar mounts `selectedIcon` on selection).
/// With reduced motion they render in their final state immediately.
abstract class _TabIconAnimation extends StatefulWidget {
  const _TabIconAnimation({super.key, required this.child});

  final Widget child;

  Duration get duration;

  Widget buildAnimated(BuildContext context, AnimationController controller);

  @override
  State<_TabIconAnimation> createState() => _TabIconAnimationState();
}

class _TabIconAnimationState extends State<_TabIconAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.buildAnimated(context, _controller);
}

/// Pops in from a small scale with an elastic overshoot.
class BouncingIcon extends _TabIconAnimation {
  const BouncingIcon({super.key, required super.child});

  @override
  Duration get duration => const Duration(milliseconds: 400);

  @override
  Widget buildAnimated(BuildContext context, AnimationController controller) =>
      ScaleTransition(
        scale: Tween<double>(begin: 0.1, end: 1).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
        child: child,
      );
}

/// Half a turn with a slight overshoot (the settings cog).
class SpinIcon extends _TabIconAnimation {
  const SpinIcon({super.key, required super.child});

  @override
  Duration get duration => const Duration(milliseconds: 500);

  @override
  Widget buildAnimated(BuildContext context, AnimationController controller) =>
      RotationTransition(
        turns: Tween<double>(begin: 0, end: 0.5).animate(
          CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
        ),
        child: child,
      );
}
